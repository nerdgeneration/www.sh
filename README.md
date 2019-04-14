# www.sh
Web framework in Bash

**DO NOT USE THIS IN ANY PUBLIC FACING SERVER. THIS IS NOT SECURE. FOR EDUCATIONAL USE ONLY.**

Supports standard web framework functions:
- HTTP status
- HTTP headers
- HTTP response
- Routing
- Templated views
- Query and POST data in $_GET and $_POST
- URL encode/decode
- Path checks
- Sanitisation of HTML, SQL
- MySQL database queries
- .env files

NOTE (for macOS): If you're getting an error because of the `declare` command, then you need to run `brew install bash` to upgrade bash to version >= 4.0.

Not everything is tested. This should be considered non-functional, it just happens that most of it works. Check back later for tests etc...
