FROM ghcr.io/linuxserver/baseimage-ubuntu:22.04

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

# Copy only necessary files
COPY test.sh setup.sh .chezmoi.toml.tmpl .chezmoiignore dot_gitconfig.tmpl dot_gitignore dot_zshrc .yamllint /test/

# Make test files executable
RUN chmod +x /test/*.sh

# Set entrypoint
ENTRYPOINT ["/test/test.sh"] 