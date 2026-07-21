use tokio::fs;

pub async fn process_file(path: &str) -> Result<String, std::io::Error> {
    let contents = fs::read_to_string(path).await?;
    let processed = contents.lines()
        .map(|line| line.trim())
        .filter(|line| !line.is_empty())
        .collect::<Vec<_>>()
        .join("\n");
    Ok(processed)
}

pub async fn read_config(path: &str) -> Result<Config, std::io::Error> {
    let contents = fs::read_to_string(path).await?;
    let config: Config = serde_json::from_str(&contents)?;
    Ok(config)
}
