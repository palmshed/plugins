# security-review: examples

Golden examples demonstrating what this skill flags and approves.

## Good: Parameterized query

```rust
pub async fn find_user(db: &Pool, email: &str) -> Result<User> {
    let user = sqlx::query_as!(
        User,
        "SELECT id, name, email FROM users WHERE email = $1",
        email
    )
    .fetch_one(db)
    .await?;

    Ok(user)
}
```

**Why this is good:**
- User input is passed as a parameter, not interpolated into the query
- SQL injection is not possible
- The query is clear and readable

---

## Bad: SQL injection via string interpolation

```rust
pub async fn find_user(db: &Pool, email: &str) -> Result<User> {
    let query = format!(
        "SELECT id, name, email FROM users WHERE email = '{}'",
        email
    );
    let user = sqlx::query_as::<_, User>(&query)
        .fetch_one(db)
        .await?;

    Ok(user)
}
```

**Why this is bad:**
- User input is directly interpolated into the SQL query
- An attacker can inject: `' OR '1'='1' --`
- This is a critical SQL injection vulnerability

**Better:** Use parameterized queries (see the good example above).

---

## Good: Explicit authorization check

```rust
pub async fn delete_document(
    user: &User,
    doc_id: Uuid,
    db: &Pool,
) -> Result<(), Error> {
    let doc = find_document(db, doc_id).await?;

    if doc.owner_id != user.id && !user.is_admin {
        return Err(Error::Forbidden);
    }

    delete_document_by_id(db, doc_id).await?;
    Ok(())
}
```

**Why this is good:**
- Authorization is checked before the destructive operation
- Both ownership and admin role are verified
- The check is explicit and easy to audit

---

## Bad: Missing authorization (IDOR)

```rust
pub async fn delete_document(
    doc_id: Uuid,
    db: &Pool,
) -> Result<(), Error> {
    delete_document_by_id(db, doc_id).await?;
    Ok(())
}
```

**Why this is bad:**
- No authentication check ~ who is making this request?
- No authorization check ~ does the user own this document?
- Any user can delete any document by guessing the UUID
- This is an Insecure Direct Object Reference (IDOR) vulnerability

---

## Good: Secrets not in source

```rust
pub fn load_config() -> Result<Config> {
    let api_key = std::env::var("API_KEY")
        .map_err(|_| Error::MissingConfig("API_KEY"))?;

    Ok(Config { api_key })
}
```

**Why this is good:**
- API key is loaded from environment variable
- Not hardcoded in source code
- Not logged or included in error messages

---

## Bad: Secret in source code

```rust
pub fn load_config() -> Config {
    Config {
        api_key: "sk-live-abc123def456".to_string(),
    }
}
```

**Why this is bad:**
- Secret is hardcoded in source code
- Visible to anyone with repository access
- Will be in git history forever even if removed later
- Should be in environment variables or a secrets manager

---

## Good: TLS verification enabled

```rust
let client = reqwest::Client::builder()
    .danger_accept_invalid_certs(false)
    .build()?;

let response = client.get("https://api.example.com/data")
    .send()
    .await?;
```

**Why this is good:**
- TLS certificate verification is explicitly enabled (the default)
- Man-in-the-middle attacks are prevented

---

## Bad: TLS verification disabled

```rust
let client = reqwest::Client::builder()
    .danger_accept_invalid_certs(true)
    .build()?;

let response = client.get("https://api.example.com/data")
    .send()
    .await?;
```

**Why this is bad:**
- TLS verification is disabled
- Man-in-the-middle attacks are possible
- An attacker can intercept and modify all traffic
- Should never be done in production code
