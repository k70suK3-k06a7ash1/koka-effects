// Async simulation in Koka
// Demonstrates sequential operations that simulate async behavior

// Simulated data fetching function
fun fetch-data(id : int) : <console,div> string
  println("Starting fetch for id: " ++ id.show)
  // Simulate processing with a simple loop
  var counter := 0
  while { counter < (id * 100) }
    counter := counter + 1
  
  val result = "Data-" ++ id.show
  println("Completed fetch for id: " ++ id.show)
  result

// Fetch multiple items sequentially
fun fetch-multiple() : <console,div> list<string>
  println("Fetching multiple items...")
  val result1 = fetch-data(1)
  val result2 = fetch-data(2)
  val result3 = fetch-data(3)
  [result1, result2, result3]

// Process data with validation
fun validate-and-fetch(id : int) : <console,div> string
  if id <= 0 then
    "Invalid ID: " ++ id.show
  else
    fetch-data(id)

// Chain operations
fun process-data() : console int
  println("Processing data...")
  val rawstr = "42"
  // Simple parsing simulation
  42

// Batch processing
fun batch-process(ids : list<int>) : <console,div> list<string>
  println("Batch processing " ++ ids.length.show ++ " items")
  ids.map(fn(id) fetch-data(id))

fun main() : <console,div> ()
  println("=== Single Fetch ===")
  val single = fetch-data(1)
  println("Result: " ++ single)
  
  println("\n=== Multiple Fetch ===")
  val multiple = fetch-multiple()
  println("Results: " ++ multiple.show)
  
  println("\n=== Validated Fetch ===")
  val valid = validate-and-fetch(2)
  val invalid = validate-and-fetch(-1)
  println("Valid: " ++ valid)
  println("Invalid: " ++ invalid)
  
  println("\n=== Data Processing ===")
  val processed = process-data()
  println("Processed: " ++ processed.show)
  
  println("\n=== Batch Processing ===")
  val batch = batch-process([1, 2, 3])
  println("Batch results: " ++ batch.show)