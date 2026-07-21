# code-review: examples

Golden examples demonstrating what this skill flags and approves.

## Good: Clear abstraction with single responsibility

```rust
// config.rs
pub struct AppConfig {
    pub database: DatabaseConfig,
    pub server: ServerConfig,
}

pub struct DatabaseConfig {
    pub url: String,
    pub pool_size: u32,
}

pub struct ServerConfig {
    pub host: String,
    pub port: u16,
}

impl AppConfig {
    pub fn from_env() -> Result<Self, ConfigError> {
        Ok(Self {
            database: DatabaseConfig {
                url: env_required("DATABASE_URL")?,
                pool_size: env_optional("DB_POOL_SIZE", 10)?,
            },
            server: ServerConfig {
                host: env_optional("HOST", "127.0.0.1")?,
                port: env_optional("PORT", 8080)?,
            },
        })
    }
}
```

**Why this is good:**
- Each struct has a clear, single responsibility
- Config loading is centralized in one place
- Types make the shape of the data explicit
- Easy to test, extend, and reason about

---

## Bad: Feature logic leaking into shared path

```rust
// handler.rs ~ shared request handler
pub async fn handle_request(req: Request) -> Response {
    let user = authenticate(&req).await?;

    // Feature-specific logic scattered into the shared handler
    if req.path().starts_with("/admin") {
        let role = get_user_role(user.id).await?;
        if role != "admin" {
            return Response::forbidden();
        }
    }

    // More feature-specific checks bolted on
    if req.headers().contains("X-Beta-Feature") {
        let beta = check_beta_access(user.id).await?;
        if !beta {
            return Response::forbidden();
        }
    }

    // ... rest of handler
}
```

**Why this is bad:**
- Admin authorization logic belongs in its own middleware or guard
- Beta feature check is unrelated to the core handler flow
- Adding more feature checks makes this handler increasingly tangled
- Each new feature adds another conditional to an already busy function

**Better:** Extract admin guard and beta guard into separate middleware. The handler stays focused on request routing.

---

## Bad: File past 1k lines from new code

```rust
// service.rs ~ was 900 lines, now 1200 after this PR
// The PR adds a new "export" feature that duplicates
// patterns already used for "import" and "sync" features.

pub async fn export_users(config: &Config) -> Result<Vec<User>> {
    // 80 lines of export logic that mirrors import logic
}

pub async fn export_orders(config: &Config) -> Result<Vec<Order>> {
    // 80 lines of export logic that mirrors import logic
}

pub async fn export_products(config: &Config) -> Result<Vec<Product>> {
    // 80 lines of export logic that mirrors import logic
}
```

**Why this is bad:**
- Three near-duplicate functions that differ only in the type they operate on
- Pushes the file well past 1k lines
- The duplication signals a missing generic abstraction

**Better:** Extract a generic `export_entities` helper or use a trait-based approach. Delete the duplication.

---

## Good: Direct, boring implementation

```rust
pub fn parse_address(input: &str) -> Result<Address, ParseError> {
    let parts: Vec<&str> = input.splitn(3, ',').collect();
    if parts.len() < 3 {
        return Err(ParseError::MissingFields);
    }

    Ok(Address {
        street: parts[0].trim().to_string(),
        city: parts[1].trim().to_string(),
        state: parts[2].trim().to_string(),
    })
}
```

**Why this is good:**
- Direct, readable, no indirection
- Error case is handled explicitly
- No magic, no generics, no abstractions beyond what is needed
- Easy to understand and modify

---

## Bad: Magic abstraction that hides simple logic

```rust
pub trait Processor {
    fn process(&self, item: &dyn Any) -> Result<Box<dyn Any>>;
}

pub struct AddressProcessor;
impl Processor for AddressProcessor {
    fn process(&self, item: &dyn Any) -> Result<Box<dyn Any>> {
        let input = item.downcast_ref::<String>().ok_or(Error::TypeMismatch)?;
        let address = parse_address(input)?;
        Ok(Box::new(address))
    }
}

// Used as:
let result = processor.process(&raw_input)?;
let address = result.downcast_ref::<Address>().unwrap();
```

**Why this is bad:**
- `Any` type erasure hides the real contract
- Caller must downcast ~ runtime failure instead of compile-time safety
- The abstraction adds indirection without clarifying intent
- A simple function `parse_address(input: &str) -> Result<Address>` would be clearer

**Better:** Replace with a direct function call. The trait adds nothing here.
