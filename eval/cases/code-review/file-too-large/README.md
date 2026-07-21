# Function with too many responsibilities

`calculate_metrics` computes statistics, collects categories, tracks timestamps, and builds a metadata map. It mixes computation, collection, and organization in a single function.

This should be decomposed into smaller functions: one for computing statistics, one for collecting categories, and one for building metadata.
