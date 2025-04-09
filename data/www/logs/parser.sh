#!/bin/bash

file1=/data/www/logs/file1.txt
file2=/data/www/logs/file2.txt
file3=/data/www/logs/file3.txt
file4=/data/www/logs/file4.txt

lines=/data/www/logs/lines.txt

nginx_access_logs=/var/log/nginx/access.log
nginx_error_logs=/var/log/nginx/error.log

function parse {
	accessLines=$(cat $lines | awk '//{print $1}')
	errorLines=$(cat $lines | awk '//{print $2}')

	nginx_alines=$(wc -l $nginx_access_logs | awk '//{print $1}')
	nginx_elines=$(wc -l $nginx_error_logs | awk '{print $1}')

	access_tailLines=$(($nginx_alines-$accessLines))
	error_tailLines=$(($nginx_elines-$errorLines))

	echo "$nginx_alines $nginx_elines" > $lines
	
	access_logs=$(tail -n $access_tailLines $nginx_access_logs)
	error_logs=$(tail -n $error_tailLines $nginx_error_logs)


	server_pattern='5..'
	client_pattern='4..'
	while IFS= read -r record; do
		if [[ -n  $record ]]
		then
			echo "$record" >> $file1
			status=$(echo "$record" | awk '//{print $9}')
			if [[ $status =~ $server_pattern ]];
			then 
				echo $record >> $file3
			fi
	
			if [[ $status =~ $client_pattern ]];
			then
				echo $record >> $file4
			fi
		fi
	done <<< $access_logs

	while IFS= read -r record; do	
		if [[ -n $record ]]
		then
			echo "$record" >> $file1
		fi
        done <<< $error_logs

	file1_size=$(du $file1 | awk '//{print $1}')
	
	if [ $file1_size -gt 10 ]
	then
		count=$(wc -l $file1 | awk '//{print $1}')
		time=$(date)
		echo "" > $file1
		awk 'BEGIN { print "'"$time"' file1 was cleanup successfully and '"$count"' records was deleted" }' >> $file2
	fi

}



while true; do
	parse
	sleep 5
done
