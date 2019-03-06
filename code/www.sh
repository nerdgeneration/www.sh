# www.sh - Copyright Mark Griffin 2019
# Please don't actually use this for anything, that would be stupid.

WWWSH_VERSION='0.1-alpha'
WWWSH_URL='http://www.nerdgeneration.com/wwwsh/'

# Some notes:
# - The aim is to use native bash as much as possible
# - printf is more secure than echo because you can't tell echo to stop processing parameters


# Make bash intolerant of errors
set -ef -o pipefail

url_decode() {
    local data="${*//+/ }"   # + to space
    echo -e "${data//%/\\x}" # %xx to ascii
    # or: printf '%b' "${1//%/\\x}"
}

url_encode() {
    # Modified from https://gist.github.com/cdown/1163649
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C
    
    local length="${#1}"
    for (( pos = 0; pos < length; pos++ )); do
        local chr="${1:pos:1}"
        case $chr in
            ' ') printf '+' ;;
            [a-zA-Z0-9.~_-]) printf "%s" "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
    
    LC_COLLATE=$old_lc_collate
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
   # TODO Load code/views/$1 and do template expansion somehow
   return
}

path() {
    local check="$(realpath -e "./$1")"
    # TODO Clean $1 and ensure it exists in $DOCUMENT_ROOT
    return
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
        # TODO Finish this for local file serving too
        # local filename="$(realpath --canonicalize-existing --quiet "./$SCRIPT_NAME")"
        # [[ $? == 0 && ... check the filename is in $DOCUMENT_ROOT ]] && send the file
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


# Parse the query into $_GET
IFS='&;' read -a query <<< "$QUERY_STRING"
declare -A _GET
for name_value_str in "${query[@]}"; do
    IFS='=' read -a name_value <<< "$name_value_str"
    name="$(url_decode "${name_value[0]}")"
    value="$(url_decode "${name_value[1]}")"
    _GET["$name"]="$value"
done

# TODO read in a sourced script seems to break everything
# Parse the POST into $_POST
#IFS='&;' read -a query
#declare -A _POST
#for name_value_str in "${query[@]}"; do
#    IFS='=' read -a name_value <<< "$name_value_str"
#    name="$(url_decode "${name_value[0]}")"
#    value="$(url_decode "${name_value[1]}")"
#    _POST["$name"]="$value"
#done

# Read the .env file
declare -A _ENV
[[ -f ../.env ]] && source ../.env
