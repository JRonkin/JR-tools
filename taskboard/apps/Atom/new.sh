folder="$1"
jiranum="$2"
repo="$3"
monitors="$4"
bounds="$5"

if [ ! "$bounds" ] 
then
  bounds='279, 23, 1610, 1050'
  [ $monitors -gt 1 ] && bounds='1920, 23, 3254, 1123'
fi

if [ "$repo" ]
then
  selector="window whose name contains \"/${jiranum}/${repo}\""

  atom "${folder}/${repo}" && sleep 2 &&
    osascript -e "
      tell app \"Atom\"
        set timer to 0
        repeat until the length of (get every ${selector}) > 0 or timer > 15
          delay 0.5
          set timer to timer + 0.5
        end repeat
        set the bounds of every ${selector} to {${bounds}}
      end tell
    " &
fi
