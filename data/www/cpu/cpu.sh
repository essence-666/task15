while true; do
	top -n 1 -b | awk '/%Cpu/{print 100-$8"%"}' > /data/www/cpu/cpu_usage.txt
	sleep 1
done
