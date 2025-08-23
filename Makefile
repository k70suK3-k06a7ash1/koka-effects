.PHONY: build run shell clean test all-effects

# Docker image name
IMAGE_NAME := koka-app

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) .

# Run the hello.kk example
run: build
	docker run --rm $(IMAGE_NAME) koka -e hello.kk

# Run a specific Koka file
test: build
	docker run --rm -v $(PWD):/app $(IMAGE_NAME) koka hello.kk

# Execute the compiled program
exec: build
	docker run --rm -v $(PWD):/app $(IMAGE_NAME) koka -e hello.kk

# Start shell in container
shell: build
	docker run -it --rm -v $(PWD):/app $(IMAGE_NAME) /bin/bash

# Clean up Docker images
clean:
	docker rmi $(IMAGE_NAME)

# Algebraic Effects Examples
effects-basic: build
	@echo "=== Running Basic Effects Example ==="
	@docker run --rm $(IMAGE_NAME) koka -e effectsbasic.kk

effects-yield: build
	@echo "=== Running Generator/Yield Example ==="
	@docker run --rm $(IMAGE_NAME) koka -e effectsyield.kk

effects-async: build
	@echo "=== Running Async/Await Example ==="
	@docker run --rm $(IMAGE_NAME) koka -e effectsasync.kk

effects-choice: build
	@echo "=== Running Non-determinism/Choice Example ==="
	@docker run --rm $(IMAGE_NAME) koka -e effectschoice.kk

effects-combined: build
	@echo "=== Running Combined Effects Example ==="
	@docker run --rm $(IMAGE_NAME) koka -e effectscombined.kk

# Run all effect examples
all-effects: effects-basic effects-yield effects-async effects-choice effects-combined
	@echo "=== All effect examples completed ==="

# Interactive mode for effect examples
effects-interactive: build
	@echo "Starting interactive shell for effect examples..."
	@echo "Try: koka -e effects_basic.kk"
	@docker run -it --rm -v $(PWD):/app $(IMAGE_NAME) /bin/bash

# Help command
help:
	@echo "Koka Effects Examples - Available Commands:"
	@echo ""
	@echo "  make build              - Build the Docker image"
	@echo "  make run                - Run hello.kk example"
	@echo "  make shell              - Start interactive shell"
	@echo "  make effects-basic      - Run basic effects example"
	@echo "  make effects-yield      - Run generator/yield example"
	@echo "  make effects-async      - Run async/await example"
	@echo "  make effects-choice     - Run non-determinism example"
	@echo "  make effects-combined   - Run combined effects example"
	@echo "  make all-effects        - Run all effect examples"
	@echo "  make effects-interactive - Interactive shell for effects"
	@echo "  make clean              - Remove Docker image"
	@echo "  make help               - Show this help message"