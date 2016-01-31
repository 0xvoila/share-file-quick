#!/bin/sh

usage="$(basename "$0") [-h] [-p] [-c]-- command line utility to quickly share any file or folder on your computer.

where:
    -h  show help
    -p  Make file password protected 
    -c  create a new account"


G_EMAILID=""
G_PASSWORD=""

signup(){

 	read -p "emailid:" emailId
 	read -p "password:" password

 	echo "Create a new account"
 	echo ""
 	
 	response=$(curl -s -F "emailId=$emailId" -F "password=$password" "http://kikimazu.in/signup.php")

 	if [ "$response" -eq 0 ]; then 

 		echo '#!/bin/sh' > ~/.getlink.conf
 		echo "emailId=$emailId" >> ~/.getlink.conf
 		echo "password=$password" >> ~/.getlink.conf

 	elif [ "$response" -eq 1 ]; then 
 		 echo "$emailId already exists. Please choose another email id "
 		 exit 0

 	elif [ "$response" -eq 2 ]; then 
 		echo "Unable to signup. Please contact admin"
 		exit 0

 	else 
 		echo "some error"

 	fi

 	echo ""
 	echo "Welcome User."
 	echo "Below are some examples"
 	echo ""
 	echo "Get sharable link of single file"
 	echo "$> getlink.sh file1"
 	echo ""
 	echo "Get sharable link of multiple files and folders"
 	echo "$> getlink.sh file1 folder2"
 	echo ""
 	echo "Get password protected sharable link of multiple files and folders"
 	echo "$> getlink.sh -p file1 folder2"
 	echo ""
 	exit 0;
}

fileUpload(){

	FILE_CONFIDENTIAL="$4"

	if [ "$2" -eq 1 ] && [ ! -d "$1" ]; then
		
		if [ "$FILE_CONFIDENTIAL" = "NO" ]; then 
			## Now curl this request 
			echo ""	
			echo "Hold tight, creating sharable link. This may take some time"
			echo ""
			response=$(curl -m 5000 -F "emailId=$G_EMAILID" -F "password=$G_PASSWORD" -F "zip_file=@$1" "http://kikimazu.in/server.php?isConfi=N&numShare=0")
		
			echo ""
			echo "#############################################################"
			echo "$response" | xargs
			echo "#############################################################"
			echo ""

		else 

			## Now curl this request 
			echo ""	
			echo "Hold tight, creating sharable link. This may take some time"
			echo ""
			response=$(curl -m 5000 -F "emailId=$G_EMAILID" -F "password=$G_PASSWORD" -F "zip_file=@$1" "http://kikimazu.in/server.php?isConfi=Y&numShare=0")
		
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

			echo ""	
			echo "Hold tight, creating sharable link. This may take some time"
			echo ""
		
			if [ "$FILE_CONFIDENTIAL" = "YES" ]; then

				## Now curl this request 

				response=$(curl -m 5000 -F "emailId=$G_EMAILID" -F "password=$G_PASSWORD" -F "zip_file=@/tmp/$tempFile.zip;type=application/zip" "http://kikimazu.in/server.php?isConfi=Y&numShare=0") 
			

			
				echo ""
				echo "#############################################################"
				echo "$response" | xargs
				echo "#############################################################"
				echo ""

			else 

				response=$(curl -m 5000 -F "emailId=$G_EMAILID" -F "password=$G_PASSWORD" -F "zip_file=@/tmp/$tempFile.zip;type=application/zip" "http://kikimazu.in/server.php?isConfi=N&numShare=0")
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



FILE_CONFIDENTIAL="NO"
while getopts hpc name 
do

	case $name in
		h) echo "$usage"
       		exit;;

		p) FILE_CONFIDENTIAL="YES";;
			
       	c) signup ;;

        \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       		echo "$usage" >&2
       		exit 1;;

    esac
done

shift $(($OPTIND -1))

### Check if user has account on sever 

if [ -e ~/.getlink.conf ]; then 

	. ~/.getlink.conf

	G_EMAILID="$emailId"
	G_PASSWORD="$password"


else
	echo "Please create your account first using getlink --c"
	exit 0;

fi


## First check if zip is installed 

zip --help > /dev/null 2>&1

if [ $? -ne 0 ]; then 
	echo "Please install zip."
	exit 0;

fi 

curl --help >/dev/null 2>&1

if [ $? -ne 0 ]; then 
	echo "Please install curl"
	exit 0;
fi


### Now check the command line arguments
if [ $# -eq 0 ]; then
    echo "No file provided as argument"
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
