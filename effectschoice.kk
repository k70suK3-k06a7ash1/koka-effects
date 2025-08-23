// Choice patterns in Koka
// Demonstrates working with options and multiple results

// Simple binary choice using maybe
fun flip() : maybe<bool>
  Just(True)  // Simplified choice

// Choose from a range using list
fun pick-range(from : int, to : int) : <div> list<int>
  fun range(start : int, end : int, acc : list<int>) : <div> list<int>
    if start > end then
      acc.reverse
    else
      range(start + 1, end, Cons(start, acc))
  range(from, to, [])

// Generate combinations
fun combinations() : <div> list<(int, int)>
  val numbers = [1, 2, 3, 4, 5]
  numbers.flatmap fn(x)
    numbers.map fn(y)
      (x, y)

// Filter valid solutions
fun solve-equation() : <div> list<(int, int)>
  val pairs = combinations()
  pairs.filter fn((x, y))
    x + y == 7

// Backtracking simulation with lists
fun find-paths() : list<list<string>>
  val paths = [
    ["start", "left", "goal"],
    ["start", "right", "goal"],
    ["start", "middle", "goal"]
  ]
  paths

// N-Queens-like constraint problem (simplified)
fun place-queens(n : int) : <div> list<list<int>>
  if n <= 0 then
    [[]]
  else if n == 1 then
    [[1]]
  else if n == 2 then
    []  // No solution for n=2
  else
    // Simplified solution for n >= 3
    val positions = pick-range(1, n)
    [positions]

// Search with pruning
fun search-with-pruning(target : int) : <div> list<int>
  val candidates = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  candidates.filter fn(x)
    x <= target

fun main() : <console,div> ()
  println("=== Binary Choice ===")
  match flip()
    Just(b) -> println("Choice: " ++ b.show)
    Nothing -> println("No choice")
  
  println("\n=== Range Selection ===")
  val range = pick-range(1, 5)
  println("Range 1-5: " ++ range.show)
  
  println("\n=== All Combinations ===")
  val combos = combinations()
  println("First 10 combinations: " ++ combos.take(10).show)
  
  println("\n=== Equation Solutions ===")
  val solutions = solve-equation()
  println("Solutions to x + y = 7: " ++ solutions.show)
  
  println("\n=== Path Finding ===")
  val paths = find-paths()
  println("Available paths: " ++ paths.show)
  
  println("\n=== Queens Problem (simplified) ===")
  val queens = place-queens(4)
  println("Queen positions for n=4: " ++ queens.show)
  
  println("\n=== Search with Pruning ===")
  val pruned = search-with-pruning(5)
  println("Numbers <= 5: " ++ pruned.show)