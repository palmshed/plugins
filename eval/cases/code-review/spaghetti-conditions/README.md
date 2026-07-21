# Spaghetti conditions

Five levels of nested if-statements in `process_user`. The logic determines a status string based on user properties, but the nesting makes it hard to follow, test, and extend.

A flatter approach would use early returns or a lookup table to reduce nesting depth.
