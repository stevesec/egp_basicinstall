#!/usr/bin/env bash
#   _____      _ _ _____      ______ _     _     _     
#  |  ___|    (_) |  __ \     | ___ \ |   (_)   | |    
#  | |____   ___| | |  \/ ___ | |_/ / |__  _ ___| |__  
#  |  __\ \ / / | | | __ / _ \|  __/| '_ \| / __| '_ \ 
#  | |___\ V /| | | |_\ \ (_) | |   | | | | \__ \ | | |
#  \____/ \_/ |_|_|\____/\___/\_|   |_| |_|_|___/_| |_|
#                                                      
#                                                      


INFO='[i]'

# Dialog result codes
# dialog code values can be set by environment variables, we only override if
# the env var is not set or empty.
: "${DIALOG_OK:=0}"
: "${DIALOG_CANCEL:=1}"
: "${DIALOG_ESC:=255}"

# dialog dimensions: Let dialog handle appropriate sizing.
r=20
c=70

# Set these values so the installer can still run in color
COL_NC='\e[0m' # No Color
COL_LIGHT_GREEN='\e[1;32m'
COL_LIGHT_RED='\e[1;31m'
TICK="[${COL_LIGHT_GREEN}✓${COL_NC}]"
CROSS="[${COL_LIGHT_RED}✗${COL_NC}]"
INFO="[i]"
# shellcheck disable=SC2034
DONE="${COL_LIGHT_GREEN} done!${COL_NC}"
OVER="\\r\\033[K"


# Script needs a root domain, these variables are empty scine we don't know until user enters in
root_domain=${root_domain}
evilginx2_subs=${evilginx2_subs}
e_root_bool=${e_root_bool}
redirect_url=${redirect_url}
feed_bool=${feed_bool}
rid_replacement=${rid_replacement}
evilginx2_dir=$HOME/.evilginx
bl_bool=${bl_bool}
phishing=${phishing}
bools=${bools}

# List of items to install:
apt_items_to_install=(dialog wget git)

# This directory is where all logs happen
GOPHISH_ERROR_DIRECTORY="/var/log/gophish/gophish.log"

# Default web directory
web_dir=/var/www/html

# Evilgophish Home Directory
EVILGOPHISH_HOME_DIR=/etc/.evilgophish

# Evilgophish Github Repository
evilgophishGitURL="https://github.com/wolfandco/evilgophish"

show_ascii_egp(){

echo " _____      _ _ _____      ______ _     _     _     ";
echo "|  ___|    (_) |  __ \     | ___ \ |   (_)   | |    ";
echo "| |____   ___| | |  \/ ___ | |_/ / |__  _ ___| |__  ";
echo "|  __\ \ / / | | | __ / _ \|  __/| '_ \| / __| '_ \ ";
echo "| |___\ V /| | | |_\ \ (_) | |   | | | | \__ \ | | |";
echo "\____/ \_/ |_|_|\____/\___/\_|   |_| |_|_|___/_| |_|";
echo "                                                    ";
echo "                                                    ";

}

welcomeDialogs(){

    # Display the welcome dialog using an appropriately sized window via the calculation conducted earler in the script
    dialog --no-shadow --clear --keep-tite \
        --backtitle "Welcome" \
            --title "Evilgophish Installer" \
            --msgbox "\\n\\nThis installer will transform your device into a grand ol' phishing device!" \
            "${r}" "${c}" \
            --and-widget --clear \
        --backtitle "Support SteveSec" \
            --title "Open Source Software" \
            --msgbox "\\n\\nThis software is free to use and credits should be given to https://github.com/fin3ss3g0d" \
            "${r}" "${c}" \
            --and-widget --clear \
        --colors \
            --backtitle "Starting Preparation For Phishing" \
            --title "Proper DNS Records Needed" \
            --no-button "Exit" --yes-button "Continue" \
            --defaultno \
            --yesno "\\nEvilgophish needs a root domain in order to phish from and create a landing page.\\n \
            IMPORTANT:\\Zn If you have not already done so, ensure that have assigned the proper DNS records.\
            Our recommendation is to get a domain through Cloudflare \\n\\n\
            Please continue when the DNS records have been configured."\
            "${r}" "${c}" && result=0 || result="$?"

        case "${result}" in
            "${DIALOG_CANCEL}" | "${DIALOG_ESC}")
                printf " %b Installer exited at root doamin message.\\n" "${INFO}"
                exit 1
                ;;
        esac


}

