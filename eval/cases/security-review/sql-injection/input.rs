use sqlx::PgPool;

pub async fn find_user(pool: &PgPool, email: &str) -> Result<User, sqlx::Error> {
    let query = format!(
        "SELECT id, name, email FROM users WHERE email = '{}'",
        email
    );
    let user = sqlx::query_as::<_, User>(&query)
        .fetch_one(pool)
        .await?;
    Ok(user)
}

pub async fn create_order(pool: &PgPool, user_id: i64, item: &str) -> Result<Order, sqlx::Error> {
    let query = format!(
        "INSERT INTO orders (user_id, item) VALUES ({}, '{}')",
        user_id, item
    );
    sqlx::query(&query).execute(pool).await?;
    let order = sqlx::query_as::<_, Order>(
        &format!("SELECT id, user_id, item FROM orders WHERE user_id = {}", user_id)
    )
    .fetch_one(pool)
    .await?;
    Ok(order)
}
