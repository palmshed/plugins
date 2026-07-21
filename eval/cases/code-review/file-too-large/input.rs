pub fn calculate_metrics(data: &[Record]) -> Metrics {
    let mut total = 0.0;
    let mut count = 0;
    let mut min = f64::MAX;
    let mut max = f64::MIN;
    let mut sum_squared = 0.0;
    let mut categories: Vec<String> = Vec::new();
    let mut seen_categories: Vec<String> = Vec::new();
    let mut timestamp = String::new();
    let mut metadata = std::collections::HashMap::new();

    for record in data {
        total += record.value;
        count += 1;
        if record.value < min { min = record.value; }
        if record.value > max { max = record.value; }
        sum_squared += record.value * record.value;
        if !seen_categories.contains(&record.category) {
            categories.push(record.category.clone());
            seen_categories.push(record.category.clone());
        }
        timestamp = record.timestamp.clone();
        metadata.insert(record.id.to_string(), record.value.to_string());
    }

    let mean = total / count as f64;
    let variance = sum_squared / count as f64 - mean * mean;

    Metrics {
        total,
        count,
        min,
        max,
        mean,
        variance,
        categories,
        timestamp,
        metadata,
    }
}
