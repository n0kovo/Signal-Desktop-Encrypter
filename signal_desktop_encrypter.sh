#!/usr/bin/env bash

cat <<EOT
 _______ __                     __ _____               __     __                _______                               __              
|     __|__|.-----.-----.---.-.|  |     \.-----.-----.|  |--.|  |_.-----.-----.|    ___|.-----.----.----.--.--.-----.|  |_.-----.----.
|__     |  ||  _  |     |  _  ||  |  --  |  -__|__ --||    < |   _|  _  |  _  ||    ___||     |  __|   _|  |  |  _  ||   _|  -__|   _|
|_______|__||___  |__|__|___._||__|_____/|_____|_____||__|__||____|_____|   __||_______||__|__|____|__| |___  |   __||____|_____|__|  
            |_____|                                                     |__|                            |_____|__|   by n0kovo                   
                                          ~ WELL, WONKY WORKAROUNDS DENOTES DEAF DEVS, DUDE ~ 
EOT
echo

# Define encrypted storage location
CONTAINER_FILE="$HOME/.signal_encrypted_storage"

# Set OS specific options
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        arch=$(uname -i)
        SIGNAL_DIR="$HOME/.config/Signal"
        PROCESS="signal-desktop"
        FS="ext4"
        MOUNT_POINT="$HOME/.signal"
elif [[ "$OSTYPE" == "darwin"* ]]; then
        PROCESS="Signal.app"
        SIGNAL_DIR="$HOME/Library/Application Support/Signal"
        FS="APFS"
        MOUNT_POINT="/Volumes/signal"
fi

