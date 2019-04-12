# bash library, use "source"

# www.sh - the experimental bash web framework
#
# Copyright Mark Griffin 2019 (BSD-3 License)
# http://nerdgeneration.com/www.sh/
#
# Let's be absolutely clear: this is a joke project. DO NOT USE THIS FOR
# ANYTHING, ESPECIALLY ON A PUBLIC FACING SERVER.
#
# This is the main library that exposes various "web framework" like
# functions:
#   - HTTP status
#   - HTTP headers
#   - HTTP response
#   - Routing
#   - Templated views
#   - Pre-filled $_GET and $_POST data
#
# This also supports:
#   - URL encode/decode
#   - Path checks
#   - Sanitisation of HTML, SQL
#   - MySQL database queries
#
# Not everything is tested. This should be considered non-functional,
# it just happens that most of it works. Check back later for tests etc...

WWWSH_VERSION='0.2-alpha'
WWWSH_URL='http://www.nerdgeneration.com/wwwsh/'

# Some notes:
# - The aim is to use native bash as much as possible
# - printf is more secure than echo because you can't tell echo to stop processing parameters

# Make bash intolerant of errors
set -ef -o pipefail

url_decode() {
    local data="${*//+/ }"
    printf '%b' "${data//%/\\x}"
}

url_encode() {
    # Modified from https://gist.github.com/cdown/1163649
    old_lc_collate="$LC_COLLATE"
    LC_COLLATE="C"
    
    local length="${#1}"
    for (( pos = 0; pos < length; pos++ )); do
        local chr="${1:pos:1}"
        case "$chr" in
            ' ')
                printf '+'
                ;;
            [a-zA-Z0-9.~_-])
                printf "%s" "$chr"
                ;;
            *)
                printf '%%%02X' "'$chr"
                ;;
        esac
    done
    
    LC_COLLATE="$old_lc_collate"
}

html() {
    local str="$1"
    str="${str//</&lt;}"
    str="${str//>/&gt;}"
    str="${str//\"/&quot;}"
    printf "%s" "$str"
}

sql() {
    printf "0x"
    printf "%s" "$1" | xxd -p | tr -d '\n'
}

query() {
    mysql -u "${_ENV['DB_USER']}" -p <(echo "${_ENV['DB_PASS']}") --database="${_ENV['DB_DATABASE']}" --silent --raw <<<"$1" \
        | tail -n +2
}

view() {
    local view="$1"
    local -n tmpl=$2
    local template="$(<"../code/views/$view")"
    
    for name in ${!tmpl}; do
        local find="{{$find}}"
        local replace="${tmpl[$name]}"
        template="${template/$find/$replace}"
    done
    
    printf "%s" "$template"
}

path_in() {
    local check="$(realpath --canonicalize-existing --quiet "./$1")"
    local in="$(realpath --canonicalize-existing --quiet "./$2")"
    local in_length="${#in}"
    [[ "${check:1:in_length}" == "$in" ]] && print "%s" "$check"
}

path_in_www() {
    path_in "$1" "$DOCUMENT_ROOT/www"
}

declare -A routes
route() {
    routes["$1"]="$2"
}

http_status_code="200 OK"
http_status() {
    http_status_code="$1"
}

declare -A http_headers
http_header() {
    http_headers["$1"]="$2"
}

http_serve() {
    http_header "Content-Type" "text/html;charset=utf-8"
    http_header "X-Server" "www.sh/$WWWSH_VERSION ($WWWSH_URL)"

    # Find route, source controller, capture output
    [[ "$SCRIPT_NAME" == "" ]] && SCRIPT_NAME="/"
    if [[ ! -z ${routes[$SCRIPT_NAME]} ]]; then
        local controller="${routes[$SCRIPT_NAME]}"
        content="$(source "../code/controllers/$controller.sh")"
    else
        http_status "404 Not Found"
        content="Not Found"
    fi
    
    # Output headers
    printf "HTTP/1.0 %s\r\n" "$http_status_code"
    for name in "${!http_headers[@]}"; do 
        printf "%s: %s\r\n" "$name" "${http_headers[$name]}"; 
    done
    
    printf "\r\n%s\n" "$content"
}

http_error() {
    printf "HTTP/1.0 500 Internal Server Error\r\n\r\nInternal Server Error"
    exit 1
}

# Parse the query into $_GET
IFS='&;' read -a query <<< "$QUERY_STRING"
declare -A _GET
for name_value_str in "${query[@]}"; do
    IFS='=' read -a name_value <<< "$name_value_str"
    name="$(url_decode "${name_value[0]}")"
    value="$(url_decode "${name_value[1]}")"
    _GET["$name"]="$value"
done

# Parse the POST into $_POST
IFS='&;' read -a query
declare -A _POST
for name_value_str in "${query[@]}"; do
    IFS='=' read -a name_value <<< "$name_value_str"
    name="$(url_decode "${name_value[0]}")"
    value="$(url_decode "${name_value[1]}")"
    _POST["$name"]="$value"
done

# Read the .env file
declare -A _ENV
[[ -f ../.env ]] && source ../.env
