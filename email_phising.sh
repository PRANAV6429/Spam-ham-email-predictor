#!/bin/bash
#setting the path to my email client's mailbox file
MAILBOX="/var/mail/$USER"


#set the path to spam folder
SPAM_PHISHING_FOLDER="$HOME/spam_phishing"


#create the spam folder if it doesn't already exist
mkdir -p $SPAM_PHISHING_FOLDER

#use the 'formail' command to extract the headers from each email
#and check for common spam and phishing charachterstics

formail -I "from:" <$MAILBOX | while read from; do


#check for common spam keywords
if echo "$from" | grep -qE"(viagra|pills|loans|credit|debit|debt|weight loss)";
	echo "spam deetcted: $from"

#extracting the user info from the email headers
	user=$(echo "$from" |awk -F"<" '{print $1}' | awk '{print $1}')
	ip=$(echo "$from" |awk -F"<" '{print $1}' |awk '{print $2}' | awk -F">" 	z'{print $1}')
	echo "User: $user"
	echo "IP: $ip"


#move the  email to spam folder
	mv $MAILBOX $(echo $MAILBOX |sed "s/^\/var\mail\/\([^@]\)\@./\1/")/spam_phihing/$from
	continue
fi

#checking for phishing urls:
if echo "$from" | grep -qE "(http|https)://[^/]"; then url=$(echo "$from"| grep -oE "(http|https)://[^/]")
	if curl -s -o /dev/null -w "%{http_code}" $url|grep -q "404"; then
		echo "phishing URL detected: $url"
		#extract user info from the mail headers:
		user=$(echo "$from"|awk -F"<" '{print $1}' |awk '{print $1}')
		ip=$(echo "$from"| awk -F"<" '{print $1}' | awk '{print $2}' |awk -F">" '{print $1}')
		echo "User: $user"
		echo "IP: $ip"
		
		#move the email to the spam folder
		mv $MAILBOX $(echo $MAILBOX | sed "s/^\/var\/mail\/\([^@]\)@./\1/")/spam_phishing/$from
		fi
	fi
done
