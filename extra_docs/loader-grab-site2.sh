#!/bin/bash
# Task Runner
# v.1.0.5


# -----------------------------
# -- Function CheckDependencies --
# -----------------------------
function CheckDependencies {
	#Install Chromium Browser
	echo "[LOADER] Checking Dependencies ..."
	if [[ -z "$(dpkg -s chromium-browser | grep Description)" ]]; then
		sudo apt install -y chromium-browser
	fi
}
# Function CheckDependencies End


# -----------------------------
# -- Function LoadSettings  --
# -----------------------------
function LoadSettings {
	if [[ -e "loader.ini" ]]; then
		while read a b ; do
			if [[ "$a" == "MaxTasks" ]]; then MaxTasks="$b"; fi
			if [[ "$a" == "Hostname" ]]; then Hostname="$b"; fi
			if [[ "$a" == "BaseDir" ]]; then
				BaseDir="$b"
				NotStartedDir="${BaseDir}/${Hostname}/NotStarted"
				InProgressDir="${BaseDir}/${Hostname}/InProgress"
				DoneDir="${BaseDir}/${Hostname}/Done"
				LocalRepoDir="${BaseDir}/LocalRepo"
				LogDir="${BaseDir}/logs"
				ExportDir="${BaseDir}/export_grab-site"
			fi
			if [[ "$a" == "MyProcess" ]]; then MyProcess="$b"; fi
			if [[ "$a" == "RunScriptDir" ]]; then RunScriptDir="$b"; fi
			if [[ "$a" == "DebugMode" ]]; then DebugMode="$b"; fi
			if [[ "$a" == "CloudRepo" ]]; then CloudRepo="$b"; fi
			if [[ "$a" == "Quota" ]]; then Quota="$b"; fi
			if [[ "$a" == "IfMoveToCloud" ]]; then IfMoveToCloud="$b"; fi
			if [[ "$a" == "UserAgent" ]]; then UserAgent="$b"; fi
		done < loader.ini

		if [[ "$DebugMode" == "true" ]]; then
			echo '*** START setting variables ***'
			echo "MaxTasks = $MaxTasks"
			echo "Hostname = $Hostname"
			echo "BaseDir = $BaseDir"
			echo "NotStartedDir = $NotStartedDir"
			echo "InProgressDir = $InProgressDir"
			echo "DoneDir = $DoneDir"
			echo "LogDir = $LogDir"
			echo "MyProcess = $MyProcess"
			echo "RunScriptDir = $RunScriptDir"
			echo "DebugMode = $DebugMode"
			echo "LocalRepoDir = $LocalRepoDir"
			echo "CloudRepo = $CloudRepo"
			echo "Quota = $Quota"
			echo "IfMoveToCloud = $IfMoveToCloud"
			echo '*** END setting variables***'
		fi


	fi
}
# Function LoadSettings End

