#!/bin/bash
source ~/blood_donation/config.sh

while true; do
    ACTION=$(zenity --list \
        --title="Donor Management" \
        --text="What do you want to do?" \
        --column="Action" \
        "✏️ Donor Info Edit" \
        "🗑️ Donor Delete" \
        "🔙 Back")

    case $ACTION in
        "✏️ Donor Info Edit")
            RESULT=$(run_query_output "SELECT id, name, phone, blood_group, district, upazila FROM donors WHERE name IS NOT NULL ORDER BY id;")

            if [ -z "$RESULT" ]; then
                zenity --warning --text="No donor record was found!"
                continue
            fi

            LISTARGS=()
            while IFS='|' read -r ID NAME PHONE BG DIST UPA; do
                LISTARGS+=("$ID" "$NAME" "$PHONE" "$BG" "$DIST" "$UPA")
            done <<< "$RESULT"

            SELECTED=$(zenity --list \
                --title="Select Donor to Edit" \
                --text="Select a donor to edit:" \
                --column="ID" \
                --column="Name" \
                --column="Phone" \
                --column="Blood Group" \
                --column="District" \
                --column="Upazila" \
                --width=750 --height=400 \
                --print-column=1 \
                "${LISTARGS[@]}")

            [ -z "$SELECTED" ] && continue

            DONOR=$(run_query_output "SELECT name, phone, email, blood_group, district, upazila FROM donors WHERE id=$SELECTED;")
            IFS='|' read -r DNAME DPHONE DEMAIL DBG DDIST DUPA <<< "$DONOR"

            FORM=$(zenity --forms \
                --title="Edit Donor - ID: $SELECTED" \
                --text="Update the information (if left blank, the previous value will be shown):" \
                --add-entry="Name [$DNAME]" \
                --add-entry="Phone [$DPHONE]" \
                --add-entry="Email [$DEMAIL]" \
                --add-combo="Blood Group" \
                --combo-values="A+|A-|B+|B-|AB+|AB-|O+|O-" \
                --add-entry="District [$DDIST]" \
                --add-entry="Upazila [$DUPA]")

            [ $? -ne 0 ] && continue

            IFS='|' read -r NNAME NPHONE NEMAIL NBG NDIST NUPA <<< "$FORM"

            [ -z "$NNAME" ] && NNAME="$DNAME"
            [ -z "$NPHONE" ] && NPHONE="$DPHONE"
            [ -z "$NEMAIL" ] && NEMAIL="$DEMAIL"
            [ -z "$NBG" ] && NBG="$DBG"
            [ -z "$NDIST" ] && NDIST="$DDIST"
            [ -z "$NUPA" ] && NUPA="$DUPA"

            run_query "UPDATE donors SET name='$NNAME', phone='$NPHONE', email='$NEMAIL', blood_group='$NBG', district='$NDIST', upazila='$NUPA' WHERE id=$SELECTED;"

            zenity --info --title="Success!" --text="Donor info has been successfully updated!"
            ;;

        "🗑️ Donor Delete")
            RESULT=$(run_query_output "SELECT id, name, phone, blood_group, district FROM donors WHERE name IS NOT NULL ORDER BY id;")

            if [ -z "$RESULT" ]; then
                zenity --warning --text="No donor record was found!"
                continue
            fi

            LISTARGS=()
            while IFS='|' read -r ID NAME PHONE BG DIST; do
                LISTARGS+=("$ID" "$NAME" "$PHONE" "$BG" "$DIST")
            done <<< "$RESULT"

            SELECTED=$(zenity --list \
                --title="Select Donor to Delete" \
                --text="Select Donor to Delete:" \
                --column="ID" \
                --column="Name" \
                --column="Phone" \
                --column="Blood Group" \
                --column="District" \
                --width=700 --height=400 \
                --print-column=1 \
                "${LISTARGS[@]}")

            [ -z "$SELECTED" ] && continue

            DNAME=$(run_query_output "SELECT name FROM donors WHERE id=$SELECTED;")

            zenity --question \
                --title="Confirm Delete" \
                --text="'$DNAME' ke delete korte chao?"

            if [ $? -eq 0 ]; then
                run_query "DELETE FROM donors WHERE id=$SELECTED;"

                run_query "UPDATE donors SET id=id-1 WHERE id > $SELECTED;"

                MAXID=$(run_query_output "SELECT COALESCE(MAX(id),0) FROM donors;")
                NEXTID=$((MAXID+1))
                run_query "ALTER SEQUENCE donors_id_seq RESTART WITH $NEXTID;"

                zenity --info --title="Deleted!" --text="'$DNAME' Successfully deleted!"
            fi
            ;;

        "🔙 Back"|"")
            exit 0
            ;;
    esac
done
