FROM cockroachdb/cockroach:latest

LABEL maintainer="tjveil@gmail.com" \
      org.opencontainers.image.source="https://github.com/timveil/cockroachdb-single-node" \
      org.opencontainers.image.description="Single-node CockroachDB for CI/CD and testing" \
      org.opencontainers.image.licenses="Apache-2.0"

COPY --chmod=755 init.sh /cockroach/
COPY logs.yaml optimizations.sql /cockroach/

WORKDIR /cockroach/

EXPOSE 8080 26257

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD /cockroach/cockroach sql --insecure --execute="SELECT 1" || exit 1

ENTRYPOINT ["/cockroach/init.sh"]