# -----------------------------
# -- Function CreateTaskFile  --
# -----------------------------
function CreateTaskFile {
	FileInProgress=${InProgressDir}/${domain}.txt
	TempDir=${BaseDir}/tmp/${domain}
	dt=$(date +"%Y-%m-%d")
	OutputDir=${ExportDir}/${domain}_${domainid}/${dt}
	LogFile=${LogDir}/${domain}.log
	LogErrorFile=${LogDir}/${domain}_errors.log
	ScreenshotDir=${ExportDir}/${domain}_${domainid}

	cat > $FileInProgress << EOF
#!/bin/bash
# Run Crawler

TempDir=${BaseDir}/tmp/${domain}
FileInProgress=${FileInProgress}
dt=$(date +"%Y-%m-%d")
OutputDir=${ExportDir}/${domain}_${domainid}/${dt}
LogFile=${LogFile}
LogErrorFile=${LogErrorFile}

echo "[TASK] Checking output directories..."
if ! [ -d "$ExportDir/${domain}_${domainid}" ]; then mkdir "$ExportDir/${domain}_${domainid}" ; fi
if ! [ -d "$ExportDir/${domain}_${domainid}/homepage" ]; then mkdir "$ExportDir/${domain}_${domainid}/homepage" ; fi
if ! [ -d "$OutputDir" ]; then echo ... Creating OutputDir: $OutputDir; mkdir ${OutputDir} ; fi
if ! [ -d "${ScreenshotDir}" ]; then echo ... Creating ScreenshotDir: $ScreenshotDir; mkdir ${ScreenshotDir} ; fi
if [ -d "$TempDir" ]; then rm -R $TempDir ; fi

echo "[TASK] Logging settings ..."
echo " " >> $LogFile && echo "-----------------------------" >> $LogFile && echo " " >> $LogFile
echo "Date: $dt" >> $LogFile
echo "Domain: $domain" >> $LogFile
echo "DomainID: $domainid" >> $LogFile
echo "TempDir: $TempDir" >> $LogFile
echo "ExportDir: $exportdir" >> $LogFile
echo "OutputDir: $outputdir" >> $LogFile
echo "FileToMove: $FileInProgress" >> $LogFile
echo UserAgent: $UserAgent >> $LogFile
echo "Date: $dt" >> $LogErrorFile

# Get site screenshots
sdate=\$(date +"%Y-%m-%d")
if ! [[ -e "${ScreenshotDir}/\${sdate}_${domain}_1024_http-pure.png" ]]; then
	usr/bin/chromium-browser --no-sandbox --headless --disable-gpu \\
		--window-size=1024,768 --screenshot=${ScreenshotDir}/\${sdate}_${domain}_1024_http-pure.png \\
		http://${domain} 2>> $LogErrorFile >> $LogFile
	sleep 2
fi
if ! [[ -e "${ScreenshotDir}/\${sdate}_${domain}_1024_http-wwww.png" ]]; then
	usr/bin/chromium-browser --no-sandbox --headless --disable-gpu \\
		--window-size=1024,768 --screenshot=${ScreenshotDir}/\${sdate}_${domain}_1024_http-wwww.png \\
		http://www.${domain} 2>> $LogErrorFile >> $LogFile
	sleep 2
fi
if ! [[ -e "${ScreenshotDir}/\${sdate}_${domain}_1024_https-pure.png" ]]; then
	usr/bin/chromium-browser --no-sandbox --headless --disable-gpu \\
		--window-size=1024,768 --screenshot=${ScreenshotDir}/\${sdate}_${domain}_1024_https-pure.png \\
		https://${domain} 2>> $LogErrorFile >> $LogFile
	sleep 2
fi
if ! [[ -e "${ScreenshotDir}/\${sdate}_${domain}_1024_https-wwww.png" ]]; then
	usr/bin/chromium-browser --no-sandbox --headless --disable-gpu \\
		--window-size=1024,768 --screenshot=${ScreenshotDir}/\${sdate}_${domain}_1024_https-wwww.png \\
		https://www.${domain} 2>> $LogErrorFile >> $LogFile
	sleep 2
fi

# Run full site crawler
echo "Staring grabbing $domain ..."
grab-site --level=3 \\
	--concurrency=3 \\
	--delay 1 \\
	--no-offsite-links \\
	--ua=${UserAgent} \\
	--id=${domainid} \\
	--dir=${TempDir} \\
	--finished-warc-dir=${OutputDir} \\
	--wpull-args="--strip-session-id \"--html-parser html5lib\" \"--quota ${Quota}\"" \\
	http://${domain} https://${domain} http://www.${domain} https://www.${domain}  2>> $LogErrorFile >> $LogFile

echo "[TASK] Finishing grabbing $domain ..."
sleep 5

# Run home page crawler
echo "[TASK] Staring grabbing $domain homepage..."
grab-site --1 \\
	--concurrency=3 \\
	--delay 1 \\
	--ua=${UserAgent} \\
	--id=${domainid}_1 \\
	--dir=${TempDir}/homepage \\
	--finished-warc-dir=$ExportDir/${domain}_${domainid}/homepage \\
	--wpull-args="--strip-session-id \"--html-parser html5lib\"" \\
	http://${domain} https://${domain} http://www.${domain} https://www.${domain}  2>> $LogErrorFile >> $LogFile

echo "[TASK] Finishing grabbing $domain homepage..."
sleep 5

# Check if there were errors during crawling
if [[ -e "$LogErrorFile" ]]; then
	if ! [[ -z "\$(cat $LogErrorFile | grep RuntimeError )" ]]; then
			echo && echo "Domain $domain finished with errors:"
			cat $LogErrorFile | grep "RuntimeError:"
			echo
			sleep 30
	fi
fi

# Move finished-warc-dir=$OutputDir to local repo
echo "${dt}" > $ExportDir/${domain}_${domainid}/finished.txt
mv $ExportDir/${domain}_${domainid}/ ${LocalRepoDir}/
echo "[TASK] Moving $domain to LocalRepoDir ... done!"
sleep 3

# Move logs files to local repo $LogErrorFile $LogFile
if ! [ -d "${LocalRepoDir}/logs" ]; then
	echo "[TASK] Creating LocalRepoLogs dir: ${LocalRepoDir}/logs"
	mkdir ${LocalRepoDir}/logs
fi
mv $LogFile ${LocalRepoDir}/logs/
mv $LogErrorFile ${LocalRepoDir}/logs/
echo "[TASK] Moving ${LogFile}, ${LogErrorFile} to LocalRepoDir ... done!"

# Move from LocalRepo to Cloud
if [[ "${IfMoveToCloud}" == "true"  ]]; then
		/usr/bin/rclone --drive-stop-on-upload-limit move \\
				${LocalRepoDir}/${domain}_${domainid} \\
				${CloudRepo}/TempFiles/${Hostname}/${domain}_${domainid} --delete-empty-src-dirs \\
				&& rm -R ${LocalRepoDir}/${domain}_${domainid}
		echo "[TASK] Moving ${domain} to CloudRepo ... done!"
	else
		# save command to file
		echo"#!/bin/bash" > ${LocalRepoDir}/job_${domain}.sh
		echo"/usr/bin/rclone --drive-stop-on-upload-limit move ${LocalRepoDir}/${domain}_${domainid} ${CloudRepo}/TempFiles/${Hostname}/${domain}_${domainid} --delete-empty-src-dirs && rm -R ${LocalRepoDir}/${domain}_${domainid} && rm ${LocalRepoDir}/job_${domain}.sh " >> ${LocalRepoDir}/job_${domain}.sh
		chmod +x ${LocalRepoDir}/job_${domain}.sh
		echo "[TASK] Saving job to file job_${domain}.sh ... done!"
fi

# Check if TempDir contains no warc files
# and delete TempDir
COUNTER=0
while [[ \${COUNTER} -lt  "60" ]]; do
	if [[ "0" -eq "\$(find $TempDir -type f | grep warc.gz | wc -l)" ]]; then
		echo
		let "COUNTER += 60"
		sleep 1m
	fi
	let "COUNTER += 1"
	sleep 1m
done
rm -R $TempDir
echo "[TASK] TempDir "$TempDir" does not contains war.gz, deleting ... done!"

# Finish
echo "[TASK] The task $domain is done!"
mv  $FileInProgress ${DoneDir}/

EOF

}
# Functions CreateTaskFile End

