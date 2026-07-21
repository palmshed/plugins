# Missing error handling and logging

The process_request function doesn't handle errors from fetch_data. If the fetch fails, the function will panic or propagate an unhelpful error.

Also, timing is printed to stdout instead of using a proper logging framework, making it hard to correlate in production.
