pub async fn process_request(req: Request) -> Response {
    let start = std::time::Instant::now();
    
    let data = fetch_data(&req.url).await;
    let parsed = parse_response(data);
    let result = transform(parsed);
    
    let elapsed = start.elapsed();
    println!("Request processed in {:?}", elapsed);
    
    Response::from(result)
}
