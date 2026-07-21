pub fn complex_calculation(input: &str) -> Result<Output, Error> {
    let parsed = parse(input)?;
    let mut result = Output::default();
    
    for item in parsed.items {
        if item.value > threshold() {
            if item.category == "special" {
                result.special_count += 1;
                result.special_sum += item.value;
            } else {
                result.normal_count += 1;
                result.normal_sum += item.value;
            }
        }
    }
    
    result.avg = (result.special_sum + result.normal_sum) / (result.special_count + result.normal_count) as f64;
    
    Ok(result)
}
