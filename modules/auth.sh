#!/bin/bash
source ~/blood_donation/config.sh

while true; do
    ACTION=$(zenity --list \
        --title="Blood Donation System" \
        --text="Welcome! Register or Login:" \
        --column="Option" \
        --width=300 --height=250 \
        "Register" \
        "Login" \
        "Exit")

    case $ACTION in
        "Register")
            FORM=$(zenity --forms \
                --title="Register" \
                --text="Fill your info:" \
                --add-entry="Full Name" \
                --add-entry="Phone Number" \
                --add-entry="Email" \
                --add-password="Password" \
                --add-password="Confirm Password")

            [ $? -ne 0 ] && continue

            IFS='|' read -r NAME PHONE EMAIL PASS CONFIRMPASS <<< "$FORM"

            if [ -z "$NAME" ] || [ -z "$PHONE" ] || [ -z "$PASS" ]; then
                zenity --error --text="Name, Phone and Password cannot be empty!"
                continue
            fi

            if [ "$PASS" != "$CONFIRMPASS" ]; then
                zenity --error --text="Passwords do not match!"
                continue
            fi

            EXISTING=$(run_query_output "SELECT COUNT(*) FROM users WHERE phone='$PHONE';")
            if [ "$EXISTING" -gt 0 ]; then
                zenity --error --text="Phone already registered!"
                continue
            fi

            HASHED=$(echo -n "$PASS" | sha256sum | awk '{print $1}')
            run_query "INSERT INTO users (name, phone, email, password, role) VALUES ('$NAME', '$PHONE', '$EMAIL', '$HASHED', 'user');"
            zenity --info --text="Registration done! Please login."
            ;;

        "Login")
            FORM=$(zenity --forms \
                --title="Login" \
                --text="Enter credentials:" \
                --add-entry="Phone Number" \
                --add-password="Password")

            [ $? -ne 0 ] && continue

            IFS='|' read -r PHONE PASS <<< "$FORM"

            if [ -z "$PHONE" ] || [ -z "$PASS" ]; then
                zenity --error --text="Phone and Password cannot be empty!"
                continue
            fi

            HASHED=$(echo -n "$PASS" | sha256sum | awk '{print $1}')
            RESULT=$(run_query_output "SELECT id, name, role FROM users WHERE phone='$PHONE' AND password='$HASHED';")

            if [ -n "$RESULT" ]; then
                IFS='|' read -r UID UNAME UROLE <<< "$RESULT"
                export CURRENT_USER_ID=$UID
                export CURRENT_USER_NAME=$UNAME
                export CURRENT_USER_ROLE=$UROLE
                zenity --info --text="Welcome, $UNAME!"
                bash ~/blood_donation/modules/menu.sh
                exit 0
            else
                zenity --error --text="Wrong phone or password!"
            fi
            ;;

        "Exit"|"")
            exit 0
            ;;
    esac
done
