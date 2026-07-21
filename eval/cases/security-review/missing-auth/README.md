# Missing authentication checks

Three endpoints with no authentication or authorization checks.

`delete_document` performs a destructive operation (delete) without verifying who is making the request. Any unauthenticated user can delete any document.

`update_settings` modifies application state without authentication. Any user can change system settings.

`export_data` exposes all data without authentication. Any user can export the entire dataset.

Each endpoint should verify authentication before performing the operation.
