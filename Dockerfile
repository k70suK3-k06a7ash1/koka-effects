FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV KOKA_VERSION=3.2.2

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gcc \
    g++ \
    make \
    cmake \
    git \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Koka
RUN curl -sSL https://github.com/koka-lang/koka/releases/download/v${KOKA_VERSION}/install.sh | sh

# Add Koka to PATH
ENV PATH="/usr/local/bin:${PATH}"

# Create working directory
WORKDIR /app

# Copy project files (if any)
COPY . /app

# Set the default command
CMD ["koka", "--help"]