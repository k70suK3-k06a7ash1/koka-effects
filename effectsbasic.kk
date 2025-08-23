// Basic Effects in Koka
// Demonstrates basic state and safe division

import std/num/int32

// Function with local state
fun counter-example() : console ()
  var count := 0
  fun increment() : <local<_>,console> int
    count := count + 1
    count
  
  println("=== Local State Example ===")
  println("Initial count: " ++ count.show)
  val r1 = increment()
  println("After first increment: " ++ count.show ++ ", returned: " ++ r1.show)
  val r2 = increment()
  println("After second increment: " ++ count.show ++ ", returned: " ++ r2.show)

// Example with maybe type for safer division
fun safe-divide(x : int, y : int) : maybe<int>
  if y == 0 then
    Nothing
  else
    Just(x / y)

fun maybe-example() : console ()
  fun print-division(x : int, y : int) : console ()
    match safe-divide(x, y)
      Just(result) -> println(x.show ++ " / " ++ y.show ++ " = " ++ result.show)
      Nothing -> println("Error: Division by zero for " ++ x.show ++ " / " ++ y.show)
  
  println("=== Safe Division Example ===")
  print-division(10, 2)
  print-division(10, 0)
  print-division(15, 3)

fun main() : console ()
  counter-example()
  println("")
  
  maybe-example()