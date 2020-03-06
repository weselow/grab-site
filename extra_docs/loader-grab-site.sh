#!/bin/bash
# Task Runner

JobsCounter=0
MY_PID=$$

# Functions start
function LoadSettings {
	if [[ -e "loader.ini" ]]; then
		echo '*** START setting variables ***'
		while read a b ; do
			if [[ "$a" == "MaxTasks" ]]; then MaxTasks="$b"; echo MaxTasks = $MaxTasks;  fi
			if [[ "$a" == "NotStartedDir" ]]; then NotStartedDir="$b"; echo NotStartedDir = $NotStartedDir;  fi
			if [[ "$a" == "InProgressDir" ]]; then InProgressDir="$b"; echo InProgressDir = $InProgressDir;  fi
			if [[ "$a" == "DoneDir" ]]; then DoneDir="$b"; echo DoneDir = $DoneDir; fi
			if [[ "$a" == "MyProcess" ]]; then MyProcess="$b"; echo MyProcess = $MyProcess;  fi
			if [[ "$a" == "RunScriptDir" ]]; then RunScriptDir="$b"; echo RunScriptDir = $RunScriptDir;  fi
			if [[ "$a" == "LogDir" ]]; then LogDir="$b"; echo LogDir = $LogDir; fi
		done < loader.ini
		echo '*** END setting variables***'
	fi
}
# Functions end

LoadSettings
sleep 10
echo

# проверяем наличие директорий
echo [LOADER] Checking directories ...
if ! [ -d "$NotStartedDir" ]; then mkdir $NotStartedDir; fi
if ! [ -d "$InProgressDir" ]; then mkdir $InProgressDir; fi
if ! [ -d "$DoneDir" ]; then mkdir $DoneDir; fi
if ! [ -d "$LogDir" ]; then mkdir $LogDir; fi

# run gs-server
if [ -z "$(ps -ela | grep gs-server)" ]
	then
		echo [LOADER] Running gs-server ...
		gs-server 2>>$LogDir/gs-server-errors.log >>$LogDir/gs-server.log &
	else
		echo [LOADER] GS-server already running, skipping...
fi

# run free disk checker
if [ -z "$(ps -ela | grep pause_resume)" ]
	then
		echo [LOADER] Running pause_resume_grab_sites.sh ...
		/home/viking01/pause_resume_grab_sites.sh &
	else
		echo [LOADER] Script pause_resume_grab_sites.sh already running, skipping...
fi

sleep 5

echo

for i in $(find $NotStartedDir -name '*.txt')
	do
		echo "Find $(find $NotStartedDir -name '*.txt' | wc -l) tasks ..."
		echo "... taking task: $i"
		sleep 3

		if [ -e $i ]; then
			# if file exists
			if [ -s $i ]; then
				# File contains data
				# echo "File $i contains data"
				domainid=$(cat $i | awk -F':' '{print $1}')
				domain=$(cat $i | awk -F':' '{print $2}' | tr -d '\n' | tr -d '\r')

				# Count background tasks
				# JobsCounter=$((`ps ax -Ao ppid | grep $MY_PID | wc -l`))
				JobsCounter=$(ps -ela | grep $MyProcess | wc -l)
				LoadSettings > /dev/null

				while [ $JobsCounter -ge $MaxTasks ]
				do
					# JobsCounter=$(ps ax -Ao ppid | grep $MY_PID | wc -l)
					JobsCounter=$(ps -ela | grep $MyProcess | wc -l)
					echo Wpull jobs counter: $JobsCounter
					sleep 3
				done

				# run task
				echo "Running domain: $domain"
				$RunScriptDir/run-grab-site.sh $domain $domainid $i &
			else
				# file is empty
				echo && echo "[ERROR] File $i is empty." && echo
			fi
		else
			# file ot found
			echo && echo "[ERROR] File not fond: $i" && echo
		fi
done

