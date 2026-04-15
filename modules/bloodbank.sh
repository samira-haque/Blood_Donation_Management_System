#!/bin/bash
source ~/blood_donation/config.sh

while true; do
    ACTION=$(zenity --list \
        --title="Blood Bank Management" \
        --text="What do you want to do?" \
        --column="Action" \
        "📋 View Inventory" \
        "➕ Add Stock" \
        "⚠️ View Expiry Alerts" \
        "🔙 Back")

    case $ACTION in
        "📋 View Inventory")
            RESULT=$(run_query_output "SELECT hospital_name, blood_group, quantity, status, expiry_date FROM blood_inventory ORDER BY status;")

            if [ -z "$RESULT" ]; then
                zenity --warning --text="There is no inventory!"
                continue
            fi

            LISTARGS=()
            SERIAL=1
            while IFS='|' read -r HOSP BG QTY STATUS EXP; do
                LISTARGS+=("$SERIAL" "$HOSP" "$BG" "$QTY" "$STATUS" "$EXP")
                ((SERIAL++))
            done <<< "$RESULT"

            zenity --list \
                --title="Blood Bank Inventory" \
                --column="No." \
                --column="Hospital" \
                --column="Blood Group" \
                --column="Quantity" \
                --column="Status" \
                --column="Expiry Date" \
                --width=800 --height=450 \
                "${LISTARGS[@]}"
            ;;

        "➕ Add Stock")
            FORM=$(zenity --forms \
                --title="Add Blood Stock" \
                --text="Give the Stock info:" \
                --add-entry="Hospital Name" \
                --add-combo="Blood Group" \
                --combo-values="A+|A-|B+|B-|AB+|AB-|O+|O-" \
                --add-entry="Quantity (units)" \
                --add-entry="Expiry Date (YYYY-MM-DD)")

            [ $? -ne 0 ] && continue

            IFS='|' read -r HOSP BG QTY EXPIRY <<< "$FORM"

            if [ -z "$HOSP" ] || [ -z "$BG" ] || [ -z "$QTY" ]; then
                zenity --error --text="Sob field fill up koro!"
                continue
            fi

            STATUS="sufficient"
            [ "$QTY" -lt 10 ] && STATUS="moderate"
            [ "$QTY" -lt 5 ] && STATUS="critical"

            run_query "INSERT INTO blood_inventory (hospital_name, blood_group, quantity, expiry_date, status) VALUES ('$HOSP', '$BG', $QTY, '$EXPIRY', '$STATUS');"

            zenity --info --title="Success!" --text="Stock has been successfully added!"
            ;;

        "⚠️ View Expiry Alerts")
            RESULT=$(run_query_output "SELECT hospital_name, blood_group, quantity, expiry_date FROM blood_inventory WHERE expiry_date <= CURRENT_DATE + INTERVAL '7 days' ORDER BY expiry_date;")

            if [ -z "$RESULT" ]; then
                zenity --info --text="There are no expiry alerts!"
                continue
            fi

            LISTARGS=()
            SERIAL=1
            while IFS='|' read -r HOSP BG QTY EXP; do
                LISTARGS+=("$SERIAL" "$HOSP" "$BG" "$QTY" "$EXP")
                ((SERIAL++))
            done <<< "$RESULT"

            zenity --list \
                --title="Expiry Alerts (Within 7 days)" \
                --column="No." \
                --column="Hospital" \
                --column="Blood Group" \
                --column="Quantity" \
                --column="Expiry Date" \
                --width=700 --height=400 \
                "${LISTARGS[@]}"
            ;;

        "🔙 Back"|"")
            exit 0
            ;;
    esac
done
