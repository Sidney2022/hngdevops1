# Project Name: Automated User and Group Management
## Description
This Bash script automates the creation of users and groups in a Unix-like environment. It reads input from a text file, sets up home directories, generates random passwords, logs actions, and ensures secure password storage.

## Features
User and Group Creation: Creates users and corresponding groups based on input.
Home Directory Setup: Sets up home directories for each user.
Random Password Generation: Generates secure passwords for each user.
Logging: Logs all actions to ```/var/log/user_management.log.```
Secure Password Storage: Stores generated passwords in 
```bash /var/secure/user_passwords.csv``` with restricted permissions.
## Usage
Clone Repository:

```bash
git clone <repository-url>
cd <repository-directory>
```
Prepare Input File:
Create a text file (user_data.txt) with each line formatted as username; groups. For example:
```bash
user1; group1, group2
user2; group2
```
Run Script:
Ensure script is executable:

```bash
chmod +x create_users.sh
```
Execute the script with sudo privileges:

```bash
sudo ./create_users.sh user_data.txt
```
Verify Output:

Check ```/var/log/user_management.log``` for detailed logs.
Verify passwords in ```/var/secure/user_passwords.csv```.
Use system commands (id, grep) to verify user and group creation.
Notes
Ensure proper permissions (sudo) to execute the script.
Customize script variables (LOG_FILE, SECURE_DIR) as per system requirements.
