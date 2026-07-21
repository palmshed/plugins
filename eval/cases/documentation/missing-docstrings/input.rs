pub fn process_data(input: &[u8]) -> Vec<u8> {
    input.iter().map(|b| b.wrapping_add(1)).collect()
}

pub struct Config {
    pub timeout: u32,
    pub retries: u8,
    pub base_url: String,
}

pub fn connect(config: &Config) -> Result<Connection, Error> {
    todo!()
}
