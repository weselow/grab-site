#!/bin/bash
# Task Runner
# v.1.0.3

JobsCounter=0
MY_PID=$$

# Functions start
function LoadSettings {
	if [[ -e "loader.ini" ]]; then
		echo '*** START setting variables ***'
		while read a b ; do
			if [[ "$a" == "MaxTasks" ]]; then MaxTasks="$b"; echo MaxTasks = $MaxTasks;  fi
			if [[ "$a" == "BaseDir" ]]; then
				BaseDir="$b"
				NotStartedDir="${BaseDir}/NotStarted"
				InProgressDir="${BaseDir}/InProgress"
				DoneDir="${BaseDir}/Done"
				LogDir="${BaseDir}/logs"
				echo "BaseDir = $BaseDir"
				echo "NotStartedDir = $NotStartedDir"
				echo "InProgressDir = $InProgressDir"
				echo "DoneDir = $DoneDir"
				echo "LogDir = $LogDir"
			fi

			if [[ "$a" == "CloudBaseDir" ]]; then CloudBaseDir="$b"; echo "CloudBaseDir = $CloudBaseDir";  fi

			#if [[ "$a" == "NotStartedDir" ]]; then NotStartedDir="$b"; echo NotStartedDir = $NotStartedDir;  fi
			#if [[ "$a" == "InProgressDir" ]]; then InProgressDir="$b"; echo InProgressDir = $InProgressDir;  fi
			#if [[ "$a" == "DoneDir" ]]; then DoneDir="$b"; echo DoneDir = $DoneDir; fi
			#if [[ "$a" == "LogDir" ]]; then LogDir="$b"; echo LogDir = $LogDir; fi
			if [[ "$a" == "MyProcess" ]]; then MyProcess="$b"; echo "MyProcess = $MyProcess";  fi
			if [[ "$a" == "RunScriptDir" ]]; then RunScriptDir="$b"; echo "RunScriptDir = $RunScriptDir";  fi
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
		echo "[LOADER] Running gs-server ..."
		gs-server 2>>$LogDir/gs-server-errors.log >>$LogDir/gs-server.log &
	else
		echo "[LOADER] GS-server already running, skipping..."
fi

# run free disk checker
if [ -z "$(ps -ela | grep pause_resume)" ]
	then
		echo "[LOADER] Running pause_resume_grab_sites.sh ..."
		/home/viking01/pause_resume_grab_sites.sh &
	else
		echo "[LOADER] Script pause_resume_grab_sites.sh already running, skipping..."
fi

sleep 5

echo


# Resume InProgress tasks
InProgressTasks=$(find $InProgressDir -name '*.txt')
if [ -z "$(ps -ela | grep run-grab)" ]; then
	#statements
	echo "[LOADER] Looks like it is first run, resuming all InProgress tasks ... "
	for i in $InProgressTasks; do
		#statements
		domainid=$(cat $i | awk -F':' '{print $1}')
		domain=$(cat $i | awk -F':' '{print $2}' | tr -d '\n' | tr -d '\r')
		echo "... resuming $domain ..."
		$RunScriptDir/run-grab-site.sh $domain $domainid $i &
		sleep 3
	done
	echo "... all InProgress tasks resumed!" && echo
else
	echo "[LOADER] Looks like it is not first run, skipping resuming ... "
fi
sleep 3

# Run NotStarted tasks
while [[ true ]]; do

	# if not enough tasks in NotStartedDir
	if [[ "$(find $NotStartedDir -name '*.txt' | wc -l)" -lt "$MaxTasks" ]]; then
		#statements
		echo "[LOADER] Checking if there are new tasks in CloudDir ... "
		echo "... copying $(ls ${CloudBaseDir}/NotStarted/*.txt) files ..."
		mv ${CloudBaseDir}/NotStarted/*.txt $NotStartedDir
		echo "... done!"
	fi

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

echo "[LOADER] Waiting NotStarted tasks ... "
sleep 1m
done #while done
