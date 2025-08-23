# CockroachDB Single Node

[![CI Build and Test](https://github.com/timveil-cockroach/cockroachdb-single-node/actions/workflows/ci.yml/badge.svg)](https://github.com/timveil-cockroach/cockroachdb-single-node/actions/workflows/ci.yml)
[![Release Docker Image](https://github.com/timveil-cockroach/cockroachdb-single-node/actions/workflows/docker-release.yml/badge.svg)](https://github.com/timveil-cockroach/cockroachdb-single-node/actions/workflows/docker-release.yml)
[![Docker Hub](https://img.shields.io/docker/pulls/timveil/cockroachdb-single-node)](https://hub.docker.com/repository/docker/timveil/cockroachdb-single-node)

A lightweight [CockroachDB](https://www.cockroachlabs.com/) Docker image optimized for CI/CD pipelines and functional testing. This image extends the official CockroachDB Docker image with automatic single-node startup, optional database creation, and performance optimizations for testing environments.

## Features

✅ **Automatic startup** - CockroachDB starts immediately in single-node mode  
✅ **Database creation** - Optionally creates a named database on startup  
✅ **In-memory storage** - Configurable in-memory storage for faster tests  
✅ **Security hardened** - Runs as non-root user with health checks  
✅ **CI/CD optimized** - Perfect for GitHub Actions service containers  
✅ **Multi-platform** - Supports both AMD64 and ARM64 architectures  

## Quick Start

### Basic Usage
```bash
# Run with default settings
docker run -d -p 8080:8080 -p 26257:26257 timveil/cockroachdb-single-node:latest

# Access CockroachDB Admin UI
open http://localhost:8080

# Connect with SQL client
docker exec -it <container_id> /cockroach/cockroach sql --insecure
```

### With Custom Database and In-Memory Storage
```bash
docker run -d -p 8080:8080 -p 26257:26257 \
  -e "DATABASE_NAME=myapp" \
  -e "MEMORY_SIZE=1" \
  timveil/cockroachdb-single-node:latest
```

## Environment Variables

| Variable | Description | Example | Default |
|----------|-------------|---------|---------|
| `DATABASE_NAME` | Creates a database with this name on startup | `testdb` | None |
| `MEMORY_SIZE` | Uses in-memory storage with specified size (GB) | `0.5` | Persistent storage |

## GitHub Actions Integration

Perfect for use as a [service container](https://docs.github.com/en/actions/using-containerized-services/about-service-containers) in GitHub Actions workflows:

```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      cockroach:
        image: timveil/cockroachdb-single-node:latest
        env:
          DATABASE_NAME: testdb
          MEMORY_SIZE: 0.5
        ports:
          - 26257:26257
        options: >-
          --health-cmd="/cockroach/cockroach sql --insecure --execute='SELECT 1'"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5

    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: |
          # Your test commands here
          # CockroachDB is available at localhost:26257
```

## Available Tags

The image is automatically built and published to Docker Hub with multiple tags:

| Tag | Description | Example |
|-----|-------------|---------|
| `latest` | Latest build from main branch | `timveil/cockroachdb-single-node:latest` |
| `YYYY.MM.DD` | Date-based releases | `timveil/cockroachdb-single-node:2024.08.23` |
| `YYYY.MM.DD-{sha}` | Date + commit SHA | `timveil/cockroachdb-single-node:2024.08.23-abc1234` |

## Performance Optimizations

This image includes several CockroachDB settings optimized for testing environments:

- **Disabled raft log synchronization** - Faster writes in test scenarios
- **Reduced job intervals** - Quicker background job execution  
- **Shortened GC TTL** - Faster cleanup of deleted data
- **Disabled automatic stats** - Reduces background overhead

> ⚠️ **Note**: These optimizations prioritize speed over durability and are intended for testing only.

## Building from Source

```bash
# Clone the repository
git clone https://github.com/timveil-cockroach/cockroachdb-single-node.git
cd cockroachdb-single-node

# Build the image
docker build --no-cache -t cockroachdb-single-node:local .

# Run locally built image
docker run -d -p 8080:8080 -p 26257:26257 cockroachdb-single-node:local
```

## Architecture

The image consists of four key components:

- **Dockerfile** - Security-hardened container with health checks
- **init.sh** - Entry point script that configures and starts CockroachDB
- **optimizations.sql** - Performance tuning for test environments
- **logs.yaml** - Structured logging configuration

## Health Checks

The image includes built-in health checks that verify CockroachDB is responding:

```bash
# Check container health
docker ps --filter "health=healthy"

# Manual health check
docker exec <container_id> /cockroach/cockroach sql --insecure --execute="SELECT 1"
```

## Contributing

Contributions are welcome! Please see our [GitHub Actions workflows](.github/workflows/) for CI/CD processes.

## License

This project is licensed under the Apache License 2.0 - see the [CockroachDB license](https://github.com/cockroachdb/cockroach/blob/master/LICENSE) for details.