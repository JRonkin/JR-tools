folder="$1"
jiranum="$2"
repo="$3"
position="$4"
size="$5"

[ "$position" ] || position='279, 23'
[ "$size" ] || size='1331, 1027'

bounds="${position}, $(( ${position%,*} + ${size%,*} )), $(( ${position#*,} + ${size#*,} ))"

if [ "$repo" ]
then
  repoCmds="
    make new tab in new_window
    set the URL of the active tab of new_window to \"https://github.com/yext-pages/${repo}\"
    make new tab in new_window
    set the URL of the active tab of new_window to \"https://www.yext.com/pagesadmin/?query=$(echo "${repo//[Mm]aster[^A-Za-z0-9]}" | tr A-Z a-z)\"
  "
fi

osascript -e "
  tell app \"Google Chrome\"
    set new_window to (make new window)
    set the bounds of new_window to {${bounds}}
    set the URL of the 1st tab of new_window to \"https://yexttest.atlassian.net/browse/${jiranum}\"
    ${repoCmds}
    set the active tab index of new_window to 1
  end tell
" &
