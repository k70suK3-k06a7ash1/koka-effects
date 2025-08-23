// Basic Algebraic Effects in Koka
// Demonstrates state and exception effects

import std/num/int32

// Define a simple state effect
effect state<s>
  fun get() : s
  fun set(x : s) : ()

// Define an exception effect
effect except<e>
  ctl throw(err : e) : a

// Function using state effect
fun increment() : state<int> int
  val current = get()
  set(current + 1)
  current + 1

// Function using exception effect
fun divide(x : int, y : int) : except<string> int
  if y == 0 then
    throw("Division by zero!")
  else
    x / y

// Example with state handler
fun state-example() : console ()
  val result = handler
    var s := 10
    fun get() s
    fun set(x) s := x
    {
      println("Initial state: " ++ get().show)
      val r1 = increment()
      println("After first increment: " ++ get().show ++ ", returned: " ++ r1.show)
      val r2 = increment()
      println("After second increment: " ++ get().show ++ ", returned: " ++ r2.show)
      get()
    }
  println("Final result: " ++ result.show)

// Example with exception handler
fun exception-example() : console ()
  fun safe-divide(x : int, y : int) : console ()
    val result = handler
      ctl throw(err)
        println("Error: " ++ err)
        -1  // Default value on error
      {
        divide(x, y)
      }
    println(x.show ++ " / " ++ y.show ++ " = " ++ result.show)
  
  safe-divide(10, 2)
  safe-divide(10, 0)
  safe-divide(15, 3)

// Combining multiple effects
fun combined-example() : console ()
  val result = handler
    var count := 0
    fun get() count
    fun set(x) count := x
    {
      handler
        ctl throw(err)
          println("Caught error: " ++ err ++ " at count " ++ get().show)
          0
        {
          set(1)
          println("Count: " ++ get().show)
          set(2)
          println("Count: " ++ get().show)
          val r = divide(10, 2)
          set(get() + r)
          println("After successful division, count: " ++ get().show)
          val r2 = divide(10, 0)  // This will throw
          set(get() + r2)  // This won't execute
          get()
        }
    }
  println("Combined result: " ++ result.show)

fun main() : console ()
  println("=== State Effect Example ===")
  state-example()
  println("")
  
  println("=== Exception Effect Example ===")
  exception-example()
  println("")
  
  println("=== Combined Effects Example ===")
  combined-example()