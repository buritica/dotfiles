FROM ubuntu:latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    bats \
    git \
    curl \
    wget \
    sudo \
    lcov \
    && rm -rf /var/lib/apt/lists/*

# Install BATS helpers
RUN mkdir -p /test/test_helper && \
    git clone https://github.com/bats-core/bats-support.git /test/test_helper/bats-support && \
    git clone https://github.com/bats-core/bats-assert.git /test/test_helper/bats-assert

# Install chezmoi
RUN sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin

# Set up test environment
ENV HOME=/test/home
ENV CHEZMOI_USERNAME=test_user
ENV CHEZMOI_EMAIL=test@example.com
ENV CHEZMOI_NAME="Test User"
ENV CHEZMOI_ARCH=amd64
ENV CHEZMOI_OS=linux
ENV CHEZMOI_HOSTNAME=test-host

# Create test directory
RUN mkdir -p /test/home

# Set working directory
WORKDIR /test

# Copy test files
COPY test/ /test/

# Make test files executable
RUN chmod +x /test/*.sh

# Set entrypoint
ENTRYPOINT ["bats"]
CMD ["/test"] 