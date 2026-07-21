pub fn parse_config(input: &str) -> Result<Config, ConfigError> {
    let lines: Vec<&str> = input.lines().collect();
    let mut config = Config::default();
    
    for line in lines {
        let parts: Vec<&str> = line.splitn(2, '=').collect();
        if parts.len() != 2 {
            return Err(ConfigError::InvalidFormat);
        }
        match parts[0].trim() {
            "timeout" => config.timeout = parts[1].trim().parse().map_err(|_| ConfigError::InvalidValue)?,
            "retries" => config.retries = parts[1].trim().parse().map_err(|_| ConfigError::InvalidValue)?,
            _ => return Err(ConfigError::UnknownKey),
        }
    }
    Ok(config)
}

pub fn validate_email(email: &str) -> bool {
    email.contains('@') && email.contains('.')
}

pub fn calculate_hash(data: &[u8]) -> u64 {
    data.iter().fold(0u64, |acc, &b| acc.wrapping_mul(31).wrapping_add(b as u64))
}
