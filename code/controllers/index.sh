declare -A tmpl
tmpl['welcome']=$_GET['welcome']
tmpl['sw']="www.sh $WWWSH_VERSION"
tmpl['sw-url']="$WWWSH_URL"

printf "%s" "$(view index.html $tmpl)"