#!/bin/bash

# Define colors and styles
info_color="\033[0;34m"     # Blue for information
warning_color="\e[1;33m"    # Yellow for warning
error_color="\e[1;31m"      # Red for error
menu_color="\e[1;44m"       # Blue background
highlight_color="\e[1;42m"  # Green background
reset_color="\e[0m"
bold="\e[1m"
normal="\e[0m"

# Initialize variables
selected_options=()
menu_length=8

# Function to print a decorated message
print_message() {
    local text="$1"
    local color="$2"
    local width=$(tput cols)
    local text_length=${#text}
    local border_length=$((width > text_length + 4 ? width : text_length + 4))
    local border_line=""
    
    for ((i=1; i<=border_length; i++)); do
        border_line+="="
    done

    printf "${color}%s${reset_color}\n" "$border_line"
    printf "${color}%*s${reset_color}\n" $(((${#border_line}+$text_length)/2)) "$text"
    printf "${color}%s${reset_color}\n" "$border_line"
}

# Function to display the menu
show_menu() {
    clear
    local menu_text=" Cleanup Script Menu "
    local width=$(tput cols)
    local padding=$(( (width - ${#menu_text}) / 2 ))
    printf "${menu_color}%s${reset_color}\n" "$(printf "%-${width}s")"
    printf "${menu_color}%s${reset_color}\n" "$(printf "%-${width}s" "$(printf "%${padding}s%s" "" "$menu_text")")"
    local author_info="by Wanghley Soares Martins (me@wanghley.com)"
    local padding_author=$(( (width - ${#author_info}) / 2 ))
    printf "${menu_color}%s${reset_color}\n" "$(printf "%-${width}s" "$(printf "%${padding_author}s%s" "" "$author_info")")"
    printf "${menu_color}%s${reset_color}\n" "$(printf "%-${width}s")"
    printf "\n"


    # Print each menu option centered
    for ((i=1; i<=$menu_length; i++)); do
        local option_text=$(get_menu_option_text $i)
        option_text="$i) $option_text"
        local option_length=${#option_text}
        local padding=$(( (width - option_length) / 2 ))

        if [[ " ${selected_options[@]} " =~ " $i " ]]; then
            printf "${highlight_color}${bold}%*s${reset_color}\n" $((padding + option_length)) "$option_text"
        else
            printf "${info_color}%*s${reset_color}\n" $((padding + option_length)) "$option_text"
        fi
    done

    echo
}

# Function to get text for each menu option
get_menu_option_text() {
    case $1 in
        1) echo "Full Update and Cleanup" ;;
        2) echo "Update and Upgrade Homebrew" ;;
        3) echo "Clean Up Homebrew" ;;
        4) echo "Check for Issues" ;;
        5) echo "Update nvm and node" ;;
        6) echo "Update Yarn" ;;
        7) echo "Update Global npm Packages" ;;
        8) echo "Exit" ;;
        *) echo "Invalid Option" ;;
    esac
}

# Function to update and upgrade Homebrew
update_homebrew() {
    print_message "Updating and Upgrading Homebrew" "$info_color"
    {
        brew update
        brew upgrade
        brew upgrade --cask
    } || {
        print_message "Error updating Homebrew" "$error_color"
        return 1
    }
}

# Function to clean up Homebrew
cleanup_homebrew() {
    print_message "Cleaning Up Homebrew" "$info_color"
    {
        brew cleanup --scrub --prune=all
    } || {
        print_message "Error cleaning up Homebrew" "$error_color"
        return 1
    }
}

# Function to check for issues
check_issues() {
    print_message "Checking for Issues" "$info_color"
    {
        brew doctor
        brew missing
    } || {
        print_message "Error checking for issues" "$error_color"
        return 1
    }
}

# Function to update nvm and node
update_nvm_node() {
    print_message "Updating nvm and node" "$info_color"
    {
        export NVM_DIR=~/.nvm
        source ~/.nvm/nvm.sh
        nvm install --reinstall-packages-from=current 'lts/*'
        nvm alias default 'lts/*'
        nvm use 'lts/*'
        nvm cache clear
    } || {
        print_message "Error updating nvm and node" "$error_color"
        return 1
    }
}

# macOS clear trash
clear_trash() {
    print_message "Clearing Trash" "$info_color"
    # print yellow message saying it will remove all files in the trash and it is not reversible
    print_message "This will remove all files in the Trash and it is not reversible" "$warning_color"
    read -p "Do you want to continue? (y/n): " confirm
    [[ $confirm != "y" ]] && return 1
    {
        sudo rm -rvf ~/.Trash/* 
    } || {
        print_message "Error clearing Trash" "$error_color"
        return 1
    }
}

clear_cache_user_cache() {
    print_message "Clearing User Cache" "$info_color"
    # print yellow message saying it will remove all files in the trash and it is not reversible
    print_message "This will remove all files in the User Cache and it is not reversible" "$warning_color"
    read -p "Do you want to continue? (y/n): " confirm
    [[ $confirm != "y" ]] && return 1
    {
        echo "Clearing Cache"
        sudo rm -rvf /Library/Caches/*
        echo "---------------------------------"
        echo "---------------------------------"
        echo "Clearing User Cache"
        rm -rvf ~/Library/Caches/*/
    } || {
        print_message "Error clearing User Cache" "$error_color"
        return 1
    }
}

# Function to update global npm packages
update_npm_packages() {
    print_message "Updating Global npm Packages" "$info_color"
    {
        npm update -g
    } || {
        print_message "Error updating global npm packages" "$error_color"
        return 1
    }
}

# Function for full update and cleanup
full_update_cleanup() {
    clear_trash
    clear_cache_user_cache
    update_homebrew
    cleanup_homebrew
    check_issues
    update_nvm_node
    update_npm_packages
}

# Function to handle the user's choice
handle_choice() {
    local choice="$1"
    case $choice in
        1)
            full_update_cleanup
            ;;
        2)
            update_homebrew
            ;;
        3)
            cleanup_homebrew
            ;;
        4)
            check_issues
            ;;
        5)
            update_nvm_node
            ;;
        6)
            return 1
            ;;
        7)
            update_npm_packages
            ;;
        8)
            print_message "Exiting Script" "$info_color"
            exit 0
            ;;
        *)
            print_message "Invalid Option. Please Try Again." "$warning_color"
            ;;
    esac
    printf "${bold}Press any key to return to the menu...${normal}"
    read -n 1
}

# Check if '--all' is provided as a parameter
if [[ "$1" == "--all" ]]; then
    selected_options=(1 2 3 4 5 6 7)
    full_update_cleanup
    exit 0
fi

# Main loop to show the menu and handle choices
while true; do
    show_menu
    read -r -p "Enter your choice: " input

    # Split input by spaces into array elements
    IFS=' ' read -ra options <<< "$input"

    # Validate and process each selected option
    for opt in "${options[@]}"; do
        if [[ $opt =~ ^[1-8]$ && ! " ${selected_options[@]} " =~ " $opt " ]]; then
            selected_options+=("$opt")
            handle_choice "$opt"
        fi
    done
done
