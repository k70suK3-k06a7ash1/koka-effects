.PHONY: build run shell clean test

# Build the Docker image
build:
	docker build -t koka-effects:latest .

# Run the container interactively
run: build
	docker run -it --rm -v $(PWD):/app koka-effects:latest /bin/bash

# Run a specific Koka file
test: build
	docker run --rm -v $(PWD):/app koka-effects:latest koka hello.kk

# Execute the compiled program
exec: build
	docker run --rm -v $(PWD):/app koka-effects:latest koka -e hello.kk

# Start shell in container
shell: build
	docker run -it --rm -v $(PWD):/app koka-effects:latest /bin/bash

# Clean up Docker images
clean:
	docker rmi koka-effects:latest

# Using docker-compose
compose-up:
	docker-compose up -d

compose-down:
	docker-compose down

compose-shell:
	docker-compose exec koka /bin/bash