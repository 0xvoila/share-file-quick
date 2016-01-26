#!/bin/sh

usage="$(basename "$0") [-h] [-n] -- command line utility to quickly share any file or folder on your computer.


where:
    -h  show help
    -p  Make file password protected "


fileUpload(){

	FILE_SENSITIVE="$4"

	if [ "$2" -eq 1 ] && [ ! -d "$1" ] && [ "$FILE_SENSITIVE" = "NO" ]; then
		
		## Now curl this request 

		echo "Hold tight, creating sharable link. This may take some time"
		echo ""
		response=$(curl -m 5000 -F "zip_file=@$1" http://kikimazu.in/api/server.php)
		
		echo ""
		echo "#############################################################"
		echo "Link $response"
		echo "#############################################################"
		echo ""
	
	else 
		echo "zipping"
		tempFile=$RANDOM

		if [ "$FILE_SENSITIVE" = "NO" ]; then

			cmd="zip -r /tmp/$tempFile.zip "

		else 

			password=$RANDOM
			cmd="zip -P $password -r /tmp/$tempFile.zip "
		
		fi  
		
		for var in "$3"
		do 
			cmd="$cmd $var"
		done

		$cmd 

		if [ $? -eq 0 ]; then

			echo "Hold tight, creating sharable link. This may take some time"
			echo ""
			
			## Now curl this request 
			response=$(curl -m 5000 -F "zip_file=@/tmp/$tempFile.zip;type=application/zip" http://kikimazu.in/api/server.php) 
			
			if [ "$FILE_SENSITIVE" = "YES" ]; then
			
				echo ""
				echo "#############################################################"
				echo "Link $response"
				echo "Zip-password $password"
				echo "#############################################################"
				echo ""

			else 

				echo ""
				echo "#############################################################"
				echo "Link $response"
				echo "#############################################################"
				echo ""				

			fi

		fi

		## Now delete the temp file
		rm -rf "/tmp/$tempFile.zip"	
	fi 


}


FILE_SENSITIVE="NO"
while getopts hp name 
do

	case $name in
		h) echo "$usage"
       		exit;;

		p) FILE_CONFIDENTIAL="YES";;
			
       
        \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       		echo "$usage" >&2
       		exit 1;;

    esac
done

shift $(($OPTIND -1))

## First check if zip is installed 

zip --help > /dev/null 2>&1

if [ $? -ne 0 ]; then 
	echo "Please install zip first."
	exit 0;

fi 

curl --help >/dev/null 2>&1

if [ $? -ne 0 ]; then 
	echo "Please install curl"
	exit 0;
fi


### Now check the command line arguments
if [ $# -eq 0 ]; then
    echo "No file to share is given"
    exit 0;
fi


### Now take each argument and check if file exists or it is folder 

found=0
temp=''
for var in "$@"
do
    if [ -e "$var" ] || [ -d "$var" ]; then
    	found=1
    else 
    	found=0
    	temp="$var"
    	break

    fi
done


if [ "$found" -eq 0 ]; then
	echo "File not found $temp"
	exit 1
fi

## Now check if there is only one file . Then do not zip it. Send it directly
fileUpload "$1" "$#" "$*" "$FILE_CONFIDENTIAL"
