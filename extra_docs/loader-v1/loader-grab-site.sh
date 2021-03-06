#!/bin/bash
# Task Runner
# v.1.0.4

JobsCounter=0
# MY_PID=$$

# -----------------------------
# -- Functions start --
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
                LogDir="${BaseDir}/logs"
            fi
            if [[ "$a" == "MyProcess" ]]; then MyProcess="$b"; fi
            if [[ "$a" == "RunScriptDir" ]]; then RunScriptDir="$b"; fi
            if [[ "$a" == "DebugMode" ]]; then DebugMode="$b"; fi
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
            echo '*** END setting variables***'            
        fi

        
    fi
}
# Functions end

LoadSettings
sleep 10
echo

# -----------------------------
# -- Checking directories --
# -----------------------------

echo [LOADER] Checking directories ...
if ! [ -d "$NotStartedDir" ]; then mkdir $NotStartedDir; fi
if ! [ -d "$InProgressDir" ]; then mkdir $InProgressDir; fi
if ! [ -d "$DoneDir" ]; then mkdir $DoneDir; fi
if ! [ -d "$LogDir" ]; then mkdir $LogDir; fi


# -----------------------------
# -- Run gs-server --
# -----------------------------

if [ -z "$(ps -ela | grep gs-server)" ]
    then
        echo "[LOADER] Running gs-server ..."
        gs-server 2>>$LogDir/gs-server-errors.log >>$LogDir/gs-server.log &
    else
        echo "[LOADER] GS-server already running, skipping..."
fi

# -----------------------------
# -- Run free disk checker --
# -----------------------------

if [ -z "$(ps -ela | grep pause_resume)" ]
    then
        echo "[LOADER] Running pause_resume_grab_sites.sh ..."
        /home/viking01/pause_resume_grab_sites.sh &
    else
        echo "[LOADER] Script pause_resume_grab_sites.sh already running, skipping..."
fi

sleep 5

echo

# -----------------------------
# -- Resume InProgress tasks --
# -----------------------------

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


if [[ "${IfMoveToCloud}" == "true"  ]]; then
    if [[ "$(ps -ela | grep unfinished | wc -l)" -eq "0" ]]; then
        $RunScriptDir/move-unfinished-to-cloud.sh &    
    fi
fi

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