# -----------------------------
# -- Functions CreatePauseResumeFile --
# -----------------------------

function  CreatePauseResumeFile {
	cat > ${pausefile} << EOF
#!/bin/bash
LOW_DISK_KB=$((15 * 1024 * 1024))	# 15 Gb
PARTITION=${LocalRepoDir}
CHECK_INTERVAL_SEC=1200				# every 20 min
paused=0

while true; do
	left=\$(df "\${PARTITION}" | grep / | sed -r 's/ +/ /g' | cut -f 4 -d ' ')
	if [[ \${paused} = 1 ]] && (( left >= \${LOW_DISK_KB} )); then
		echo "[LOADER] Disk OK, resuming all grab-sites ..."
		paused=0
		killall -CONT grab-site
	fi
	if (( left < \${LOW_DISK_KB} )); then
		echo "[LOADER] Disk low, pausing all grab-sites ..."
		paused=1
		killall -STOP grab-site
	fi
	sleep \${CHECK_INTERVAL_SEC}
done
EOF

}
# Functions CreatePauseResumeFile End

# -----------------------------
# -- Functions MoveUnfinishedToCloudFile --
# -----------------------------

function  MoveUnfinishedToCloudFile {
	cat > ${MoveUnfinishedFile} << EOF
#!/bin/bash
while [[ "\$(ps -ela | grep grab | wc -l)" -gt "0" ]]; do
    for i in \$(ls ${ExportDir}/)
        do
            counter=\$(find ${ExportDir}/\${i}/ -name '*.warc*'| wc -l)
            if [[ "\${counter}" -gt "0" ]]; then
                /usr/bin/rclone --drive-stop-on-upload-limit copy \\
                    ${ExportDir}/\${i} \\
                    ${CloudRepo}/TempFiles/${Hostname}/\${i}

               for j in \$(find ${ExportDir}/\${i}/ -name '*.warc*')
                    do
                       rm \${j}
                    done
            fi
        done
    sleep 10m
done
EOF

}
# Functions MoveUnfinishedToCloudFile End



