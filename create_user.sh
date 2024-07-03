#!/bin/bash

# Define paths for log and password files
LOG_FILE="/var/log/user_management.log"
SECURE_DIR="/var/secure"
PASSWORD_FILE="$SECURE_DIR/user_passwords.csv"

# Ensure log directory and file exist
if ! sudo touch "$LOG_FILE"; then
    echo "Failed to create log file at $LOG_FILE"
    exit 1
fi

# Ensure secure directory exists and create password file with correct permissions
if ! sudo mkdir -p "$SECURE_DIR"; then
    echo "Failed to create directory at $SECURE_DIR"
    exit 1
fi

if ! sudo touch "$PASSWORD_FILE"; then
    echo "Failed to create password file at $PASSWORD_FILE"
    exit 1
fi

if ! sudo chmod 700 "$SECURE_DIR"; then
    echo "Failed to set permissions for $SECURE_DIR"
    exit 1
fi

if ! sudo chmod 600 "$PASSWORD_FILE"; then
    echo "Failed to set permissions for $PASSWORD_FILE"
    exit 1
fi

# Function to generate a random password
generate_password() {
    local password_length=12
    tr -dc A-Za-z0-9 </dev/urandom | head -c "$password_length"
}

# Read the input file line by line
while IFS=';' read -r username groups; do
    # Remove leading and trailing whitespaces
    username=$(echo "$username" | xargs)
    groups=$(echo "$groups" | xargs)

    # Skip empty lines
    [ -z "$username" ] && continue

    # Create a personal group for the user
    if ! getent group "$username" > /dev/null; then
        if ! sudo groupadd "$username"; then
            echo "Failed to create group $username" | sudo tee -a "$LOG_FILE"
            continue
        fi
        echo "$(date): Created group $username" | sudo tee -a "$LOG_FILE"
    fi

    # Create the user with their personal group and home directory
    if ! id -u "$username" > /dev/null 2>&1; then
        if ! sudo useradd -m -g "$username" -s /bin/bash "$username"; then
            echo "Failed to create user $username" | sudo tee -a "$LOG_FILE"
            continue
        fi
        echo "$(date): Created user $username with group $username" | sudo tee -a "$LOG_FILE"

        # Generate a random password for the user
        password=$(generate_password)
        
        # Debugging: Print generated password to the console
        echo "Generated password for $username: $password"
        
        # Write username and password to the password file
        echo "$username,$password" | sudo tee -a "$PASSWORD_FILE"
        
        # Debugging: Check if the password was written correctly
        if grep -q "$username,$password" "$PASSWORD_FILE"; then
            echo "$(date): Successfully wrote password for user $username to $PASSWORD_FILE" | sudo tee -a "$LOG_FILE"
        else
            echo "$(date): Failed to write password for user $username to $PASSWORD_FILE" | sudo tee -a "$LOG_FILE"
        fi

        # Set the password for the user
        echo "$username:$password" | sudo chpasswd
        echo "$(date): Set password for user $username" | sudo tee -a "$LOG_FILE"
    else
        echo "$(date): User $username already exists, skipping creation" | sudo tee -a "$LOG_FILE"
    fi

    # Assign user to specified groups
    if [ -n "$groups" ]; then
        IFS=',' read -ra group_array <<< "$groups"
        for group in "${group_array[@]}"; do
            group=$(echo "$group" | xargs)
            if ! getent group "$group" > /dev/null; then
                if ! sudo groupadd "$group"; then
                    echo "Failed to create group $group" | sudo tee -a "$LOG_FILE"
                    continue
                fi
                echo "$(date): Created group $group" | sudo tee -a "$LOG_FILE"
            fi
            if ! sudo usermod -aG "$group" "$username"; then
                echo "Failed to add user $username to group $group" | sudo tee -a "$LOG_FILE"
                continue
            fi
            echo "$(date): Added user $username to group $group" | sudo tee -a "$LOG_FILE"
        done
    fi

done < "$1"

echo "$(date): Script completed" | sudo tee -a "$LOG_FILE"

