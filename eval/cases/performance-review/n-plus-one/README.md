# N+1 query pattern

`get_users_with_orders` fetches all users in one query, then issues a separate query for each user's orders. With 1000 users, this makes 1001 database round trips.

Fix: use a JOIN query or batch the order fetches.
