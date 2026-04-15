#!/bin/bash
source ~/blood_donation/config.sh

while true; do
    CHOICE=$(zenity --list \
        --title="🩸 Blood Donation System" \
        --text="Welcome, $CURRENT_USER_NAME! 👋" \
        --column="Option" \
        --height=500 --width=380 \
        "➕ Add Donor" \
        "🔍 Donor Search" \
        "🚨 Emergency Request" \
        "🏥 Blood Bank" \
        "👥 Manage Donors" \
        "📊 Dashboard" \
        "🚪 Logout")

    case $CHOICE in
        "➕ Add Donor")          bash ~/blood_donation/modules/add_donor.sh ;;
        "🔍 Donor Search")      bash ~/blood_donation/modules/search.sh ;;
        "🚨 Emergency Request") bash ~/blood_donation/modules/emergency.sh ;;
        "🏥 Blood Bank")        bash ~/blood_donation/modules/bloodbank.sh ;;
        "👥 Manage Donors")     bash ~/blood_donation/modules/manage.sh ;;
        "📊 Dashboard")         bash ~/blood_donation/modules/dashboard.sh ;;
        "🚪 Logout"|"")
            zenity --info --text="Goodbye, $CURRENT_USER_NAME! 👋"
            exit 0
            ;;
    esac
done