# -----------------------------
# -- MAIN PROGRAM --
# -----------------------------

JobsCounter=0
# MY_PID=$$
CheckDependencies
LoadSettings
sleep 1
echo

# -----------------------------
# -- Checking directories --
# -----------------------------

echo [LOADER] Checking directories ...
if ! [ -d "$NotStartedDir" ]; then mkdir $NotStartedDir; fi
if ! [ -d "$InProgressDir" ]; then mkdir $InProgressDir; fi
if ! [ -d "$DoneDir" ]; then mkdir $DoneDir; fi
if ! [ -d "$LogDir" ]; then mkdir $LogDir; fi
if ! [ -d "${BaseDir}/tmp" ]; then echo ... Creating TempDir: ${BaseDir}/tmp/; mkdir ${BaseDir}/tmp ; fi
if ! [ -d "$LocalRepoDir" ]; then echo ... Creating LocalRepoDir: $LocalRepoDir; mkdir $LocalRepoDir ; fi
if ! [ -d "$ExportDir" ]; then echo ... Creating ExportDir: $exportdir; mkdir $ExportDir ; fi


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
# -- Run free disk checker --
# -----------------------------

if [ -z "$(ps -ela | grep pause_resume)" ]
	then
		echo "[LOADER] Running pause_resume_grab_sites.sh ..."
		pausefile=/home/viking01/pause_resume_grab_sites.sh
		CreatePauseResumeFile
		chmod +x ${pausefile}
		bash  ${pausefile} &
	else
		echo "[LOADER] pause_resume_grab_sites.sh already running, skipping..."
fi

# -----------------------------
# -- Run MoveUnfinishedToCloudFile --
# -----------------------------

if [[ "${IfMoveToCloud}" == "true"  ]]; then
	if [ -z "$(ps -ela | grep move-unfinished)" ]
		then
			echo "[LOADER] Running MoveUnfinishedFile ..."
			MoveUnfinishedFile=/home/viking01/move-unfinished-to-cloud.sh
			MoveUnfinishedToCloudFile
			chmod +x ${MoveUnfinishedFile}
			bash  ${MoveUnfinishedFile} &
		else
			echo "[LOADER] MoveUnfinishedFile already running, skipping..."
	fi
fi



# -----------------------------
# -- Resume InProgress tasks --
# -----------------------------

InProgressTasks=$(find $InProgressDir -name '*.txt')
if [ -z "$(ps -ela | grep grab-site)" ]; then
	echo "[LOADER] Looks like it is first run, resuming all InProgress tasks ... "
	for i in $InProgressTasks; do
		JobsCounter=$(ps -ela | grep $MyProcess | wc -l)

		while [ $JobsCounter -ge $MaxTasks ]
			do
				JobsCounter=$(ps -ela | grep $MyProcess | wc -l)
				echo Wpull jobs counter: $JobsCounter
				sleep 3
			done

		echo "[LOADER] ... resuming ${i}"
		bash ${i} &
		sleep 3
	done
else
	echo "[LOADER] Looks like it is not first run, skipping resuming ... "
fi

sleep 3


# -----------------------------
# -- Run NotStarted tasks --
# -----------------------------

while [[ true ]]; do

	for i in $(find $NotStartedDir -name '*.txt')
		do
			echo "Find $(find $NotStartedDir -name '*.txt' | wc -l) tasks ..."
			echo "... taking task: $i"
			sleep 3

			if [ -e $i ]; then
				# if file exists
				if [ -s $i ]; then
					# File contains data
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
						CreateTaskFile
						sleep 1
						bash ${InProgressDir}/${domain}.txt &
						rm $i

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
