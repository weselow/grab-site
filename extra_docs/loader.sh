#!/bin/bash
# Task Runner
#

NotStartedDir=/home/viking01/data/NotStarted
InProgressDir=/home/viking01/data/InProgress
DoneDir=/home/viking01/data/Done
JobsCounter=0
MaxTasks=15
MyProcess=run-grab-site
MY_PID=$$
RunScriptDir="/home/viking01"

# проверяем наличие директорий
if ! [ -d "$NotStartedDir/" ]; then mkdir "$NotStartedDir/" ; fi
if ! [ -d "$InProgressDir/" ]; then mkdir "$InProgressDir/" ; fi
if ! [ -d "$DoneDir/" ]; then mkdir "$DoneDir/" ; fi

# run free disk checker
GT=$(ps -ela | grep pause_resume_grab_sites.sh)
if [ -z "$GT" ] 
	then 
		echo 
		echo Running pause_resume_grab_sites.sh ...
		echo 
		pause_resume_grab_sites.sh & 
	else
		echo 
		echo Script pause_resume_grab_sites.sh already running, skipping...
		echo 
fi


# while [ "1" -eq "1" ]; do
	for i in $(find $NotStartedDir -name '*.txt'); 
	do 
		echo "File found: " $i

		if [ -e $i ]; then
			# если файл существует
			if [ -s $i ]; then
				# Файл содержит данные.
				echo "Файл $i содержит данные."
				domainid=$(cat $i | awk -F':' '{print $1}')
				domain=$(cat $i | awk -F':' '{print $2}' | tr -d '\n' | tr -d '\r')
				

				# подсчитываем фоновые задачи
				# JobsCounter=$((`ps -ela | grep $MyProcess | wc -l`))
				JobsCounter=$((`ps ax -Ao ppid | grep $MY_PID | wc -l`))
				while [ $JobsCounter -ge $MaxTasks ]
				do
					JobsCounter=$((`ps ax -Ao ppid | grep $MY_PID | wc -l`))
					echo Wpull jobs counter: $JobsCounter
					sleep 1
				done

				# запускаем наш скрипт
				echo Running domain: $domain
				# echo domain $domain
				# echo domainid $domainid
				$RunScriptDir/run-grab-site.sh $domain $domainid $InProgressDir/$domain.txt $DoneDir/$domain.txt $i &				

			else
				# Файл пустой.
				echo
				echo "[ERROR] Файл $i пустой."
				echo
			fi
		else
			# иначе — создать файл и сделать в нем новую запись
			echo
			echo "[ERROR] File not find: "$i
			echo
		fi
	done
#done