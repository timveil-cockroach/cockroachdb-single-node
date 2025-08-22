# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker image project that creates a single-node CockroachDB instance, primarily designed for CI/CD pipelines and functional testing. The image automatically starts CockroachDB in single-node mode and can optionally create a database and use in-memory storage.

## Key Commands

### Building the Docker Image
```bash
docker build --no-cache -t timveil/cockroachdb-single-node:latest .
```

### Running the Image Locally
```bash
# With database creation and in-memory storage
docker run -d -it -p 8080:8080 -p 26257:26257 -e "DATABASE_NAME=test" -e "MEMORY_SIZE=.5" timveil/cockroachdb-single-node:latest

# Without environment variables
docker run -d -it -p 8080:8080 -p 26257:26257 timveil/cockroachdb-single-node:latest
```

### Publishing to Docker Hub
```bash
docker push timveil/cockroachdb-single-node:latest
```

### Validating Shell Scripts
```bash
bash -n init.sh
```

## Architecture

The project consists of:

1. **Dockerfile**: Extends `cockroachdb/cockroach:latest`, adds initialization scripts, and exposes ports 8080 (admin UI) and 26257 (SQL)

2. **init.sh**: Entry point script that:
   - Starts CockroachDB in single-node mode with optional in-memory storage (via `MEMORY_SIZE` env var)
   - Applies SQL optimizations for testing environments
   - Creates a database if `DATABASE_NAME` env var is provided
   - Tails the CockroachDB logs to keep the container running

3. **optimizations.sql**: Contains cluster settings optimized for testing environments, including disabled synchronization, reduced intervals, and shorter TTLs

4. **logs.yaml**: CockroachDB logging configuration with various channels for different log types

## Environment Variables

- `DATABASE_NAME`: If provided, creates a database with this name after startup
- `MEMORY_SIZE`: If provided, uses in-memory storage with the specified size (e.g., "0.5" for 500MB)

## CI/CD Integration

The image is designed for GitHub Actions service containers. It automatically builds and publishes to:
- GitHub Container Registry (ghcr.io) on every push to main
- Docker Hub (timveil/cockroachdb-single-node) on releases

GitHub Actions workflows handle:
- CI builds and tests on PRs and pushes
- Docker image releases with multi-platform support (linux/amd64, linux/arm64)
- Security scanning via Docker Scout
- Automated dependency updates via Dependabot