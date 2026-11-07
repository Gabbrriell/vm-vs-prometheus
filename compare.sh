#!/usr/bin/env bash
# Snapshot of resource usage for Prometheus vs VictoriaMetrics.
# Run after the stack has been up for a while (30+ min is better).
set -u

echo "== Container CPU / memory (docker stats) =="
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" prometheus victoriametrics

echo
echo "== On-disk data size =="
echo -n "prometheus:      "; docker run --rm --volumes-from prometheus alpine du -sh /prometheus | cut -f1
echo -n "victoriametrics: "; docker run --rm --volumes-from victoriametrics alpine du -sh /storage | cut -f1

echo
echo "== Active series =="
echo -n "prometheus:      "; curl -s localhost:9090/api/v1/status/tsdb | grep -o '"numSeries":[0-9]*' | cut -d: -f2
echo -n "victoriametrics: "; curl -s localhost:8428/api/v1/series/count | grep -o '\[[0-9]*\]' | tr -d '[]'
