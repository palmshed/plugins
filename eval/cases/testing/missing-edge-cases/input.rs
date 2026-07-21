#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_valid_config() {
        let input = "timeout=30\nretries=3";
        let config = parse_config(input).unwrap();
        assert_eq!(config.timeout, 30);
        assert_eq!(config.retries, 3);
    }
}
