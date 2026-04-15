#!/bin/bash
source ~/blood_donation/config.sh

FORM=$(zenity --forms \
    --title="Add New Donor" \
    --text="Give the donor's information:" \
    --add-entry="Full Name" \
    --add-entry="Phone Number" \
    --add-entry="Email" \
    --add-combo="Blood Group" \
    --combo-values="A+|A-|B+|B-|AB+|AB-|O+|O-" \
    --add-entry="District" \
    --add-entry="Upazila")

[ $? -ne 0 ] && exit

IFS='|' read -r NAME PHONE EMAIL BLOOD DISTRICT UPAZILA <<< "$FORM"

if [ -z "$NAME" ] || [ -z "$PHONE" ] || [ -z "$BLOOD" ]; then
    zenity --error --text="Name, Phone and Blood Group cannot be empty!"
    exit
fi

EXISTING=$(run_query_output "SELECT COUNT(*) FROM donors WHERE phone='$PHONE';")
if [ "$EXISTING" -gt 0 ]; then
    zenity --error --text="This donor already exists!"
    exit
fi

run_query "INSERT INTO donors (name, phone, email, blood_group, district, upazila) VALUES ('$NAME', '$PHONE', '$EMAIL', '$BLOOD', '$DISTRICT', '$UPAZILA');"

zenity --info --title="Donor Added!" --text="$NAME successfully added as donor!"
