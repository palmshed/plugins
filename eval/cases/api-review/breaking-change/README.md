# Breaking change risk

The API functions have implicit contracts. If `calculate_total_with_tax` were modified to accept `discount_percent` as a second parameter before `tax_rate`, all existing callers would break silently since both are f64.

Consider using a struct for configuration parameters to make the API more resilient to change.
