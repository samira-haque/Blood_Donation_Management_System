#!/bin/bash
source ~/blood_donation/config.sh

BLOOD=$(zenity --list \
    --title="Donor Search" \
    --text="Select the Blood Group:" \
    --column="Blood Group" \
    "A+" "A-" "B+" "B-" "AB+" "AB-" "O+" "O-")

[ -z "$BLOOD" ] && exit

DISTRICT=$(zenity --entry \
    --title="District Filter" \
    --text="Write the District (keep it blank to see the full list):")

if [ -z "$DISTRICT" ]; then
    QUERY="SELECT id, name, phone, blood_group, district, upazila FROM donors WHERE blood_group='$BLOOD' AND is_available=TRUE AND name IS NOT NULL ORDER BY id;"
else
    QUERY="SELECT id, name, phone, blood_group, district, upazila FROM donors WHERE blood_group='$BLOOD' AND district ILIKE '%$DISTRICT%' AND is_available=TRUE AND name IS NOT NULL ORDER BY id;"
fi

RESULT=$(run_query_output "$QUERY")

if [ -z "$RESULT" ]; then
    zenity --warning --text="No donor record was found!"
    exit
fi

LISTARGS=()
SERIAL=1
while IFS='|' read -r ID NAME PHONE BG DIST UPA; do
    LISTARGS+=("$ID" "$SERIAL" "$NAME" "$PHONE" "$BG" "$DIST" "$UPA")
    ((SERIAL++))
done <<< "$RESULT"

SELECTED=$(zenity --list \
    --title="Available Donors - Blood Group: $BLOOD" \
    --text="If a donor is selected, the details will be shown:" \
    --column="ID" \
    --column="No." \
    --column="Name" \
    --column="Phone" \
    --column="Blood Group" \
    --column="District" \
    --column="Upazila" \
    --width=800 --height=450 \
    --print-column=1 \
    "${LISTARGS[@]}")

[ -z "$SELECTED" ] && exit

INFO=$(run_query_output "SELECT id, name, phone, email, blood_group, district, upazila, is_available, last_donation, created_at FROM donors WHERE id=$SELECTED;")

IFS='|' read -r DID DNAME DPHONE DEMAIL DBG DDIST DUPA DAVAIL DLAST DCREATED <<< "$INFO"

[ "$DAVAIL" == "t" ] && AVAIL_TEXT="Available" || AVAIL_TEXT="Not Available"
[ -z "$DLAST" ] && DLAST="N/A"
[ -z "$DEMAIL" ] && DEMAIL="N/A"

zenity --info \
    --title="Donor Details - $DNAME" \
    --width=400 \
    --text="
=====================================
         DONOR INFORMATION
=====================================

 ID           : $DID
 Name         : $DNAME
 Phone        : $DPHONE
 Email        : $DEMAIL
 Blood Group  : $DBG
 District     : $DDIST
 Upazila      : $DUPA
 Status       : $AVAIL_TEXT
 Last Donation: $DLAST
 Joined       : $DCREATED

====================================="
