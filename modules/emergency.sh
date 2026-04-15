#!/bin/bash
source ~/blood_donation/config.sh

FORM=$(zenity --forms \
    --title="🚨 Emergency Blood Request" \
    --text="Sent emergency request:" \
    --add-combo="Blood Group" \
    --combo-values="A+|A-|B+|B-|AB+|AB-|O+|O-" \
    --add-entry="Hospital Name" \
    --add-entry="District" \
    --add-entry="Contact Number")

if [ $? -eq 0 ]; then
    IFS='|' read -r BLOOD HOSPITAL DISTRICT CONTACT <<< "$FORM"

    run_query "INSERT INTO emergency_requests (blood_group, hospital_name, district, contact)
               VALUES ('$BLOOD', '$HOSPITAL', '$DISTRICT', '$CONTACT');"

    DONORS=$(run_query_output "SELECT name, phone FROM users
              WHERE blood_group='$BLOOD' AND district ILIKE '%$DISTRICT%'
              AND is_available=TRUE AND role='donor' LIMIT 10;")

    if [ -n "$DONORS" ]; then
        echo "$DONORS" | awk -F'|' '{print $1"\t"$2}' | \
        zenity --list \
            --title="🚨 Nearby Donors Found!" \
            --text="Contact these donors:" \
            --column="Name" --column="Phone" \
            --width=500 --height=350
    else
        zenity --warning --text="⚠️ There are no nearby donors!\nRequest has been saved"
    fi
fi
