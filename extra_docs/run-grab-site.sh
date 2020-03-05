#!/bin/bash
#
# Grab-site Options
# source: https://github.com/ArchiveTeam/grab-site
#

# $RunScriptDir/run-grab-site.sh $domain $domainid $InProgressDir/$domain.txt $DoneDir/$domain.txt $i $LogDir &

domain=$1
domainid=$2
useragent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.116 Safari/537.36"
dir=/home/viking01/data/tmp/$domain
dt=$(date +"%Y-%m-%d")
exportdir=/home/viking01/data/export_grab-site
outputdir=$exportdir/${dt}_${domain}_${domainid}
FileInProgress=$3
FileDone=$4
FileNotStarted=$5

# Log settings
LogDir=$6
LogFile=$LogDir/$domain.log
LogErrorFile=$LogDir/${domain}_errors.log

# exec 6>&1 # Связать дескр. #6 со stdout.
# exec > $exportdir/$domain.log


#создаем директорию
echo Checking output directories...
if [ -d "$dir/" ]; then rm -R "$dir/" ; fi
if ! [ -d "$exportdir/" ]; then echo ... Creating ExportDir: $exportdir; mkdir "$exportdir/" ; fi
if ! [ -d "$outputdir/" ]; then echo ... Creating OutputDir: $outputdir; mkdir "$outputdir/" ; fi
echo ... done!
echo

echo Logging settings ...
echo Date: $dt >> $LogFile
echo Domain: $domain >> $LogFile
echo DomainID: $domainid >> $LogFile
echo TempDir: $dir >> $LogFile
echo ExportDir: $exportdir >> $LogFile
echo OutputDir: $outputdir >> $LogFile
echo FileToMove: $FileInProgress >> $LogFile
echo DestinationFile: $FileDone >> $LogFile
echo  >> $LogFile
echo ... done!
echo

echo
echo Staring grabbing $domain ...
echo

mv $FileNotStarted $FileInProgress

grab-site --level=3 \
	--concurrency=3 \
	--delay 1 \
	--ua="$useragent" \
	--id=$id \
	--dir=$dir \
	--finished-warc-dir=$outputdir \
	--wpull-args="--strip-session-id \"--html-parser html5lib\"" \
	http://$domain  2> $LogErrorFile >> $LogFile


# проверяем, что во временной директории нет warc файлов
COUNTER=0
while [[ $COUNTER -lt  "60" ]]; do
	if [[ "0" -eq "$(find $dir -type f | grep warc.gz | wc -l)" ]]; then
		echo
		let "COUNTER += 60"
		sleep 1m # пауза 1 минута
	fi
	let "COUNTER += 1"
	sleep 1m
done

echo ... папка "$dir" не содержит war.gz, удаляем ...
rm -R $dir


# exec 1>&6 6>&- # Восстановить stdout и закрыть дескр. #6.


# ***
# *** Grab-site default start command list
# ***
#
# viking01@grab-site:~$ grab-site http://aws-law.ru --which-wpull-command
#
# GRAB_SITE_WORKING_DIR=/home/viking01/aws-law.ru-2020-02-28-691660a3
# DUPESPOTTER_ENABLED=1 /home/viking01/gs-venv/bin/wpull --quiet
# -U 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:70.0) Gecko/20100101 Firefox/70.0'
# -header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
# --header 'Accept-Language: en-US,en;q=0.5'
# --no-check-certificate --no-robots --inet4-only --dns-timeout 20
# --connect-timeout 20 --read-timeout 900 --session-timeout 172800
# --tries 3 --waitretry 5 --max-redirect 8
# --output-file /home/viking01/aws-law.ru-2020-02-28-691660a3/wpull.log
# --database /home/viking01/aws-law.ru-2020-02-28-691660a3/wpull.db
# --plugin-script /home/viking01/gs-venv/lib/python3.7/site-packages/libgrabsite/wpull_hooks.py
# --save-cookies /home/viking01/aws-law.ru-2020-02-28-691660a3/cookies.txt
# --delete-after --page-requisites --no-parent --concurrent 2
# --warc-file /home/viking01/aws-law.ru-2020-02-28-691660a3/aws-law.ru-2020-02-28-691660a3
# --warc-max-size 5368709120 --warc-cdx --strip-session-id
# --escaped-fragment --level inf --page-requisites-level 5
# --span-hosts-allow page-requisites,linked-pages
# --load-cookies /home/viking01/gs-venv/lib/python3.7/site-packages/libgrabsite/default_cookies.txt
# --debug-manhole --sitemaps --recursive http://aws-law.ru



# ***
# *** Graab-site options
# ***
# source: https://github.com/ArchiveTeam/grab-site#grab-site-options-ordered-by-importance
#
# --igsets=IGSET1,IGSET2
# use ignore sets IGSET1 and IGSET2. Ignore sets are used to avoid requesting junk URLs
# using a pre-made set of regular expressions. See the full list of available ignore sets.
# The global ignore set is implied and always enabled.
# The ignore sets can be changed during the crawl by editing the DIR/igsets file.

# --import-ignores
# Copy this file to to DIR/ignores before the crawl begins.

# --concurrency=N
# Use N connections to fetch in parallel (default: 2). Can be changed during the crawl by editing the DIR/concurrency file.

# --level=3
# recurse N levels instead of inf levels.

# --delay DELAY
# Time to wait between requests, in milliseconds (default: 0).  Can be "NUM", or "MIN-MAX"
# to use a random delay between MIN and MAX for each request.
# Delay applies to each concurrent fetcher, not globally.

# --ua=STRING
# Send User-Agent: STRING instead of pretending to be Firefox on Windows.

# --id=ID
# Use id ID for the crawl instead of a random 128-bit id. This must be unique for every crawl.

# --dir=DIR
# Put control files, temporary files, and unfinished WARCs in DIR
# (default: a directory name based on the URL, date, and first 8 characters of the id).

# --finished-warc-dir=FINISHED_WARC_DIR
# absolute path to a directory into which finished .warc.gz and .cdx files will be moved.

# --wpull-args=ARGS
# String containing additional arguments to pass to wpull; see wpull --help.
# ARGS is split with shlex.split and individual arguments can contain spaces if quoted,
# e.g. --wpull-args="--youtube-dl \"--youtube-dl-exe=/My Documents/youtube-dl\""

# --which-wpull-args-partial
# Print a partial list of wpull arguments that would be used and exit.
# Excludes grab-site-specific features, and removes DIR/ from paths.
# Useful for reporting bugs on wpull without grab-site involvement.

# --which-wpull-command
# Populate DIR/ but don't start wpull;
# instead print the command that would have been used to start wpull with all of the grab-site functionality.

# --debug
# print a lot of debug information.

# Also useful: --wpull-args=--no-skip-getaddrinfo to respect /etc/hosts entries.


# ***
# *** WPull options:
# ***
# source: https://wpull.readthedocs.io/en/master/options.html
#
# --monitor-disk MONITOR_DISK
# pause if minimum free disk space is exceeded
#
# --monitor-memory MONITOR_MEMORY
# pause if minimum free memory is exceeded
#
# --delete-after
# download files temporarily and delete them after
#
# --no-clobber
# don’t use anti-clobbering filenames
#
# --strip-session-id
# remove session ID tokens from links
#
# --sitemaps
# download Sitemaps to discover more links
