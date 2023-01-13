#!/usr/bin/env bash
#   _____      _ _ _____      ______ _     _     _     
#  |  ___|    (_) |  __ \     | ___ \ |   (_)   | |    
#  | |____   ___| | |  \/ ___ | |_/ / |__  _ ___| |__  
#  |  __\ \ / / | | | __ / _ \|  __/| '_ \| / __| '_ \ 
#  | |___\ V /| | | |_\ \ (_) | |   | | | | \__ \ | | |
#  \____/ \_/ |_|_|\____/\___/\_|   |_| |_|_|___/_| |_|
#                                                      
#  Credit: https://github.com/fin3ss3g0d/evilgophish                                                    


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


# These variables are empty scine we don't know until user enters in
root_domain=${root_domain}
evilginx2_subs=${evilginx2_subs}
e_root_bool=${e_root_bool}
redirect_url=${redirect_url}
feed_bool=${feed_bool}
rid_replacement=${rid_replacement}
bl_bool=${bl_bool}
api_key=${api_key}
smtp_password=${smtp_password}

# List of items to install:
apt_items_to_install=(dialog wget git)

# Evilgophish Home Directory
EVILGOPHISH_HOME_DIR=/etc/.evilgophish

# DenSecure Evilgophish Github Repository
densecureegpGitURL="https://github.com/wolfandco/evilgophish"

# Mailgun URL
mailgun_url="https://api.mailgun.net/v4/domains"

show_ascii_egp(){

echo " _____      _ _ _____      ______ _     _     _     ";
echo "|  ___|    (_) |  __ \     | ___ \ |   (_)   | |    ";
echo "| |____   ___| | |  \/ ___ | |_/ / |__  _ ___| |__  ";
echo "|  __\ \ / / | | | __ / _ \|  __/| '_ \| / __| '_ \ ";
echo "| |___\ V /| | | |_\ \ (_) | |   | | | | \__ \ | | |";
echo "\____/ \_/ |_|_|\____/\___/\_|   |_| |_|_|___/_| |_|";
echo "                                                    ";
echo "Credit: https://github.com/fin3ss3g0d/evilgophish   ";

}

is_command() {
    # Checks to see if the given command (passed as a string argument) exists on the system.
    # The function returns 0 (success) if the command exists, and 1 if it doesn't.
    local check_command="$1"

    command -v "${check_command}" >/dev/null 2>&1
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
            --msgbox "\\n\\nThis software is free to use and all credits should be given to https://github.com/fin3ss3g0d" \
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
                printf " %b Installer exited at root domain message.\\n" "${INFO}"
                exit 1
                ;;
        esac


}

verify_urls(){

    regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
    string=$1
    if [[ $1 =~ $regex ]] ; then
        :
    else
        dialog --no-shadow --keep-tite \
        --ok-label "Exit" \
        --title "Invalid URL" \
        --msgbox "Invalid URL Entered" \
        "${r}" "${c}"
        exit 1
    fi

}

install_depends_for_this_script(){

    # Good ol' APT
    apt update && apt install ${apt_items_to_install} &> /dev/null

}