install_depends_for_this_script(){

    # Good ol' APT
    apt update && apt install ${apt_items_to_install} &> /dev/null

}

set_vars(){

    phishingInformationCorrect=false
    until [[ "${phishingInformationCorrect}" = True ]]; do
        #Ask user for all variables in varying prompts
        root_domain=$(dialog --noshadow --keep-tite \
            --ok-label "Submit" \
            --backtitle "Root Domain Info" \
            --title "Root Domain Info" \
            --form "Enter root domain" \
        20 70 0 \
            "Root Domain:"      1 1 "${root_domain}"        1 15 40 0 \
            3>&1 1>&2 2>&3 3>&-)

        result1=$?

        case ${result1} in 
            "${DIALOG_CANCEL}" | "${DIALOG_ESC}")
            printf " %b Cancel was selected, exiting installer%b\\n" "${COL_LIGHT_RED}" "${COL_NC}"
            exit 1
            ;;
        esac

        evilginx2_subs=$(dialog --noshadow --keep-tite \
            --ok-label "Submit" \
            --backtitle "Subdomain Info" \
            --title "Subdomain Info" \
            --form "Enter Subdomains" \
        20 70 0 \
            "Subdomain(s):"      1 1 "${evilginx2_subs}"        1 15 40 0 \
            3>&1 1>&2 2>&3 3>&-)

        result1=$?

        case ${result1} in 
            "${DIALOG_CANCEL}" | "${DIALOG_ESC}")
            printf " %b Cancel was selected, exiting installer%b\\n" "${COL_LIGHT_RED}" "${COL_NC}"
            exit 1
            ;;
        esac

        redirect_url=$(dialog --noshadow --keep-tite \
            --ok-label "Submit" \
            --backtitle "Redirect URL" \
            --title "Redirect URL" \
            --form "Enter redirect url" \
        20 70 0 \
            "Redirect URL:"      1 1 "${redirect_url}"        1 15 40 0 \
            3>&1 1>&2 2>&3 3>&-)

        result1=$?

        case ${result1} in 
            "${DIALOG_CANCEL}" | "${DIALOG_ESC}")
            printf " %b Cancel was selected, exiting installer%b\\n" "${COL_LIGHT_RED}" "${COL_NC}"
            exit 1
            ;;
        esac


        rid_replacement=$(dialog --noshadow --keep-tite \
            --ok-label "Submit" \
            --backtitle "RID Replacement" \
            --title "RID Replacement" \
            --form "Enter RID Replacement" \
        20 70 0 \
            "RID Replacement:"      1 1 "${rid_replacement}"        1 20 40 0 \
            3>&1 1>&2 2>&3 3>&-)

        result1=$?

        case ${result1} in 
            "${DIALOG_CANCEL}" | "${DIALOG_ESC}")
            printf " %b Cancel was selected, exiting installer%b\\n" "${COL_LIGHT_RED}" "${COL_NC}"
            exit 1
            ;;
        esac

        # Set Boolean (Yes or no)
        dialog --no-shadow --keep-tite \
            --backtitle "Root Domain Boolean" \
            --title "Enable Root Domain Boolean" \
            --defaultno \
            --yesno "\\n\\nWould you like to set the proxy root domain to Evilginx2?" \
            "${r}" "${c}" && result=0 || result=$?

        case ${result} in 
            "${DIALOG_OK}")
                e_root_bool=true
                ;;
            "${DIALOG_CANCEL}")
                e_root_bool=false
                ;;
            "${DIALOG_ESC}")
                # User pressed <ESC>
                printf "  %b Escape pressed, exiting installer.%b\\n" "${COL_LIGHT_RED}" "${COL_NC}"
                exit 1
                ;;
        esac

        dialog --no-shadow --keep-tite \
            --backtitle "Feed Boolean" \
            --title "Enable Live Feed" \
            --defaultno \
            --yesno "\\n\\nWould you like to enable the live feed?" \
            "${r}" "${c}" && result=0 || result=$?

        case ${result} in 
            "${DIALOG_OK}")
                feed_bool=true
                ;;
            "${DIALOG_CANCEL}")
                feed_bool=false
                ;;
            "${DIALOG_ESC}")
                # User pressed <ESC>
                printf "  %b Escape pressed, exiting installer.%b\\n" "${COL_LIGHT_RED}" "${COL_NC}"
                exit 1
                ;;
        esac    

        dialog --no-shadow --keep-tite \
            --backtitle "Apache Blacklist" \
            --title "Enable Apache Blacklist" \
            --defaultno \
            --yesno "\\n\\nWould you like to enable the Apache blacklist?" \
            "${r}" "${c}" && result=0 || result=$?

        case ${result} in 
            "${DIALOG_OK}")
                bl_bool=true
                ;;
            "${DIALOG_CANCEL}")
                bl_bool=false
                ;;
            "${DIALOG_ESC}")
                # User pressed <ESC>
                printf "  %b Escape pressed, exiting installer.%b\\n" "${COL_LIGHT_RED}" "${COL_NC}"
                exit 1
                ;;
        esac

        # Give the user a chance to review their settings before moving on
        dialog --no-shadow --keep-tite \
            --no-label "Edit Settings" \
            --backtitle "Edit User Set Settings" \
            --title "User Settings" \
            --yesno "Are these settings correct?
                Root Domain: ${root_domain}
                Evilginx2 Subdomains: ${evilginx2_subs}
                Redirect URL: ${redirect_url}
                RID Replacement: ${rid_replacement}
                Root Domain Boolean ${e_root_bool}
                Live Feed ${feed_bool}
                Apache Blacklist ${bl_bool}" \
            "${r}" "${c}" && phishingInformationCorrect=True
    done
    git_clone_and_setup_script

}

