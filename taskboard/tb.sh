osascript -e 'tell app "Terminal" to set custom title of front window to "TaskBoard"'

source taskswap.sh

tasks=()
selected=0
active=-1

while :
do
	clear
	printf "\
=============================================================
| Q: Quit TaskBoard | N: New Task       | X: Close Selected |
| [Enter]: Activate/Deactivate Selected                     |
|-----------------------------------------------------------|
"
for ((i = 0; i < ${#tasks[@]}; i++))
do
	if [ $selected = $i ]; then s=">"; else s=" "; fi
	if [ $active = $i ]; then a="*"; else a=" "; fi
	printf "\
| $s$a%s |
" "$(echo "${tasks[i]}                                                       " | sed "s/\(.\{55\}\).*/\1/")"
done
	printf "\
============================================================
"

	read -n 1 input
	case "$( echo $input | tr a-z A-Z )" in

		"Q" )
			clear
			break
			;;

		"N" )
			clear
			read -p "GitHub URL: " giturl
			if [[ "$giturl" =~ .*github\.com\/[^/]+\/([^/]+).* ]]
			then
				repo=${BASH_REMATCH[1]}
			else
				printf "Invalid URL:\n$giturl\n\n> Return to TaskBoard"
				read -n 1
				continue
			fi
			read -p "JIRA URL: " jiraurl
			if [[ "$jiraurl" =~ .*yexttest\.atlassian\.net\/browse\/([^/]+).* ]]
			then
				jiranum=${BASH_REMATCH[1]}
			else
				printf "Invalid URL:\n$jiraurl\n\n> Return to TaskBoard"
				read -n 1
				continue
			fi				
			new "$repo" "$jiranum"
			selected=${#tasks[*]}
			tasks[${#tasks[*]}]="$jiranum   $repo"
			if [ $active -gt -1 ]
			then
				deactivate "${tasks[$active]}"
			fi
			active=$selected
			;;

		"X" )
			close "${tasks[selected]}"
			tasks=("${tasks[@]:0:$selected}" "${tasks[@]:$(( $selected + 1 )):${#tasks[*]}}")
			if [ $active = $selected ]
			then
				active=-1
			else
				if [ $active -gt $selected ]
				then
					(( --active ))
				fi
			fi
			if [ $selected = ${#tasks[*]} ]; then (( --selected )); fi
			;;

		"" )
			read -n 2 -t 1 input2
			case $input2 in
				"[A" )
					if [ $selected -gt 0 ]
					then
						(( --selected ))
					else
						selected=$(( ${#tasks[*]} - 1 ))
					fi
					;;
				"[B" )
					if [ $selected -lt $(( ${#tasks[*]} - 1 )) ]
					then
						(( ++selected ))
					else
						selected=0
					fi
					;;
			esac
			;;

		"" )
			if [ $active -gt -1 ]
			then
				deactivate "${tasks[$active]}"
			fi
			if [ $selected = $active ]
			then
				active=-1
			else
				activate "${tasks[$selected]}"
				active=$selected
			fi
			;;

	esac
done