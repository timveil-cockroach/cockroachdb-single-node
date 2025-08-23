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

### Testing Docker Image Health
```bash
# Check if CockroachDB is responding
docker exec <container_id> /cockroach/cockroach sql --insecure --execute="SELECT 1"
```

### Validating Shell Scripts
```bash
bash -n init.sh
```

## Architecture

The project consists of:

1. **Dockerfile**: 
   - Extends `cockroachdb/cockroach:latest`
   - Runs as non-root user (UID 1000) for security
   - Includes health check for container monitoring
   - Exposes ports 8080 (admin UI) and 26257 (SQL)
   - Uses OCI-compliant labels for metadata

2. **init.sh**: Entry point script that:
   - Starts CockroachDB in single-node mode with optional in-memory storage (via `MEMORY_SIZE` env var)
   - Applies SQL optimizations for testing environments
   - Creates a database if `DATABASE_NAME` env var is provided
   - Tails the CockroachDB logs to keep the container running

3. **optimizations.sql**: Contains cluster settings optimized for testing environments:
   - Disables raft log synchronization for faster operations
   - Reduces job registry intervals
   - Shortens garbage collection TTL
   - Disables automatic statistics collection

4. **logs.yaml**: CockroachDB logging configuration with various channels for different log types

## Environment Variables

- `DATABASE_NAME`: If provided, creates a database with this name after startup
- `MEMORY_SIZE`: If provided, uses in-memory storage with the specified size (e.g., "0.5" for 500MB)

## CI/CD Integration

### Docker Registry
The image automatically builds and publishes to Docker Hub only:
- `timveil/cockroachdb-single-node:latest` - always latest build
- `timveil/cockroachdb-single-node:2024.08.23` - date-based tag
- `timveil/cockroachdb-single-node:2024.08.23-abc1234` - date + commit SHA

### GitHub Actions Workflows
- **CI** (`.github/workflows/ci.yml`): Builds and tests on PRs and pushes
- **Release** (`.github/workflows/docker-release.yml`): Multi-platform builds and Docker Hub publishing
- **Dependabot** (`.github/dependabot.yml`): Automated dependency updates

### Required Secrets
- `DOCKER_USERNAME`: Docker Hub username
- `DOCKER_PASSWORD`: Docker Hub password/token

## Security Features
- Runs as non-root user (cockroach user, UID 1000)
- Generates SBOM and provenance attestations
- Multi-platform builds (linux/amd64, linux/arm64)
- Built-in health checks