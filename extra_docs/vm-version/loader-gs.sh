#!/bin/bash

FILE=sites.txt

# -----------------------------
# -- Run gs-server --
# -----------------------------

if [ -z "$(ps -ela | grep gs-server)" ]
	then
		echo "[LOADER] Running gs-server ..."
		gs-server 2>>$LogDir/gs-server-errors.log >>$LogDir/gs-server.log &
	else
		echo "[LOADER] gs-server server already running, skipping..."
fi


# -----------------------------
# -- Run NotStarted tasks --
# -----------------------------

while [[ true ]]; do

	for i in $(cat ${FILE})
		do
			echo "Find task: $i"
			sleep 3

			if [ -e $i ]; then
				# if file exists
				if [ -s $i ]; then
					# File contains data
					domainid=$(cat $i | awk -F':' '{print $1}')
					domain=$(cat $i | awk -F':' '{print $2}' | tr -d '\n' | tr -d '\r')

						# run task
						echo "Running domain: $domain"
						_run-task.sh ${domainid} ${domain} &
				else
					# file is empty
					echo && echo "[ERROR] File $i is empty." && echo
				fi
			else
				# file not found
				echo && echo "[ERROR] File not fond: $i" && echo
			fi
	done

echo "[LOADER] Waiting NotStarted tasks ... "
sleep 1m
done #while done
