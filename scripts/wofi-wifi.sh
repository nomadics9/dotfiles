#!/usr/bin/env bash

# Define the GTK theme as a variable for easy changes
GTK_THEME_NAME="Nightfox-Dark"

# Set the X offset to 1500 (for top-right positioning)
OFFSET_X=1500
OFFSET_Y=20  # Small top margin

# Function to convert signal strength to bars
convert_signal_to_bars() {
    signal=$1
    if [ "$signal" -ge 75 ]; then
        echo "▂▃▄▅▆▇█"   # Full bars (strong signal)
    elif [ "$signal" -ge 50 ]; then
        echo "▂▃▄▅▆▇"   # Medium signal
    elif [ "$signal" -ge 25 ]; then
        echo "▂▃▄▅▆"    # Weak signal
    else
        echo "▂▃▄"      # Very weak signal
    fi
}

# Function to get Wi-Fi networks with right-aligned signal bars

# Function to get Wi-Fi networks with right-aligned signal bars
get_network_list() {
    max_ssid_length=$(nmcli -t -f SSID dev wifi list | awk '{ if (length > max) max = length } END { print max }')
    [ -z "$max_ssid_length" ] && max_ssid_length=0  # Default in case no SSID found
    max_ssid_length=$((max_ssid_length + 2))  # Add padding

    network_list=""
    IFS=$'\n'
    # Get unique SSIDs using sort and uniq
    for line in $(nmcli -t -f SSID,SIGNAL dev wifi list | sort -t: -k1,1 -u); do
        ssid=$(echo "$line" | cut -d: -f1)
        signal=$(echo "$line" | cut -d: -f2)

        if [ -n "$ssid" ]; then
            bars=$(convert_signal_to_bars "$signal")
            formatted_ssid=$(printf "%-${max_ssid_length}s" "$ssid")
            network_list+=" $formatted_ssid $bars\n"
        fi
    done
    echo -e "$network_list"
}


# Function to get the name of the currently connected network
get_connected_network() {
    connected_network=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d: -f2)
    if [ -n "$connected_network" ]; then
        echo "$connected_network"
    else
        echo "Not connected"
    fi
}

# Function to show network information (IP, gateway, etc.)
get_network_info() {
    ip_address=$(nmcli -g IP4.ADDRESS dev show | grep -v '^$')
    gateway=$(nmcli -g IP4.GATEWAY dev show | grep -v '^$')
    dns=$(nmcli -g IP4.DNS dev show | grep -v '^$')

    info="IP Address: $ip_address\nGateway: $gateway\nDNS: $dns"
    echo -e "$info"
}

# Function to forget a Wi-Fi network
forget_network() {
    network=$(nmcli connection show --active | grep wifi | awk '{print $1}')
    
    if [ -n "$network" ]; then
        nmcli connection delete "$network"
        notify-send "Forgot network: $network"
    else
        notify-send "No active network to forget"
    fi
}

# Function to connect to a network
connect_to_network() {
    while true; do
        # Perform a scan to refresh available Wi-Fi networks
        nmcli dev wifi rescan

        # Get the Wi-Fi list with aligned signal bars
        network_list=$(get_network_list)

        # Add refresh and go back options
        menu_list="Refresh\nGo back\n$network_list"

        # Use the GTK_THEME variable for wofi and set position with 1500px X offset
        chosen_network=$(echo -e "$menu_list" | GTK_THEME="$GTK_THEME_NAME" wofi --dmenu --prompt "Select Wi-Fi network:" -x "$OFFSET_X")

        # Handle special options
        case "$chosen_network" in
            "Refresh")
                continue
                ;;
            "Go back")
                main_menu
                return
                ;;
        esac

        # Extract the SSID from the chosen network (strip the bars and icon)
        chosen_network=$(echo "$chosen_network" | sed 's/ //;s/  *▂▃.*//')

        # Exit if no network is selected
        if [ -z "$chosen_network" ]; then
            echo "No network selected."
            exit 1
        fi

        # Check if the network is secured
        security_check=$(nmcli -t -f SSID,SECURITY dev wifi | grep "$chosen_network" | awk -F':' '{print $2}')

        # If secured, prompt for a password
        if [[ "$security_check" != "--" ]]; then
            password=$(GTK_THEME="$GTK_THEME_NAME" wofi --dmenu --password --prompt "Enter Password" --lines 1 --width 300 -x "$OFFSET_X")
            if [ -n "$password" ]; then
                nmcli dev wifi connect "$chosen_network" password "$password"
            else
                echo "No password entered."
            fi
        else
            # If not secured, connect directly
            nmcli dev wifi connect "$chosen_network"
        fi

        break  # Exit the loop once connected
    done
}

# Main menu function
main_menu() {
    network_info=$(get_network_info)
    connected_network=$(get_connected_network)

    # Present the main menu with "Wireless Connections", connected network, and network information
    menu="Wireless Connections\nConnected to: $connected_network\n$network_info\nForget Network"

    # Use the GTK_THEME variable for wofi and set position with 1500px X offset
    chosen=$(echo -e "$menu" | GTK_THEME="$GTK_THEME_NAME" wofi --dmenu --prompt "Main Menu:" -x "$OFFSET_X")

    case "$chosen" in
        "Wireless Connections")
            connect_to_network
            ;;
        "Forget Network")
            forget_network
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
}

# Run the main menu function
main_menu

