# performance-review: examples

Golden examples demonstrating what this skill flags and approves.

## Good: Single-pass with hash lookup

```rust
use std::collections::HashSet;

fn find_missing(users: &[User], active_ids: &HashSet<Uuid>) -> Vec<&User> {
    users.iter()
        .filter(|u| !active_ids.contains(&u.id))
        .collect()
}
```

**Why this is good:**
- O(n) time complexity
- HashSet lookup is O(1)
- No nested loops, no repeated work
- Clear intent: find users not in the active set

---

## Bad: N+1 query pattern

```rust
pub async fn get_users_with_orders(db: &Pool) -> Result<Vec<UserWithOrders>> {
    let users = sqlx::query_as!(User, "SELECT id, name FROM users")
        .fetch_all(db)
        .await?;

    let mut result = Vec::new();
    for user in &users {
        // N+1: one query per user
        let orders = sqlx::query_as!(
            Order,
            "SELECT id, total FROM orders WHERE user_id = $1",
            user.id
        )
        .fetch_all(db)
        .await?;

        result.push(UserWithOrders {
            user: user.clone(),
            orders,
        });
    }

    Ok(result)
}
```

**Why this is bad:**
- 1 query for users + N queries for orders = N+1 total queries
- With 1000 users, this makes 1001 database round trips
- Latency scales linearly with user count

**Better:** Use a JOIN or a single query with a grouping:

```rust
let rows = sqlx::query!(
    "SELECT u.id, u.name, o.id as order_id, o.total
     FROM users u
     LEFT JOIN orders o ON o.user_id = u.id"
)
.fetch_all(db)
.await?;
// Group into UserWithOrders in application code
```

---

## Good: Streaming large file

```rust
use tokio::io::AsyncBufReadExt;

pub async fn count_lines(path: &Path) -> Result<usize> {
    let file = File::open(path).await?;
    let reader = BufReader::new(file);
    let mut lines = reader.lines();
    let mut count = 0;

    while let Some(_) = lines.next_line().await? {
        count += 1;
    }

    Ok(count)
}
```

**Why this is good:**
- Streams the file line by line
- Memory usage is constant regardless of file size
- Works for files of any size

---

## Bad: Reading entire file into memory

```rust
pub async fn count_lines(path: &Path) -> Result<usize> {
    let contents = tokio::fs::read_to_string(path).await?;
    let count = contents.lines().count();
    Ok(count)
}
```

**Why this is bad:**
- Reads the entire file into memory as a String
- A 4GB file requires 4GB of RAM
- Will cause OOM on large files
- The streaming approach uses constant memory

---

## Good: Batched database inserts

```rust
pub async fn insert_events(db: &Pool, events: &[Event]) -> Result<()> {
    for chunk in events.chunks(100) {
        sqlx::query("INSERT INTO events (id, type, payload) VALUES ($1, $2, $3)")
            .bind(chunk.iter().map(|e| e.id).collect::<Vec<_>>())
            .bind(chunk.iter().map(|e| &e.r#type).collect::<Vec<_>>())
            .bind(chunk.iter().map(|e| &e.payload).collect::<Vec<_>>())
            .execute(db)
            .await?;
    }
    Ok(())
}
```

**Why this is good:**
- Batches inserts into groups of 100
- Reduces round trips from N to N/100
- Balances memory usage with throughput

---

## Bad: One insert per event

```rust
pub async fn insert_events(db: &Pool, events: &[Event]) -> Result<()> {
    for event in events {
        sqlx::query("INSERT INTO events (id, type, payload) VALUES ($1, $2, $3)")
            .bind(event.id)
            .bind(&event.r#type)
            .bind(&event.payload)
            .execute(db)
            .await?;
    }
    Ok(())
}
```

**Why this is bad:**
- One database round trip per event
- 1000 events = 1000 network round trips
- Latency is dominated by network overhead

---

## Good: Cached expensive computation

```rust
use std::sync::OnceLock;

fn tax_rate() -> &'static Decimal {
    static RATE: OnceLock<Decimal> = OnceLock::new();
    RATE.get_or_init(|| {
        // Expensive: fetch from external tax service
        fetch_tax_rate_from_api().unwrap_or(Decimal::ZERO)
    })
}
```

**Why this is good:**
- Computed once, cached for the lifetime of the process
- Thread-safe via `OnceLock`
- Subsequent calls are free

---

## Bad: Repeated expensive computation

```rust
pub fn calculate_total(items: &[Item]) -> Decimal {
    let rate = fetch_tax_rate_from_api().unwrap(); // Called every time
    items.iter()
        .map(|i| i.price * rate)
        .sum()
}
```

**Why this is bad:**
- Makes an external API call on every invocation
- Network latency on every total calculation
- The tax rate does not change within a request
- Should be cached or passed in as a parameter