set_vars(){

    phishingInformationCorrect=false
    until [[ "${phishingInformationCorrect}" = true ]]; do
        #Ask user for all variables in varying prompts
        root_domain=$(dialog --noshadow --keep-tite \
            --ok-label "Submit" \
            --backtitle "Root Domain Info" \
            --title "Root Domain Info" \
            --form "\\n\\nEnter root domain (i.e. 'example.com')" \
        20 70 0 \
            "Root Domain:"      1 1 "${root_domain}"        1 15 40 0 \
            3>&1 1>&2 2>&3 3>&-)

        result1=$?

        case ${result1} in 
            "${DIALOG_CANCEL}" | "${DIALOG_ESC}")
            printf "%bCancel was selected, exiting installer%b\\n" "${COL_LIGHT_RED}" "${COL_NC}"
            exit 1
            ;;
        esac

        if [[ -z ${root_domain} ]]; then
            printf "%bNothing was entered, exiting...%b\\n" "${COL_LIGHT_RED}" ${COL_NC}
            exit 1
        fi

        evilginx2_subs=$(dialog --noshadow --keep-tite \
            --ok-label "Submit" \
            --backtitle "Subdomain Info" \
            --title "Subdomain Info" \
            --form "\\n\\nEnter Subdomains (i.e. 'account myaccount')" \
        20 70 0 \
            "Subdomain(s):"      1 1 "${evilginx2_subs}"        1 15 40 0 \
            3>&1 1>&2 2>&3 3>&-)

        result1=$?

        case ${result1} in 
            "${DIALOG_CANCEL}" | "${DIALOG_ESC}")
            printf "%bCancel was selected, exiting installer%b\\n" "${COL_LIGHT_RED}" "${COL_NC}"
            exit 1
            ;;
        esac

        if [[ -z ${evilginx2_subs} ]]; then
            printf "%bNothing was entered, exiting...%b" "${COL_LIGHT_RED}" "${COL_NC}"
            exit 1
        fi

        redirect_url=$(dialog --noshadow --keep-tite \
            --ok-label "Submit" \
            --backtitle "Redirect URL" \
            --title "Redirect URL" \
            --form "\\n\\nEnter redirect url (i.e. 'https://redirect.com/')" \
        20 70 0 \
            "Redirect URL:"      1 1 "${redirect_url}"        1 15 40 0 \
            3>&1 1>&2 2>&3 3>&-)

        result1=$?

        case ${result1} in 
            "${DIALOG_CANCEL}" | "${DIALOG_ESC}")
            printf "%bCancel was selected, exiting installer%b\\n" "${COL_LIGHT_RED}" "${COL_NC}"
            exit 1
            ;;
        esac

        if [[ -z ${redirect_url} ]]; then
            printf "%bNothing was entered, exiting...%b" "${COL_LIGHT_RED}" "${COL_NC}"
            exit 1
        fi

        verify_urls "${redirect_url}"

        rid_replacement=$(dialog --noshadow --keep-tite \
            --ok-label "Submit" \
            --backtitle "RID Replacement" \
            --title "RID Replacement" \
            --form "\\n\\nEnter RID Replacement (i.e. 'user_id')" \
        20 70 0 \
            "RID Replacement:"      1 1 "${rid_replacement}"        1 20 40 0 \
            3>&1 1>&2 2>&3 3>&-)

        result1=$?

        case ${result1} in 
            "${DIALOG_CANCEL}" | "${DIALOG_ESC}")
            printf "%bCancel was selected, exiting installer%b\\n" "${COL_LIGHT_RED}" "${COL_NC}"
            exit 1
            ;;
        esac

        if [[ -z ${rid_replacement} ]]; then
            printf "%bNothing was entered, exiting...%b" "${COL_LIGHT_RED}" "${COL_NC}"
            exit 1
        fi

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
            "${r}" "${c}" && phishingInformationCorrect=true
    done
    mailgun_setup

}

