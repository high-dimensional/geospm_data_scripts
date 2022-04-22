#!/bin/bash



COMMAND_PATTERN="*commands.txt"

while [[ "$1" != "" ]] ; do

	study_path="$1"
	shift

	if [ ! -d "$study_path" ] ; then
		continue
	fi

	children="`find "\""$study_path"\"" -mindepth 1 -maxdepth 1 -type d`"
	collation_path="${study_path}/commands.txt"

        echo "Collating commands at '$collation_path'" 
	echo "${children[*]}"
	echo "---"

	rm "$collation_path" > /dev/null 2>&1 || true
	touch "$collation_path"

	if [ "$children" == "" ]; then
	  continue
	fi

	IFS=$'\n' sorted_children=($(sort <<<"${children[*]}"))
	unset IFS

	for i in "${!sorted_children[@]}"; do

	  child_path="${sorted_children[i]}"
          parent_name="`basename \"$child_path\"`"
      
          echo "Searching \"$parent_name\"..."
	    
	  command_path="`find "\""$child_path"\"" -mindepth 1 -maxdepth 1 -type f -iname "\""$COMMAND_PATTERN"\""`"
	    
	  if [ "$command_path" != "" ]; then
		
	    command_name="`basename "\""$command_path"\""`"
	    echo "   Found \"${command_name}\" in \"${parent_name}\"."
	    cat "$command_path" >> "$collation_path"
	    echo "   Appended to commands.txt"
	  fi
	    
	done
done
