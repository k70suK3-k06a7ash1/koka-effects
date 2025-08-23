// Generator pattern in Koka
// Demonstrates basic iteration and list generation

// Generate numbers from 1 to n
fun count-to(n : int) : <div> list<int>
  if n <= 0 then
    []
  else
    fun loop(i : int, acc : list<int>) : <div> list<int>
      if i > n then
        acc.reverse
      else
        loop(i + 1, Cons(i, acc))
    loop(1, [])

// Fibonacci generator
fun fibonacci-numbers(limit : int) : <div> list<int>
  if limit <= 0 then
    []
  else
    fun fib-loop(count : int, a : int, b : int, acc : list<int>) : <div> list<int>
      if count >= limit then
        acc.reverse
      else
        fib-loop(count + 1, b, a + b, Cons(b, acc))
    fib-loop(0, 0, 1, [])

// Tree structure and traversal
type tree<a>
  Leaf(value : a)
  Node(left : tree<a>, right : tree<a>)

fun traverse-tree(t : tree<int>) : <div> list<int>
  match t
    Leaf(v) -> [v]
    Node(l, r) ->
      traverse-tree(l) ++ traverse-tree(r)

// Process values one by one
fun process-each(values : list<int>, process : int -> console ()) : console ()
  match values
    [] -> ()
    Cons(x, xs) ->
      process(x)
      process-each(xs, process)

// Find first matching value
fun find-first(values : list<int>, predicate : int -> <div> bool) : <div> maybe<int>
  match values
    [] -> Nothing
    Cons(x, xs) ->
      if predicate(x) then
        Just(x)
      else
        find-first(xs, predicate)

// Take first n values
fun take-first(n : int, values : list<int>) : <div> list<int>
  if n <= 0 then
    []
  else
    match values
      [] -> []
      Cons(x, xs) ->
        Cons(x, take-first(n - 1, xs))

// Filter values
fun filter-values(values : list<int>, predicate : int -> <div> bool) : <div> list<int>
  values.filter(predicate)

fun main() : <console,div> ()
  println("=== Basic Number Generation ===")
  val numbers = count-to(5)
  println("Numbers 1 to 5: " ++ numbers.show)
  
  println("\n=== Fibonacci Generation ===")
  val fibs = fibonacci-numbers(10)
  println("First 10 Fibonacci numbers: " ++ fibs.show)
  
  println("\n=== Process Values One by One ===")
  process-each(count-to(3)) fn(x)
    println("Processing: " ++ x.show)
  
  println("\n=== Tree Traversal ===")
  val tree = Node(
    Node(Leaf(1), Leaf(2)),
    Node(Leaf(3), Node(Leaf(4), Leaf(5)))
  )
  val tree-values = traverse-tree(tree)
  println("Tree values: " ++ tree-values.show)
  
  println("\n=== Find First Even Number ===")
  val first-even = find-first(count-to(10)) fn(x)
    x % 2 == 0
  match first-even
    Just(v) -> println("First even: " ++ v.show)
    Nothing -> println("No even number found")
  
  println("\n=== Take First N Values ===")
  val first-three = take-first(3, fibonacci-numbers(100))
  println("First 3 Fibonacci numbers: " ++ first-three.show)
  
  println("\n=== Filter Even Numbers ===")
  val evens = filter-values(count-to(10)) fn(x)
    x % 2 == 0
  println("Even numbers from 1 to 10: " ++ evens.show)