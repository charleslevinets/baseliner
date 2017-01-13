#!/bin/bash
set -ex

echo "machine,tasks,benchmark,test,result" > results/all.csv

# stress-ng
docker run \
  --rm \
  --volume `pwd`/results/benchmark/stressng-cpu:/data \
  ivotron/json-to-tabular:v0.2 \
    --jqexp '. | .metrics | .[] | ["stressng-cpu", .stressor, ."bogo-ops-per-second-real-time"]' \
    ./ >> results/all.csv
docker run \
  --rm \
  --volume `pwd`/results/benchmark/stressng-cpucache:/data \
  ivotron/json-to-tabular:v0.2 \
    --jqexp '. | .metrics | .[] | ["stressng-cpucache", .stressor, ."bogo-ops-per-second-real-time"]' \
    ./ >> results/all.csv
docker run \
  --rm \
  --volume `pwd`/results/benchmark/stressng-mem:/data \
  ivotron/json-to-tabular:v0.2 \
    --jqexp '. | .metrics | .[] | ["stressng-mem", .stressor, ."bogo-ops-per-second-real-time"]' \
    ./ >> results/all.csv

# fio
docker run \
  --rm \
  --volume `pwd`/results/benchmark/`ls results/benchmark/ | grep fio`:/data \
  ivotron/json-to-tabular:v0.2 \
    --jqexp '. | .jobs | .[] | ["1", "fio-read", .jobname, .read.iops]' \
    ./ >> results/all.csv
docker run \
  --rm \
  --volume `pwd`/results/benchmark/`ls results/benchmark/ | grep fio`:/data \
  ivotron/json-to-tabular:v0.2 \
    --jqexp '. | .jobs | .[] | ["1", "fio-write", .jobname, .write.iops]' \
    ./ >> results/all.csv

# conceptual
for f in $(find `pwd`/results/benchmark/$(ls results/benchmark/ | grep conceptual) -type f) ; do
  docker run \
    --rm \
    -v `pwd`/results:/data \
    -v "$f":"$f" \
    --entrypoint=ncptl-logextract \
    ivotron/conceptual:v1.5.1 \
      --extract=data "$f" \
      --noheaders \
      --rowbegin=bytes- \
      --output=/data/conceptual-results.csv
  sed -i -s 's/\(.*\)/oneforall,1,conceptual,\1/' results/conceptual-results.csv
  cat results/conceptual-results.csv >> results/all.csv
  rm results/conceptual-results.csv
done
