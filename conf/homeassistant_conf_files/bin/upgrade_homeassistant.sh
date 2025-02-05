#!/bin/bash
#
# upgrade_homeassistant.sh - Simple shell script to upgrade homeassistant installed in a python environnement
#

# Uncomment to enable debugging to stderr (prints full client output and more)
DEBUG=0

# define usefull variables
app="homeassistant"
final_path="/var/www/$app"
data_path="/home/yunohost.app/$app"

########## END OF CONFIGURATION ##########


########## SCRIPT CODE FOLLOWS, DON'T TOUCH!  ##########

# Log messages to log file.
log() {
        echo "$(date)\t$1" >> $LOG_FILE
}

has_sudo() {
        local prompt
        prompt=$(sudo -nv 2>&1)
        if [ $? -eq 0 ]; then
                echo "has sudo pass set"
        elif echo $prompt | grep -q '^sudo:'; then
                echo "has sudo needs pass"
        else
                echo "can't sudo"
        fi
}

# Reset log file.
if [ ! -z "$DEBUG" ]; then
        LOG_FILE=$(cd -P -- "$(dirname -- "$0")" && pwd -P)"/upgrade_homeassistant.log"
        [ -f "$LOG_FILE" ] && :> "$LOG_FILE"
fi

# Check User and permissions
[ ! -z "$DEBUG" ] && log "User '$(whoami)' is running that script and '$(has_sudo)'."

# upgrade the virtual environment
MY_PYTHON=$(readlink -e "$final_path/bin/python")
[ ! -z "$DEBUG" ] && log "Using pyhton '$MY_PYTHON'."
$MY_PYTHON -m venv --upgrade "$final_path"

# activate the virtual environment
source "$final_path/bin/activate"

# install last version of wheel
pip --cache-dir "$data_path/.cache" install --upgrade wheel

# install last version of mysqlclient
pip --cache-dir "$data_path/.cache" install --upgrade mysqlclient

# upgrade homeassistant python package
pip --cache-dir "$data_path/.cache" install --upgrade $app

# restart homeassistant systemd service
sudo systemctl restart $app.service
[ ! -z "$DEBUG" ] && log "Last $app service start : $(sudo systemctl status $app.service | grep Started | tail -1)"

exit 0