mailgun_setup(){

    dialog --no-shadow --keep-tite \
        --backtitle "Use Mailgun Confirmation" \
        --title "Use Mailgun Confirmation" \
        --defaultno \
        --yesno "\\n\\nWould you like to use Mailgun for SMTP setup?" \
        "${r}" "${c}" && result=0 || result=$?

    case ${result} in 
            "${DIALOG_OK}")
                mailgun_bool=true
                ;;
            "${DIALOG_CANCEL}")
                mailgun_bool=false
                ;;
            "${DIALOG_ESC}")
                # User pressed <ESC>
                printf "  %b Escape pressed, exiting installer.%b\\n" "${COL_LIGHT_RED}" "${COL_NC}"
                exit 1
                ;;
    esac

    if [[ "${mailgun_bool}" = true ]]; then

        api_keys=$(dialog --noshadow --keep-tite \
            --ok-label "Submit" \
            --backtitle "Mailgun API Key" \
            --title "Mailgun API Key" \
            --form "\\n\\nEnter Mailgun API Key Info (https://app.mailgun.com/app/account/security/api_keys) Allows for copy + paste" \
        20 70 0 \
            "API Key:"      1 1 "${api_key}"        1 15 60 0 \
            3>&1 1>&2 2>&3 3>&-)

        result1=$?

        case ${result1} in 
            "${DIALOG_CANCEL}" | "${DIALOG_ESC}")
            printf "%bCancel was selected, exiting installer%b\\n" "${COL_LIGHT_RED}" "${COL_NC}"
            exit 1
            ;;
        esac

        if [[ -z ${api_key} ]]; then
            printf "%bNothing was entered, exiting...%b" "${COL_LIGHT_RED}" "${COL_NC}"
            exit 1
        fi

        smtp_password=$(dialog --no-shadow --keep-tite \
            --no-label "SMTP Password" \
            --backtitle "SMTP Password" \
            --title "Enter super secret Mailgun SMTP Password" \
            --form "\\n\\nEnter your Mailgun SMTP Password (This will be input into GoPhish) Allows for copy + paste.\\n"\
            20 90 0 \
                "Mailgun SMTP Password:" 1 1 ${smtp_password} 1 20 40 0 \
            3>&1 1>&2 2>&3 3>&-)

            result1=$?

            case ${result1} in 
                "${DIALOG_CANCEL}" | "${DIALOG_ESC}")
                printf "%bCancel was selected, exiting installer%b\\n" "${COL_LIGHT_RED}" "${COL_NC}"
                exit 1
                ;;
            esac

            if [[ -z ${smtp_password} ]]; then
                printf "%bNothing was entered, exiting...%b" "${COL_LIGHT_RED}" "${COL_NC}"
                exit 1
            fi

        curl -s --user "api:${mailgun}" \
         -X POST ${mailgun_url} \
         -F name="${root_domain}" \
         -F smtp_password="${smtp_password}"

    else
        printf "%bMailgun not used.%b\\n" "${COL_LIGHT_RED}" "${COL_NC}"
        :
    fi
    git_clone_and_setup_script

}


git_clone_and_setup_script(){

    # Make directory 
    if [ ! -d "${EVILGOPHISH_HOME_DIR}" ]; then
        mkdir "${EVILGOPHISH_HOME_DIR}" > /dev/null
    fi
    # Clone into /etc/.evilgophish
    git clone "${densecureegpGitURL}" "${EVILGOPHISH_HOME_DIR}" > /dev/null
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
                exec curl -sSL https://raw.githubusercontent.com/stevesec/egp_basicinstall/main/basic_install.sh | sudo bash "$@"
            else
                # when run via calling local bash script
                exec sudo bash "$0" "$@"
            fi

            exit $?
        else
             # Otherwise, tell the user they need to run the script as root, and bail
            printf "%b  %b Sudo utility check\\n" "${OVER}" "${CROSS}"
            printf "  %b Sudo is needed for EvilGoPhish\\n\\n" "${INFO}"
            printf "  %b %bPlease re-run this installer as root${COL_NC}\\n" "${INFO}" "${COL_LIGHT_RED}"
            exit 1
        fi
    fi

    # Install Dependencies
    install_depends_for_this_script

    # Display welcome dialogs
    welcomeDialogs

    # Set Variables
    set_vars

    # Success
    printf " %b %bRemember to grab your SMTP Password: ${smtp_password} and enter it into GoPhish!${COL_NC}\\n" "${INFO}" "${COL_LIGHT_RED}"
    printf " %b You have successfully deployed EvilGoPhish. Have a nice phish!${COL_NC}\\n" "${COL_LIGHT_GREEN}"

}

main
