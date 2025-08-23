# Koka Algebraic Effects Examples

A comprehensive collection of examples demonstrating algebraic effects in the Koka programming language.

## What are Algebraic Effects?

Algebraic effects provide a powerful way to structure programs with side effects. They allow you to:
- Define custom computational effects (like state, exceptions, async/await)
- Handle effects in a modular and composable way
- Maintain type safety while managing complex control flow
- Implement advanced control abstractions as libraries rather than language primitives

## Examples

### 1. Basic Effects (`effects_basic.kk`)
Introduces fundamental concepts:
- State effect with get/set operations
- Exception handling with throw/catch
- Combining multiple effects

```bash
docker run --rm koka-app koka -e effects_basic.kk
```

### 2. Generator/Yield (`effects_yield.kk`)
Demonstrates control flow with generators:
- Yield effect for lazy sequences
- Tree traversal with yield
- Collection operations (filter, take, find)
- Use of `ctl` and `resume` keywords

```bash
docker run --rm koka-app koka -e effects_yield.kk
```

### 3. Async/Await (`effects_async.kk`)
Shows how algebraic effects model asynchronous operations:
- Async effect for non-blocking operations
- Simulated delays and parallel execution
- Error handling in async contexts
- Chaining async operations

```bash
docker run --rm koka-app koka -e effects_async.kk
```

### 4. Non-determinism/Choice (`effects_choice.kk`)
Explores backtracking and multiple results:
- Choice effect for non-deterministic computation
- Constraint solving examples
- N-Queens problem solver
- Logic programming patterns with amb and guard

```bash
docker run --rm koka-app koka -e effects_choice.kk
```

### 5. Combined Effects (`effects_combined.kk`)
Advanced patterns with multiple effects:
- Composition of state, logging, exceptions, and reader effects
- Transaction support with rollback
- Resource management
- Effect polymorphism
- Retry mechanisms

```bash
docker run --rm koka-app koka -e effects_combined.kk
```

## Quick Start

### Using Docker

1. Build the Docker image:
```bash
docker build -t koka-app .
```

2. Run the hello world example:
```bash
docker run --rm koka-app koka -e hello.kk
```

3. Run any effect example:
```bash
docker run --rm koka-app koka -e effects_basic.kk
```

### Using Make

```bash
# Run hello world in Docker
make run

# Run specific effect examples
make effects-basic
make effects-yield
make effects-async
make effects-choice
make effects-combined

# Run all examples
make all-effects
```

## Interactive Development

To explore and modify the examples interactively:

```bash
docker run --rm -it -v $(pwd):/app koka-app bash
# Inside container:
koka -e effects_basic.kk
```

## Key Concepts

### Effect Definitions
```koka
effect state<s>
  fun get() : s
  fun set(x : s) : ()
```

### Control Operations
```koka
effect yield<a>
  ctl yield(value : a) : bool
```

### Handlers
```koka
handler
  var s := initial
  fun get() s
  fun set(x) s := x
  { action() }
```

### Resume Continuations
```koka
handler
  ctl yield(x)
    process(x)
    resume(True)  // Continue execution
  { generator() }
```

## Resources

- [Koka Language Documentation](https://koka-lang.github.io/koka/doc/book.html)
- [Algebraic Effects Tutorial](https://www.microsoft.com/en-us/research/project/koka/)
- [Effect Handlers in Practice](https://github.com/koka-lang/koka)

## Requirements

- Docker
- Make (optional, for convenience commands)

## License

These examples are provided for educational purposes to demonstrate Koka's algebraic effects system.