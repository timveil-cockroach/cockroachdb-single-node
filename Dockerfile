FROM cockroachdb/cockroach:latest

LABEL maintainer="tjveil@gmail.com" \
      org.opencontainers.image.source="https://github.com/timveil/cockroachdb-single-node" \
      org.opencontainers.image.description="Single-node CockroachDB for CI/CD and testing" \
      org.opencontainers.image.licenses="Apache-2.0"

# Ensure the directory exists
RUN mkdir -p /cockroach && chown -R 1000:1000 /cockroach

# Copy files with appropriate ownership for the cockroach user (UID 1000)
COPY --chown=1000:1000 --chmod=755 init.sh /cockroach/
COPY --chown=1000:1000 logs.yaml optimizations.sql /cockroach/

# Ensure we're using the non-root user from the base image
USER 1000

WORKDIR /cockroach/

EXPOSE 8080 26257

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD /cockroach/cockroach sql --insecure --execute="SELECT 1" || exit 1

ENTRYPOINT ["/cockroach/init.sh"]