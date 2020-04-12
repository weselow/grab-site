#!/bin/bash
# Move files to cloud to clean drive

# ---------------------
# -- Functions start --
# ---------------------
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
                TempDir="${BaseDir}/tmp/${domain}"

                FileInProgress="${InProgressDir}/${domain}.txt"

                ExportDir="${BaseDir}/export_grab-site"
                dt=$(date +"%Y-%m-%d")
                OutputDir="${ExportDir}/${domain}_${domainid}/${dt}"                

                LogDir="${BaseDir}/logs"
                LogFile="${LogDir}/$domain.log"
                LogErrorFile="${LogDir}/${domain}_errors.log"                
            fi

            if [[ "$a" == "CloudRepo" ]]; then CloudRepo="$b"; fi
            if [[ "$a" == "IfMoveToCloud" ]]; then IfMoveToCloud="$b"; fi
            if [[ "$a" == "UserAgent" ]]; then UserAgent="$b"; fi
            if [[ "$a" == "MyProcess" ]]; then MyProcess="$b"; fi
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
            echo "LocalRepoDir = $LocalRepoDir"
            echo "TempDir = $TempDir"
            echo "FileInProgress = $FileInProgress"
            echo "OutputDir = $OutputDir"
            echo "LogDir = $LogDir"
            echo "LogFile = $LogFile"
            echo "LogErrorFile = $LogErrorFile"
            echo "CloudRepo = $CloudRepo"
            echo "IfMoveToCloud = $IfMoveToCloud"
            echo "UserAgent = $UserAgent"
            echo "MyProcess = $MyProcess"
            echo '*** END setting variables***'
        fi        
    fi
}
# Functions end

while [[ "$(ps -ela | grep grab | wc -l)" -gt "0" ]]; do
    LoadSettings > /dev/null
    
    if [[ "${IfMoveToCloud}" == "true"  ]]; then
        for i in $(ls ${ExportDir}/)
            do
                # counter=$(ls -R ${ExportDir}/${i}/ | grep warc | wc -l)
                counter=$(find ${ExportDir}/${i}/ -name '*.warc*'| wc -l)
                if [[ "${counter}" -gt "0" ]]; then            
                    echo Moving ${i}                     
                    /usr/bin/rclone --drive-stop-on-upload-limit copy \
                        ${ExportDir}/${i} \
                        ${CloudRepo}/TempFiles/${Hostname}/${i}
                    
                    for j in $(find ${ExportDir}/${i}/ -name '*.warc*') 
                        do
                            echo ... deleting ${j} in ${i}
                            rm ${j}
                        done
                        
                    echo
                fi
            done
    fi
    sleep 10m
done