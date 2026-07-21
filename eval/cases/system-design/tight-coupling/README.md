# Tight coupling

UserService directly manages database, cache, email, logging, and configuration. This makes it hard to test, modify, or replace any individual concern without affecting the others.

Consider separating into dedicated services: CacheService, NotificationService, etc. and having UserService orchestrate them through a simpler interface.