# Check if VeraCrypt is installed
if ! [ -x "$(command -v veracrypt)" ]; then
        echo 'Error: VeraCrypt not found!' >&2

        # Check if Homebrew is installed if we're on MacOS
        if [[ "$OSTYPE" == *"darwin"* ]]; then
                if [ -x "$(command -v brew)" ]; then
                        while true; do
                                read -p "Do you want to install it using Homebrew? (yes/no) " yn

                                case $yn in
                                        # Install using brew
                                        yes ) if ! brew install veracrypt; then
                                                        echo "Error: Could not install VeraCrypt using Homebrew."; exit 1;
                                                fi
                                                break;;
                                        no ) echo Exiting...;
                                                break;;
                                        * ) echo invalid response;;
                                esac
                        done
                else
                        while true; do
                                # Ask to install Homebrew
                                brew_installer="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

                                echo "You can install VeraCrypt using the MacOS package manager 'Homebrew',"
                                echo "or you can download it from https://www.veracrypt.fr/ and install it manually."
                                read -p "Do you want the script to install Homebrew and use it to get VeraCrypt? (yes/no) " yn

                                case $yn in
                                        # Install Homebrew
                                        yes ) /bin/bash -c "$(curl -fsSL $brew_installer)";
                                                break;;
                                        no ) echo Exiting...;
                                                exit;;
                                        * ) echo invalid response;;
                                esac
                        done
                fi

        else
            # We're on Linux:

            while true; do
                    read -p "Do you want the script to attempt to download and install it automatically? (yes/no) " yn

                    case $yn in
                            # Find latest VeraCrypt version installer URL
                            yes ) VERACRYPT_URL=$(curl https://www.veracrypt.fr/en/Downloads.html | grep -A1 "Generic Installers" | grep -o 'https://launchpad.net.*\.bz2' | sed 's/&#43;/+/g;') || echo "error";
                                    if [[ "$VERACRYPT_URL" == "error"* ]]; then
                                            echo "Error: Could not locate VeraCrypt installer URL. Please install manually."; exit 1;
                                    fi
                                    
                                    TEMP_INSTALLER_DIR="/tmp/veracrypt_installer";
                                    mkdir $TEMP_INSTALLER_DIR;
                                    INSTALLER_ARCHIVE=$TEMP_INSTALLER_DIR/veracrypt.bz2;

                                    # Download to /tmp/veracrypt_installer
                                    if ! wget "$VERACRYPT_URL" -O "$INSTALLER_ARCHIVE"; then
                                            echo "ERROR: Could not download VeraCrypt. Please install it manually."; exit 1
                                    fi
                                    echo "TEMP_INSTALLER_DIR = $TEMP_INSTALLER_DIR";
                                    echo "INSTALLER_ARCHIVE = $INSTALLER_ARCHIVE";
                                    echo "Running tar";
                                    
                                    # Extract archive
                                    if ! tar -xf "$INSTALLER_ARCHIVE" -C "$TEMP_INSTALLER_DIR"; then
                                            echo "Error: Could not extract VeraCrypt archive. Please install it manually."; echo "Deleting temporary files..."; rm -rf $TEMP_INSTALLER_DIR; exit 1;
                                    fi

                                    #Determine machine architecture
                                    arch=$(uname --machine);
                                    echo "arch = $arch";
                                    
                                    # Run suitable installer
                                    shopt -s globstar;
                                    if [[ $arch == x86_64* ]]; then
                                            INSTALLER=$TEMP_INSTALLER_DIR/*setup-console*x64**;
                                            echo "INSTALLER = $INSTALLER";
                                            if ! $INSTALLER; then
                                                    echo 'Error: VeraCrypt installer failed. Please install manually.'; echo "Deleting temporary files..."; rm -rf $TEMP_INSTALLER_DIR; exit 1;
                                            fi
                                    elif [[ $arch == i*86* ]]; then
                                            INSTALLER=$INSTALLER_PATH/*setup-console*x86**;
                                            echo "INSTALLER = $INSTALLER";
                                            if ! $INSTALLER; then
                                                    echo 'Error: VeraCrypt installer failed. Please install manually.'; rm -rf $TEMP_INSTALLER_DIR; exit 1;
                                            fi
                                    else
                                            echo "Error: Could not locate VeraCrypt installer. Please install manually."; rm -rf $TEMP_INSTALLER_DIR; exit 1;
                                    fi

                                    break;;
                            no ) echo Exiting...;
                                    break;;
                            * ) echo invalid response;;
                    esac
            done
        fi

fi

# Locate data directory
if [ ! -d "$SIGNAL_DIR" ]; then
        echo "Could not locate Signal directory!"
        exit 2
fi

# Check if Signal is running
SIGNAL_PROCESSES=$(ps aux | grep -v grep | grep -ci $PROCESS)

# If so, tell user to exit
if [ $SIGNAL_PROCESSES -gt 0 ]; then
        echo "Signal is currently running. \
        Please exit the application before running this script."
        exit 16
fi

# Calculate data size
SIGNAL_SIZE=$(find "$SIGNAL_DIR" -type f -exec ls -l {} \; | awk '{sum += $5} END {print sum}')
if ! [ $? -eq 0 ]; then
        echo "ERROR! Could not calculate size og Signal directory."
        exit 1
fi

# Convert to human readable
SIGNAL_SIZE_HUMAN=$(numfmt --to iec --format "%8.1f" "$SIGNAL_SIZE" | xargs)
if ! [ $? -eq 0 ]; then
        echo "ERROR! Could not convert Signal directory size to human readable format."
        exit 1
fi

# Inform and prompt user
echo -e "\nThe script will now set up a VeraCrypt encrypted volume for storing your Signal data."
echo "The encrypted container will be stored at '$CONTAINER_FILE'"
echo -e "You can press Ctrl+c any time to exit and start over.\n"
echo "NOTE: This script will clear the terminal! Make sure to run it in a session where that is OK!"
echo "Also, you should probably backup you Signal data directory before continuing, in case the script bugs out."
echo -e "It is located here: $SIGNAL_DIR\n"
read -p "Press ENTER to continue or Ctrl+c to cancel..."
clear
while true; do
        echo "Do you want the script to automatically select sensible encryption/hashing/file system options? (easy mode)"
        read -p "This means AES / SHA-512, no PIM, no keyfile, no hidden volume (yes/no) " yn

        case $yn in
                yes ) ADVANCED_OPTIONS=false;
                        break;;
                no )  ADVANCED_OPTIONS=true;
                        break;;
                * ) echo invalid response;;
        esac
done

echo -e "\n\n\t\t\t\t[ENCRYPTION SETUP]\n"
echo -e "\nFor help, see https://veracrypt.fr/en/Documentation.html\n"
echo "Please select a size for the encrypted storage, at least large enough to fit the current data."
echo -e "Also take into account how much space you might need in the future as your data grows!\n"
echo "The size of your Signal data directory is currently $SIGNAL_SIZE_HUMAN"
echo "(Note: Do not select the 'max' option as it will fill your drive.)"

# Run VeraCrypt CLI volume creation wizard
if [ "$ADVANCED_OPTIONS" = false ] ; then
    veracrypt -t --create --encryption=aes --hash=sha512 --volume-type=normal -k="" --filesystem=$FS $CONTAINER_FILE
else
    if [[ "$OSTYPE" == *"darwin"* ]]; then
        veracrypt -t --create --filesystem=$FS $CONTAINER_FILE
    else
        veracrypt -t --create $CONTAINER_FILE
    fi
fi

if ! [ $? -eq 0 ] || [ ! -f "$CONTAINER_FILE" ]; then
        echo "Error: Encrypted container not created."
        exit 1
fi

# Mount container
clear
echo "The VeraCrypt volume has been successfully created."
echo "The script will now mount it and transfer your Signal data to it."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo mkdir $MOUNT_POINT 2>/dev/null
fi

if [ "$ADVANCED_OPTIONS" = false ] ; then
    veracrypt -t -k "" --protect-hidden=no --mount $CONTAINER_FILE $MOUNT_POINT 
else
    veracrypt -t --mount $CONTAINER_FILE 
fi

if ! [ $? -eq 0 ] || [ ! -f "$CONTAINER_FILE" ]; then
        echo "Error: Encrypted container not mounted."
        exit 1
fi

# Move data
sudo chown -R $USER: $MOUNT_POINT
if ! mv $SIGNAL_DIR $MOUNT_POINT; then
    echo "Error: Could not move Signal data to container. Please make sure you specified an adequate size."
    exit 1
fi

# Create symlink
if ! ln -s $MOUNT_POINT/Signal $SIGNAL_DIR; then
    echo "Error: Could not create soft symlink from $SIGNAL_DIR to $MOUNT_POINT/Signal."
    echo "Moving data back i place..."
    unlink $SIGNAL_DIR 2>/dev/null 
    mkdir $SIGNAL_DIR && mv -i $MOUNT_POINT/Signal/* $SIGNAL_DIR
    if ! mv $SIGNAL_DIR $MOUNT_POINT; then
        echo "Error: Could not move data back from $MOUNT_POINT/Signal to $SIGNAL_DIR!"
    fi
    exit 1
fi
clear
# Make user check if symlink works and data can load
clear
echo -e "\nNow please open Signal Desktop and verify that you data is loading as usual."
while true; do
        read -p "Does Signal load your account successfully? (yes/no) " yn

        case $yn in
                yes ) break;;

                no ) echo "Sorry! Seems like we have some debugging to do :/";
                    echo "(please open an issue on GitHub and provide as much information as you can!)";
                        exit 1;;
                * ) echo invalid response;;
        esac
done
clear
echo "The script will now dismount the encrypted container, making your Signal data inaccessible without your password."
echo "Please make sure you remember it or store it in a password manager."
echo -e "Also, please exit Signal Desktop before continuing!\n"

read -p "Press ENTER to continue... "
clear

# Dismount container
if ! veracrypt -t --dismount $CONTAINER_FILE -f; then
    echo "Error: Could not dismount VeraCrypt container. Please check the VeraCrypt GUI."
    exit 1
fi

# Offer to create launcher app if on MacOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    while true; do
        echo "The script can create a launcher app for Signal that will automatically ask for your password,"
        echo "mount your encrypted Signal data directory, open Signal and then automatically unmount the"
        echo "encrypted container once you exit Signal, encrypting your data again. (The launcher is"
        echo "technically an 'Automator Application Stub' containing a workflow that runs a shell script."
        echo -e "Check out launcher.tar.gz for more details)\n"
        echo "If you choose 'no', you will have to manually mount/unmount $CONTAINER_FILE in VeraCrypt before/after using Signal!"
        read -p "Create launcher app in /Applications? (yes/no) " yn
        clear
        case $yn in
                yes ) if [ ! -f "launcher.tar.gz" ]; then
                            # Download launcher archive if not found in CWD
                            if ! wget https://github.com/n0kovo/Signal-Desktop-Encrypter/raw/main/launcher.tar.gz; then
                                echo "Error: Could not find launcher.tar.gz in the current directory,";
                                echo "and downloading the file was unsuccessful.";
                                exit 1;
                            fi
                        fi

                        # Extract launcher archive
                        if ! tar zxvf launcher.tar.gz -C /Applications; then
                            echo "Error: Could not extract launcher.tar.gz to /Applications";
                            exit 1;
                        fi

                        # Replace values in workflow file
                        if ! perl -pi -e s,CONTAINER_FILE,$CONTAINER_FILE,g /Applications/Launcher.app/Contents/document.wflow; then
                            echo "Error: Could not customize parameters in workflow file.";
                            exit  1;
                        fi

                        if ! perl -pi -e s,MOUNT_POINT,$MOUNT_POINT,g /Applications/Launcher.app/Contents/document.wflow; then
                            echo "Error: Could not customize parameters in workflow file.";
                            exit  1;
                        fi
                        
                        # Rename launcher
                        if ! mv "/Applications/Launcher.app" "/Applications/Signal Encrypted.app"; then
                            echo "Error: Could not rename launcher.";
                            exit 1;
                        fi
                            
                            echo -e "\nLauncher is now located at '/Applications/Signal Encrypted.app'"
                            echo "Do not move or rename the original Signal app. Then the launcher won't be able to locate it."
                            echo -e "\n"
                                exit 0;;

                no ) break;;

                * ) echo invalid response;;
        esac

    done
    # Done, exit
    echo -e "\nEverything should be set up. Have a nice day!"
    echo -e "(Created with \033[0;31m<3\033[0m by \033[0;34m@n0kovo@infosec.exchange\033[0m)\n";
    exit 0

else

    # Offer to create shell script launcher if on Linux
    echo "The script can create a shell script for you that will prompt you for your password,"
    echo "mount your encrypted Signal data directory, open Signal and then automatically unmount the"
    echo -e "encrypted container once you exit Signal, encrypting your data again.\n"
    echo "If you choose 'no', you will have to manually mount/unmount '$CONTAINER_FILE' in VeraCrypt"
    echo "before/after using Signal!"
    
    while true; do
            read -p "Create Signal launcher script? (yes/no) " yn
            clear
            case $yn in
                    yes ) break;;

                    no ) echo -e "\nEverything should be set up. Have a nice day!";
                        echo -e "(Created with \033[0;31m<3\033[0m by \033[0;34m@n0kovo@infosec.exchange\033[0m)\n";
                            exit 0;;
                    * ) echo invalid response;;
            esac
    done
fi

# Create launcher script in /tmp first
LAUNCHER_PATH="/usr/local/bin/signal_launcher"
rm -f $LAUNCHER_PATH 2>/dev/null
cat <<EOF >> /tmp/signal_launcher
# Mount container
veracrypt --mount "$CONTAINER_FILE" "$MOUNT_POINT"
sleep 5

# Remove dead symlink if present
unlink "$SIGNAL_DIR" 2>/dev/null

# Symlink local Signal data dir to dir in container
ln -s "$MOUNT_POINT/Signal" "$SIGNAL_DIR"

# Run Signal
nohup signal-desktop >/dev/null 2>&1 &

# Wait for Signal to start
while ! ps aux | grep -v grep | grep -ci "$PROCESS"; do sleep 2; done

# Create background process to dismount as soon as Signal exits
nohup bash -c 'sleep 20; while true; do if ps aux | grep -v grep | grep -ci "$PROCESS"; then sleep 5; else veracrypt -t --dismount "$CONTAINER_FILE"; exit 0; fi; done' >/dev/null 2>&1 &
EOF

# Move launcher script in place
sudo mv "/tmp/signal_launcher" "$LAUNCHER_PATH"

# Make launcher script executable
sudo chmod +x $LAUNCHER_PATH

echo -e "\nLauncher script installed as '$LAUNCHER_PATH'"
echo -e "\nEverything should be set up. Have a nice day!";
echo -e "(Created with \033[0;31m<3\033[0m by \033[0;34m@n0kovo@infosec.exchange\033[0m)\n";
exit 0
