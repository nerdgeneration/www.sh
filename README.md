# www.sh

Web framework in Bash

**DO NOT USE THIS IN ANY PUBLIC FACING SERVER. THIS IS NOT SECURE. FOR EDUCATIONAL USE ONLY.**

Supports standard web framework functions:

-   HTTP status
-   HTTP headers
-   HTTP response
-   Routing
-   Templated views
-   Query and POST data in $_GET and $\_POST
-   URL encode/decode
-   Path checks
-   Sanitisation of HTML, SQL
-   MySQL database queries
-   .env files

### Requirements:

-   Bash 4.3 (**Mac OS X users will need to upgrade using `brew install bash`**)
-   CGI compatible web-server (Apache [mod_cgi](http://httpd.apache.org/docs/current/mod/mod_cgi.html); nginx [fcgiwrap](https://www.nginx.com/resources/wiki/start/topics/examples/fcgiwrap/); [http.sh](https://github.com/nerdgeneration/http.sh))

### Status:

Fully Tested: Nothing.

Partially Tested: Docker, CGI integration, GET, POST, Controllers, http_serve, http_header, http_status, route, view, url_decode

Not Tested: Everything else.
