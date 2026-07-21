# SQL injection via string interpolation

Three instances of user-controlled input being directly interpolated into SQL queries.

`find_user` interpolates `email` into a SELECT query. An attacker can inject arbitrary SQL via the email parameter.

`create_order` interpolates both `user_id` and `item` into an INSERT query, then interpolates `user_id` again into a SELECT query. Both are vulnerable.

The fix is to use parameterized queries (`sqlx::query(...).bind(...)`) instead of `format!()`.
