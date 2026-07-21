pub fn calculate_total(items: &[Item]) -> f64 {
    items.iter().map(|i| i.price * i.quantity).sum()
}

pub fn calculate_total_with_tax(items: &[Item], tax_rate: f64) -> f64 {
    let subtotal = calculate_total(items);
    subtotal * (1.0 + tax_rate)
}

pub fn calculate_discount(total: f64, discount_percent: f64) -> f64 {
    total * (1.0 - discount_percent / 100.0)
}
