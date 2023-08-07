mcdir="$(cd "$(dirname "$0")" && pwd)"

# find mods folder
modfolder=$( find $mcdir -maxdepth 1 | grep -e 'plugins\|mods' )
if [[ $modfolder == "" ]]; then
	mkdir $mcdir/mods
	modfolder="$mcdir/mods"
fi

# make sure backup exists
if ! [ -d "$mcdir/.bkp/world" ]; then
	mkdir --parents $mcdir/.bkp/world
fi

# clear mods
for i in `ls $modfolder | grep '.jar'`; do
	rm $modfolder/$i
done

# copy mods dirs to active mods
for i in `find $modfolder | grep -v '.bkp' | grep '.jar'`; do 
	cp $i $modfolder/`echo $i | sed -e 's/.*\///g'`
done

# start server
serverfile=$( find $mcdir -maxdepth 1 | grep -e '.*1\.20\.1.*\.jar' )
cores=$(cat /proc/cpuinfo | grep "cpu cores" -m 1| sed 's/.* //g')
ram=$( grep MemTotal /proc/meminfo | grep -o "[0-9]*" )


cd $mcdir
while true; do
	java -Dpaper.log-level=FINE -Xms$(( $ram / 4 ))k -Xmx$(( $ram * 2 ))k -jar $serverfile --nogui
	EXIT_CODE=$?
	
	# backup world before anything else
	tar -cvf - world* | pbzip2 -3 -p$(( cores / 2 )) -c > "$mcdir/.bkp/world/world-[`date \"+%Y-%m-%dT%H:%M:%S\"`].tar.bz2"

	case $EXIT_CODE in
		130)
			echo "Stop command issued."
			;&
		0)
			echo "Server is stopping..."
			exit 0
			;;
		*)
			echo "Server crashed with exit code $EXIT_CODE. Restarting..."
			;;
	esac
done
