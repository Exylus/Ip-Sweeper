#!/bin/bash

if [ "$1" == "-s" ]
then
	if [ "$2" == "" ]
		then
		echo "You forgot the file destination!"
		echo "Syntax: ./ipsweep.sh -s FileName"

	else
		cidr=$(ip -4 a show wlan0|grep "inet" -m1|grep -oe '[0-9\.]\+/[0-9\.]\+')
		class=$(grep -oe '/[0-9\.]\+' <<< "$cidr")
		class=${class:1}
		ip=${cidr%/*}

		if (("$class" <= "8"))
			then 
				class="A"
		elif (("$class" <= "16"))
			then
				class="B"
		else
				class="C"
		fi
		echo -e "Ip adress is $ip and class category is $class"

		trip=${ip%.*}
		echo -e "Truncated ip is $trip"
		mkdir -p ip-list

	if [ "$class" == "C" ]
	then
		for ipc in `seq 1 254`; do
		ping -c 1 $trip.$ipc | grep "64 bytes" | cut -d " " -f 4 | tr -d ":" >> ip-list/$2.txt &
		done
	elif [ "$class" == "B" ]
	then 
		trip=${ip%.*}
		for ipb in `seq 1 254`; do
			trip="$trip.$ipb"
			for ipc in `seq 1 254`; do
				ping -c 1 $trip.$ipc | grep "64 bytes" | cut -d " " -f 4 | tr -d ":" >> ip-list/$2.txt &
			done
		done
	elif [ "class" == "A" ]
		then
		trip=${ip%.*}
		trip=${trip%.*}
		for ipa in `seq 1 254`; do
			trip="$trip.$ipa"
			for ipb in `seq 1 254`; do
				trip="$trip.$ipb"
				for ipc in `seq 1 254`; do
					ping -c 1 $trip.$ipc | grep "64 bytes" | cut -d " " -f 4 | tr -d ":" >> ip-list/$2.txt &
				done
			done
		done
	else
		echo -e "ERROR: NO CLASS"
	fi
	echo -e "Ip sweep finished, file saved as $2.txt"
	fi
elif [ "$1" == "-n" ]
then
	if [ "$2" == "" ]
		then 
		echo "You forgot the file destination!"
		echo "Syntax: ./ipsweep.sh -n FileName"
	
	else
		mkdir -p Nmap-results
		i='0'
		for ip in $(cat ip-list/$2.txt);
		do
		nmap $ip --max-retries 10 >> Nmap-results/$2.txt & 
		i=$((i + 1))
		done
		echo "Nmap finished with $i queries, file saved as $2.txt"

	fi
else
	echo "Wrong syntax!"
	echo "Syntax for an ip sweep:"
	echo "./ipsweep.sh -s FileName"
	echo "Syntax for a nmap sweep:"
	echo "./ipsweep.sh -n FileName"
fi
