#!/bin/bash

#  _________   _________   _________
# |         | |         | |         |
# |   six   | |    2    | |   one   |
# |_________| |_________| |_________|
#     |||         |||         |||
# -----------------------------------
#        notification.sh v.1.11
# -----------------------------------

# This script is used to send formatted messages to a specified Telegram group using a Telegram bot.
# It supports sending informational, alert, and error messages, each with distinct formatting.
# The script reads the Telegram group ID and bot token from a secrets file located at /etc/telegram.secrets.
# If the secrets file does not exist, the script will prompt the user to create it, inputting the required
# GROUP_ID and BOT_TOKEN values. The secrets file is then secured with permissions set to 600.

# For icons in Telegram: ☮⚠ https://www.w3schools.com/charsets/ref_utf_symbols.asp

# Author: https://github.com/russellgrapes/




# Global variables
SECRETS_FILE="/etc/telegram.secrets"

# Functions
function check_dependencies {
	local required_packages=("curl" "gawk" "sed")
	local install_command=""
	local package_manager=""
	
	# Detect system package manager
	if command -v apt-get &> /dev/null; then
		package_manager="apt-get"
		install_command="sudo apt-get install -y"
	elif command -v yum &> /dev/null; then
		package_manager="yum"
		install_command="sudo yum install -y"
	else
		echo "Unsupported package manager. Please install the required packages manually: ${required_packages[*]}"
		exit 1
	fi
	
	# Check and install missing packages
	for package in "${required_packages[@]}"; do
		if ! command -v $package &> /dev/null; then
			echo "$package is not installed."
			read -p "Do you want to install $package? (y/n): " answer
			if [[ $answer == "y" || $answer == "Y" ]]; then
				$install_command $package
				if [[ $? -ne 0 ]]; then
					echo "Failed to install $package. Please install it manually."
					exit 1
				fi
			else
				echo "$package is required for this script to run."
				exit 1
			fi
		fi
	done
	
	echo "All required packages are installed."
}

function load_secrets {
	if [[ ! -f "$SECRETS_FILE" ]]; then
		check_dependencies
		create_secrets_file
	fi
	
	source "$SECRETS_FILE"
}

function create_secrets_file {
	echo ""
	echo "The secrets file '$SECRETS_FILE' does not exist."
	echo "Let's create it."
	echo ""
	
	echo "GROUP_ID should be set to the Telegram group ID where alerts will be sent."
	echo "BOT_TOKEN is the token for the Telegram bot that will send the messages."
	
	echo ""
	echo "Example GROUP_ID:  12345678"
	echo "Example BOT_TOKEN: 9987654321:RtG8kL5vX7bQw9mP2nR4aD1uY6jZ3eN5fC8oK4hV1xL7"
	
	echo ""
	read -p "Enter the Telegram group ID (GROUP_ID): " GROUP_ID
	read -p "Enter the Telegram bot token (BOT_TOKEN): " BOT_TOKEN
	
	echo "GROUP_ID=\"$GROUP_ID\"" > "$SECRETS_FILE"
	echo "BOT_TOKEN=\"$BOT_TOKEN\"" >> "$SECRETS_FILE"
	
	echo ""
	chmod 600 "$SECRETS_FILE"
	echo "Secrets file '$SECRETS_FILE' created with permissions set to 600."
	exit 1
}

function send_message {
	local message_content=$1
	local message_type=$2
	local formatted_message=""
	
	# Convert the uptime format to 365d, 16h, 50m
	local uptime_raw=$(uptime -p | sed 's/^up //')    
	local formatted_uptime=$(echo "$uptime_raw" | awk ' {
	for (i = 1; i <= NF; i++) {
		if ($i ~ /day/ || $i ~ /days/) { printf("%sd", $(i-1)) }
		if ($i ~ /hour/ || $i ~ /hours/) { printf(", %sh", $(i-1)) }
		if ($i ~ /minute/ || $i ~ /minutes/) { printf(", %sm", $(i-1)) }
	} }')
			
	local formatted_uptime=$(echo "$formatted_uptime" | sed 's/^, //')
	
	case $message_type in
		info)
			formatted_message=$(echo -e "\n♨ *Info*  |  $HOSTNAME  |  $(date '+%H:%M:%S')\n----------------------------------------\n$message_content\n----------------------------------------\nSystem uptime: $formatted_uptime")
		;;
		alert)
			formatted_message=$(echo -e "\n⚠ *Alert*  |  $HOSTNAME  |  $(date '+%H:%M:%S')\n----------------------------------------\n$message_content\n----------------------------------------\nImmediate attention required!\n")
		;;
		error)
			formatted_message=$(echo -e "\n⚠ *Error*  |  $HOSTNAME  |  $(date '+%H:%M:%S')\n----------------------------------------\n$message_content\n----------------------------------------\nCheck system logs for details.\n")
		;;
		*)
			echo "Unknown message type: $message_type"
			exit 1
		;;
	esac
	
	local curl_data=(
		--data parse_mode=Markdown
		--data "text=$formatted_message"
		--data "chat_id=$GROUP_ID"
	)
	
	curl -s "${curl_data[@]}" "$TELEGRAM_API" > /dev/null
}

# Help message
function show_help {
	echo ""
	echo "Usage: $0 [--info | --alert | --error] -m <message>"
	echo "  --info       Send an informational message"
	echo "  --alert      Send an alert message"
	echo "  --error      Send an error message"
	echo "  -m <message> The message content to send"
	echo "  -h           Show this help message"
	echo ""
}

# Load secrets
load_secrets

# Parse arguments
message_type=""
message_content=""

while [[ "$#" -gt 0 ]]; do
	case $1 in
		--info) message_type="info"; shift ;;
		--alert) message_type="alert"; shift ;;
		--error) message_type="error"; shift ;;
		-m) message_content="$2"; shift 2 ;;
		-h) show_help; exit 0 ;;
		*) echo "Unknown parameter: $1"; show_help; exit 1 ;;
	esac
done

# Validate inputs
if [[ -z "$message_type" ]]; then
	echo "Error: Message type is required (--info, --alert, --error)"
	show_help
	exit 1
fi

if [[ -z "$message_content" ]]; then
	echo "Error: Message content is required (-m <message>)"
	show_help
	exit 1
fi

# API endpoint
TELEGRAM_API="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"

# Send the message
send_message "$message_content" "$message_type"
