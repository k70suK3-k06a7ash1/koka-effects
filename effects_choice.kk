// Non-determinism/Choice Effects in Koka
// Demonstrates backtracking and multiple results using algebraic effects

// Define choice effect for non-deterministic computation
effect choice
  ctl choose(options : list<a>) : a
  ctl fail() : a

// Simple binary choice
fun flip() : choice bool
  choose([True, False])

// Choose a number from a range
fun pick(from : int, to : int) : choice int
  choose([from, to - 1, to].concat([from + 1, to - 2].filter(fn(x) x > from && x < to)))

// Constraint solving with choice
fun solve-equation() : choice (int, int)
  val x = choose([1, 2, 3, 4, 5])
  val y = choose([1, 2, 3, 4, 5])
  
  // Add constraints
  if x + y != 6 then fail()
  if x < y then fail()
  
  (x, y)

// N-Queens problem helper
fun is-safe(board : list<int>, col : int) : bool
  fun check(board' : list<int>, row : int) : bool
    match board'
      Nil -> True
      Cons(c, rest) ->
        if c == col || c == col - row || c == col + row then
          False
        else
          check(rest, row + 1)
  check(board, 1)

// N-Queens solver using choice
fun n-queens(n : int) : choice list<int>
  fun place-queens(board : list<int>) : choice list<int>
    val row = board.length
    if row >= n then
      board
    else
      val col = choose([1, 2, 3, 4, 5, 6, 7, 8].take(n))
      if is-safe(board, col) then
        place-queens(Cons(col, board))
      else
        fail()
  
  place-queens([])

// Pythagorean triples
fun pythagorean(limit : int) : choice (int, int, int)
  val a = choose([1, 2, 3, 4, 5, 6, 7, 8, 9, 10].filter(fn(x) x <= limit))
  val b = choose([1, 2, 3, 4, 5, 6, 7, 8, 9, 10].filter(fn(x) x <= limit && x >= a))
  val c = choose([1, 2, 3, 4, 5, 6, 7, 8, 9, 10].filter(fn(x) x <= limit && x > b))
  
  if a * a + b * b == c * c then
    (a, b, c)
  else
    fail()

// Logic puzzle: Find digits for SEND + MORE = MONEY
fun send-more-money() : choice (int, int, int, int, int, int, int, int)
  val s = choose([1, 2, 3, 4, 5, 6, 7, 8, 9])  // S can't be 0
  val e = choose([0, 1, 2, 3, 4, 5, 6, 7, 8, 9].filter(fn(x) x != s))
  val n = choose([0, 1, 2, 3, 4, 5, 6, 7, 8, 9].filter(fn(x) x != s && x != e))
  val d = choose([0, 1, 2, 3, 4, 5, 6, 7, 8, 9].filter(fn(x) x != s && x != e && x != n))
  val m = choose([1, 2, 3, 4, 5, 6, 7, 8, 9].filter(fn(x) x != s && x != e && x != n && x != d))  // M can't be 0
  val o = choose([0, 1, 2, 3, 4, 5, 6, 7, 8, 9].filter(fn(x) x != s && x != e && x != n && x != d && x != m))
  val r = choose([0, 1, 2, 3, 4, 5, 6, 7, 8, 9].filter(fn(x) x != s && x != e && x != n && x != d && x != m && x != o))
  val y = choose([0, 1, 2, 3, 4, 5, 6, 7, 8, 9].filter(fn(x) x != s && x != e && x != n && x != d && x != m && x != o && x != r))
  
  val send = s * 1000 + e * 100 + n * 10 + d
  val more = m * 1000 + o * 100 + r * 10 + e
  val money = m * 10000 + o * 1000 + n * 100 + e * 10 + y
  
  if send + more == money then
    (s, e, n, d, m, o, r, y)
  else
    fail()

// Handler that finds all solutions
fun find-all(action : () -> <choice|e> a) : e list<a>
  handler
    return(x) [x]
    ctl choose(xs)
      xs.flatmap(fn(x) resume(x))
    ctl fail()
      []
    { action() }

// Handler that finds first solution
fun find-first-solution(action : () -> <choice|e> a) : e maybe<a>
  handler
    return(x) Just(x)
    ctl choose(xs)
      fun try-options(options : list<b>) : maybe<a>
        match options
          Nil -> Nothing
          Cons(x, rest) ->
            match resume(x)
              Just(result) -> Just(result)
              Nothing -> try-options(rest)
      try-options(xs)
    ctl fail()
      Nothing
    { action() }

// Handler that counts solutions
fun count-solutions(action : () -> <choice|e> a) : e int
  handler
    return(_) 1
    ctl choose(xs)
      xs.map(fn(x) resume(x)).sum
    ctl fail()
      0
    { action() }

// Amb operator - choose with explicit alternatives
fun amb(a : a, b : a) : choice a
  choose([a, b])

// Guard - fail if condition is false
fun guard(condition : bool) : choice ()
  if !condition then fail() else ()

// Example using amb and guard
fun logic-example() : choice (int, int)
  val x = amb(3, 4)
  val y = amb(5, 6)
  guard(x + y > 8)
  (x, y)

fun main() : <console,div> ()
  println("=== Simple Choice ===")
  val flips = find-all { flip() }
  println("All flip results: " ++ flips.show)
  
  println("\n=== Solve Equation x + y = 6, x >= y ===")
  val solutions = find-all { solve-equation() }
  println("Solutions: " ++ solutions.show)
  
  println("\n=== Pythagorean Triples (limit 10) ===")
  val triples = find-all { pythagorean(10) }
  println("Pythagorean triples: " ++ triples.show)
  
  println("\n=== Logic with amb and guard ===")
  val logic-results = find-all { logic-example() }
  println("Results where x + y > 8: " ++ logic-results.show)
  
  println("\n=== Count Solutions ===")
  val count = count-solutions { solve-equation() }
  println("Number of solutions to x + y = 6, x >= y: " ++ count.show)
  
  println("\n=== Find First Solution ===")
  val first = find-first-solution { pythagorean(20) }
  match first
    Just((a, b, c)) -> 
      println("First Pythagorean triple: " ++ a.show ++ "² + " ++ b.show ++ "² = " ++ c.show ++ "²")
    Nothing -> 
      println("No solution found")
  
  println("\n=== 4-Queens Problem ===")
  val queens-count = count-solutions { n-queens(4) }
  println("Number of solutions for 4-queens: " ++ queens-count.show)
  val queens-solutions = find-all { n-queens(4) }.take(2)
  println("First 2 solutions: " ++ queens-solutions.show)