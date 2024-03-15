#!/bin/bash

# Bronze bucket destination file name
export DEST_FILE=$(date +%Y%m%d-%H%M).csv

# Run end-to-end
meltano run --full-refresh e2e

