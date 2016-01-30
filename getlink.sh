#!/bin/sh

usage="$(basename "$0") [-h] [-p] -- command line utility to quickly share any file or folder on your computer.


where:
    -h  show help
    -p  Make file password protected 
    -n  Restrict number of shares"


fileUpload(){

	FILE_CONFIDENTIAL="$4"

	if [ "$2" -eq 1 ] && [ ! -d "$1" ]; then
		
		if [ "$FILE_CONFIDENTIAL" = "NO" ]; then 
			## Now curl this request 

			echo "Hold tight, creating sharable link. This may take some time"
			echo ""
			response=$(curl -m 5000 -F "emailId=amit.aggarwal@shawacademy.com" -F "password=2June1989!" -F "zip_file=@$1" "http://kikimazu.in/server.php?isConfi=N&numShare=0")
		
			echo ""
			echo "#############################################################"
			echo "$response" | xargs
			echo "#############################################################"
			echo ""

		else 

			## Now curl this request 

			echo "Hold tight, creating sharable link. This may take some time"
			echo ""
			response=$(curl -m 5000 -F "emailId=amit.aggarwal@shawacademy.com" -F "password=2June1989!" -F "zip_file=@$1" "http://kikimazu.in/server.php?isConfi=Y&numShare=0")
		
			echo ""
			echo "#############################################################"
			echo "$response" | xargs
			echo "#############################################################"
			echo ""

		fi 

	else 
		
		tempFile=$RANDOM

		cmd="zip -r /tmp/$tempFile.zip "

		for var in "$3"
		do 
			cmd="$cmd $var"
		done

		$cmd 

		if [ $? -eq 0 ]; then

			echo "Hold tight, creating sharable link. This may take some time"
			echo ""
		
			if [ "$FILE_CONFIDENTIAL" = "YES" ]; then

				## Now curl this request 
				response=$(curl -m 5000 -F "emailId=amit.aggarwal@shawacademy.com" -F "password=2June1989!" -F "zip_file=@/tmp/$tempFile.zip;type=application/zip" "http://kikimazu.in/server.php?isConfi=Y&numShare=0") 
			

			
				echo ""
				echo "#############################################################"
				echo "$response" | xargs
				echo "#############################################################"
				echo ""

			else 

				response=$(curl -m 5000 -F "emailId=amit.aggarwal@shawacademy.com" -F "password=2June1989!" -F "zip_file=@/tmp/$tempFile.zip;type=application/zip" "http://kikimazu.in/server.php?isConfi=N&numShare=0")
				echo ""
				echo "#############################################################"
				echo "$response" | xargs
				echo "#############################################################"
				echo ""				

			fi

		fi

		## Now delete the temp file
		rm -rf "/tmp/$tempFile.zip"	
	fi 


}


### Check if user has account on sever 

FILE_CONFIDENTIAL="NO"
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