git_clone_and_setup_script(){

    # Make directory 
    mkdir "${EVILGOPHISH_HOME_DIR}" > /dev/null
    # Clone into /etc/.evilgophish
    git clone "${evilgophishGitURL}" "${EVILGOPHISH_HOME_DIR}" > /dev/null
    # Change directory 
    cd "${EVILGOPHISH_HOME_DIR}" > /dev/null
    # Run it!
    ./setup.sh "${root_domain}" "${evilginx2_subs}" "${e_root_bool}" \
    "${redirect_url}" "${feed_bool}" "${rid_replacement}" "${bl_bool}"

}

main () {
    local str="Root user check"
    printf "\\n"

    # If the user's id is zero,
    if [[ "${EUID}" -eq 0 ]]; then
        # they are root and all is good
        printf "  %b %s\\n" "${TICK}" "${str}"
        # Show EGP logo
        show_ascii_egp
    else
        # Otherwise, they do not have enough privileges, so let the user know
        printf "  %b %s\\n" "${INFO}" "${str}"
        printf "  %b %bScript called with non-root privileges%b\\n" "${INFO}" "${COL_LIGHT_RED}" "${COL_NC}"
        printf "      Evilgophish requires elevated privileges to install and run\\n"
        printf "      Please check the installer for any concerns regarding this requirement\\n"
        printf "      Make sure to download this script from a trusted source\\n\\n"
        printf "  %b Sudo utility check" "${INFO}"

        if is_command sudo ; then
            printf "%b  %b Sudo utility check\\n" "${OVER}"  "${TICK}"

            # when run via curl piping
            if [[ "$0" == "bash" ]]; then
                # Download the install script and run it with admin rights
                exec curl -sSL  | sudo bash "$@"
            else
                # when run via calling local bash script
                exec sudo bash "$0" "$@"
            fi

            exit $?
        else
             # Otherwise, tell the user they need to run the script as root, and bail
            printf "%b  %b Sudo utility check\\n" "${OVER}" "${CROSS}"
            printf "  %b Sudo is needed for the Web Interface to run pihole commands\\n\\n" "${INFO}"
            printf "  %b %bPlease re-run this installer as root${COL_NC}\\n" "${INFO}" "${COL_LIGHT_RED}"
            exit 1
        fi
    fi

    # Install Dependencies
   # install_depends_for_this_script

    # Display welcome dialogs
    welcomeDialogs

    # Set Variables
    set_vars

}

main
