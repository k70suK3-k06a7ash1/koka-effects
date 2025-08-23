// Generator/Yield Effects in Koka
// Demonstrates control flow with yield and resume

// Define yield effect for generators
effect yield<a>
  ctl yield(value : a) : bool

// Simple generator that yields numbers
fun count-to(n : int) : yield<int> ()
  var i := 1
  while { i <= n }
    val continue = yield(i)
    if continue then
      i := i + 1
    else
      break()

// Fibonacci generator using yield
fun fibonacci-gen(limit : int) : <yield<int>,div> ()
  var a := 0
  var b := 1
  var count := 0
  while { count < limit }
    yield(b)
    val next = a + b
    a := b
    b := next
    count := count + 1

// Tree traversal with yield
type tree<a>
  Leaf(value : a)
  Node(left : tree<a>, right : tree<a>)

fun traverse(t : tree<int>) : yield<int> ()
  match t
    Leaf(v) -> yield(v); ()
    Node(l, r) ->
      traverse(l)
      traverse(r)

// Handler that collects all yielded values
fun collect(action : () -> <yield<a>|e> ()) : e list<a>
  var result := []
  handler
    return(_) result.reverse
    ctl yield(x)
      result := Cons(x, result)
      resume(True)
    { action() }

// Handler that processes values one by one
fun foreach(action : () -> <yield<a>|e> (), process : a -> e ()) : e ()
  handler
    return(_) ()
    ctl yield(x)
      process(x)
      resume(True)
    { action() }

// Handler that finds first matching value
fun find-first(action : () -> <yield<a>|e> (), predicate : a -> e bool) : e maybe<a>
  handler
    return(_) Nothing
    ctl yield(x)
      if predicate(x) then
        Just(x)
      else
        resume(True)
    { action() }

// Handler that takes only first n values
fun take(n : int, action : () -> <yield<a>|e> ()) : e list<a>
  var count := 0
  var result := []
  handler
    return(_) result.reverse
    ctl yield(x)
      if count < n then
        result := Cons(x, result)
        count := count + 1
        resume(True)
      else
        result.reverse
    { action() }

// Filter values using yield
fun filter-yield(action : () -> <yield<a>|e> (), predicate : a -> e bool) : <yield<a>|e> ()
  handler
    return(_) ()
    ctl yield(x)
      if predicate(x) then
        yield(x)
      resume(True)
    { action() }

fun main() : <console,div> ()
  println("=== Basic Generator ===")
  val numbers = collect { count-to(5) }
  println("Numbers 1 to 5: " ++ numbers.show)
  
  println("\n=== Fibonacci Generator ===")
  val fibs = collect { fibonacci-gen(10) }
  println("First 10 Fibonacci numbers: " ++ fibs.show)
  
  println("\n=== Process Values One by One ===")
  foreach({count-to(3)}) fn(x)
    println("Processing: " ++ x.show)
  
  println("\n=== Tree Traversal ===")
  val tree = Node(
    Node(Leaf(1), Leaf(2)),
    Node(Leaf(3), Node(Leaf(4), Leaf(5)))
  )
  val tree-values = collect { traverse(tree) }
  println("Tree values: " ++ tree-values.show)
  
  println("\n=== Find First Even Number ===")
  val first-even = find-first({count-to(10)}) fn(x)
    x % 2 == 0
  match first-even
    Just(v) -> println("First even: " ++ v.show)
    Nothing -> println("No even number found")
  
  println("\n=== Take First N Values ===")
  val first-three = take(3) { fibonacci-gen(100) }
  println("First 3 Fibonacci numbers: " ++ first-three.show)
  
  println("\n=== Filter Even Numbers ===")
  val evens = collect
    filter-yield({count-to(10)}) fn(x)
      x % 2 == 0
  println("Even numbers from 1 to 10: " ++ evens.show)