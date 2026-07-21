use sqlx::PgPool;

pub async fn get_users_with_orders(pool: &PgPool) -> Result<Vec<UserWithOrders>, sqlx::Error> {
    let users = sqlx::query_as::<_, User>("SELECT id, name FROM users")
        .fetch_all(pool)
        .await?;

    let mut result = Vec::new();
    for user in &users {
        let orders = sqlx::query_as::<_, Order>(
            "SELECT id, total FROM orders WHERE user_id = $1"
        )
        .bind(user.id)
        .fetch_all(pool)
        .await?;

        result.push(UserWithOrders {
            user: user.clone(),
            orders,
        });
    }

    Ok(result)
}
