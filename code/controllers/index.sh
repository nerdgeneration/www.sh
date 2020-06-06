# shellcheck shell=bash

tmpl['welcome']=${_GET['welcome']}
tmpl['sw-ver']="www.sh $WWWSH_VERSION"
tmpl['sw-url']="$WWWSH_URL"

printf "%s" "$(view index.html)"