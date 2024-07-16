![alt telegram-bash-system-monitoring](https://github.com/russellgrapes/telegram-bash-notification/blob/main/placeholder.png)

# Telegram Bash Notification Script

A versatile bash script to send notifications to a specified Telegram group using a Telegram bot.

## Features

- **Telegram Alerts**: Sends informational, alert, and error messages to a specified Telegram group.
- **Dynamic Formatting**: Distinct icons and styles for different message types.
- **Automatic Dependency Handling**: Detects and installs required dependencies if missing.
- **Secrets Management**: Prompts to create and secure a secrets file if it does not exist.

## Usage

The `notification.sh` script offers various command-line options for sending notifications:

```bash
./notification.sh [--info | --alert | --error] -m <message>
```

### Options

- `--info`: Send an informational message.
- `--alert`: Send an alert message.
- `--error`: Send an error message.
- `-m <message>`: The message content to send.
- `-h`: Show this help message.

### Examples

```bash
./notification.sh --info -m "This is an informational message"
./notification.sh --alert -m "This is an alert message"
./notification.sh --error -m "This is an error message"
```

## Configuration

The script requires a secrets file at `/etc/telegram.secrets` with the following variables:

- `GROUP_ID`: Your unique Telegram group/user ID where alerts will be sent.
- `BOT_TOKEN`: The authentication token for your Telegram bot.

If the secrets file does not exist, the script will prompt the user to create it and input the required values. The file will be created with permissions set to 600 to ensure security.

## Installation

Follow these steps to install and set up the `notification.sh` script on your server.

### Install Required Packages

Install the main required packages:

```bash
sudo apt-get install curl gawk sed
```

Or for CentOS:

```bash
sudo yum install curl gawk sed
```

### Download Script

Download the script directly using `curl`:

```bash
curl -O https://raw.githubusercontent.com/russellgrapes/telegram-bash-notification/main/notification.sh
```

### Make the Script Executable

Change the script's permissions to make it executable:

```bash
chmod +x notification.sh
```

### Running the Script

Run the script with the desired message type and content:

```bash
./notification.sh --info -m "This is an informational message"
```

The script will check for required dependencies and prompt to install any that are missing. It will also prompt to create a secrets file if it does not exist.

## Setting up Telegram Bot and Group

To receive alerts from the script, you'll need to set up a Telegram bot and determine the group ID where the bot will send notifications.

### Creating a Telegram Bot

1. Open the Telegram app and search for "@BotFather", the official bot for creating other bots.
2. Send the `/newbot` command to BotFather and follow the instructions to create your bot.
3. After the bot is created, BotFather will provide a token for your new bot. Keep this token secure.

### Getting the Group ID

1. Create a new group in Telegram or use an existing one.
2. Add your newly created bot to the group as a member.
3. Send a dummy message to the group.
4. Visit `https://api.telegram.org/bot<YourBOTToken>/getUpdates` in your web browser, replacing `<YourBOTToken>` with your bot's token.
5. Look for a JSON response containing `"chat":{"id":` followed by a number. This number is your group ID.

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

Don't forget to give the project a star! Thanks again!

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Author

I write loops to skip out on life's hoops.
