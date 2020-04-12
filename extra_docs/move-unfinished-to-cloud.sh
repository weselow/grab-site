#!/bin/bash
# Move files to cloud to clean drive


dir=export_grab-site
for i in $(ls ${dir}/)
    do
        # counter=$(ls -R ${dir}/${i}/ | grep warc | wc -l)
        counter=$(find ${dir}/${i}/ -name '*.warc*'| wc -l)
        if [[ "${counter}" -gt "0" ]]; then            
            echo Moving ${i} 
            /usr/bin/rclone --drive-stop-on-upload-limit copy ${dir}/${i} gdrive01:/TempCleanDrive/${i}
            
            for j in $(find ${dir}/${i}/ -name '*.warc*') 
                do
                    echo ... deleting ${j} in ${i}
                    rm ${j}
                done
                
            echo
        fi
    done