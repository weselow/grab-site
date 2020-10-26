#!/bin/bash
# Task Runner

UserAgent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.116 Safari/537.36"
CurDir=$(pwd)
TempDir=${CurDir}/temp
OutputDir=${CurDir}/output
Quota=5368709120
LogErrorFile=${TempDir}/LogErrorFile.log
LogFile=${TempDir}/LogFile.log


domainid=$1
domain=$2
UrlFile=${TempDir}/${domain}_${domainid}.txt

echo "[TASK] Checking output directories..."
if ! [ -d "$OutputDir" ]; then echo ... Creating OutputDir: $OutputDir; mkdir ${OutputDir} ; fi
if [ -d "$TempDir" ]; then rm -R $TempDir ; fi


# Get site screenshots
sdate=$(date +"%Y-%m-%d")
/usr/bin/chromium-browser --no-sandbox --site-per-process --headless --disable-gpu \
	--window-size=1024,768 --screenshot=${OutputDir}/${sdate}_${domain}_1024_http-pure.png \
		http://${domain} 2>> $LogErrorFile >> $LogFile
	sleep 2
fi
/usr/bin/chromium-browser --no-sandbox --site-per-process --headless --disable-gpu \
	--window-size=1024,768 --screenshot=${OutputDir}/${sdate}_${domain}_1024_http-www.png \
	http://www.${domain} 2>> $LogErrorFile >> $LogFile
	sleep 2
fi
/usr/bin/chromium-browser --no-sandbox --site-per-process --headless --disable-gpu \
	--window-size=1024,768 --screenshot=${OutputDir}/\${sdate}_${domain}_1024_https-pure.png \
	https://${domain} 2>> $LogErrorFile >> $LogFile
	sleep 2
fi
/usr/bin/chromium-browser --no-sandbox --site-per-process --headless --disable-gpu \
		--window-size=1024,768 --screenshot=${ScreenshotDir}/${sdate}_${domain}_1024_https-www.png \
	https://www.${domain} 2>> $LogErrorFile >> $LogFile
	sleep 2
fi

# Run full site crawler
echo "Staring grabbing $domain ..."

echo "http://${domain}" > ${UrlFile}
echo "https://${domain}" >> ${UrlFile}
echo "http://www.${domain}" >> ${UrlFile}
echo "https://www.${domain}" >> ${UrlFile}

grab-site --level=3 \
	--concurrency=3 \
	--delay 1 \
	--no-offsite-links \
	--ua=${UserAgent} \
	--id=${domainid} \
	--dir=${TempDir} \
	--finished-warc-dir=${OutputDir} \
	--wpull-args="--strip-session-id "--html-parser html5lib" "-Q ${Quota}"" \
	--input-file ${UrlFile} 2>> $LogErrorFile >> $LogFile

echo "[TASK] Finishing grabbing $domain ..."
