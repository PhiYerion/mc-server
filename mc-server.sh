# USER INPUT:

echo "You need to download pbzip2 for backups to work\n"

echo "Choose a framework from Paper, vanilla, or fabric"
read framework

echo "Choose a directory in which to put the server"
read serverdir

mkdir $serverdir/server
serverdir="$serverdir/server"

url=""

script_dir="$(cd "$(dirname "$0")" && pwd)"
cp "$script_dir/start.sh" "$serverdir/start.sh"

cd $serverdir

case $framework in
	"paper")
		url="https://api.papermc.io/v2/projects/paper/versions/1.20.1/builds/108/downloads/paper-1.20.1-108.jar"
		;;

	"fabric")
		url="https://meta.fabricmc.net/v2/versions/loader/1.20.1/0.14.22/0.11.2/server/jar"
		;;
	
	"vanilla")
		url="https://piston-data.mojang.com/v1/objects/84194a2f286ef7c14ed7ce0090dba59902951553/server.jar"
		;;
esac

# MAIN:
## Download:
echo "Starting download..."
wget $url

## First run:
echo "Starting first server run..."
java -Xms2G -Xmx4G -jar "$( find $serverdir -maxdepth 1 | grep -e '.*\.jar$' )" --nogui

## Accept eula:
echo "Accept EULA?"
read response
if [ "${response:0:1}" == "y" ]; then
	sed -i 's/false/true/' eula.txt
else
	exit 0
fi

## Install plugins:
modfolder=$( find $serverdir -maxdepth 1 | grep -e 'plugins\|mods' )
if [[ $modfolder == "" ]]; then
	        mkdir $serverdir/mods
		        modfolder="$serverdir/mods"
fi

### Server Monitor 
echo "Installing server monitor..."
mkdir $modfolder/monitor
server_monitor_url="https://github.com/plan-player-analytics/Plan/releases/download/5.5.2461/Plan-5.5-build-2461.jar"
wget $server_monitor_url -P $modfolder/monitor

## Second run:
echo "stop" | $serverdir/start.sh
