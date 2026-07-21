# Potential division by zero

If no items exceed the threshold, both `special_count` and `normal_count` will be zero, causing a division by zero on line 16. This is a latent bug that only manifests with certain inputs.

The function should handle this edge case explicitly.
