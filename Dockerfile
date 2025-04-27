FROM ubuntu:24.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    zsh \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -s /bin/zsh testuser && \
    echo "testuser:testuser" | chpasswd && \
    adduser testuser sudo

# Set up the test environment
WORKDIR /home/testuser
USER testuser

# Install chezmoi
RUN sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /home/testuser/.local/bin

# Add chezmoi to PATH
ENV PATH="/home/testuser/.local/bin:${PATH}"

# Copy dotfiles
COPY --chown=testuser:testuser . /home/testuser/dotfiles

# Set up test environment
WORKDIR /home/testuser/dotfiles
RUN chmod +x test.sh

# Run tests
CMD ["./test.sh"] 