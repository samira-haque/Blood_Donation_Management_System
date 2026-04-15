#!/bin/bash
source ~/blood_donation/config.sh

TOTAL_DONORS=$(run_query_output "SELECT COUNT(*) FROM donors;")
TOTAL_USERS=$(run_query_output "SELECT COUNT(*) FROM users;")
TOTAL_REQUESTS=$(run_query_output "SELECT COUNT(*) FROM emergency_requests;")
PENDING=$(run_query_output "SELECT COUNT(*) FROM emergency_requests WHERE status='pending';")
FULFILLED=$(run_query_output "SELECT COUNT(*) FROM emergency_requests WHERE status='fulfilled';")
CRITICAL=$(run_query_output "SELECT COUNT(*) FROM blood_inventory WHERE status='critical';")

APLUS=$(run_query_output "SELECT COUNT(*) FROM donors WHERE blood_group='A+';")
AMINUS=$(run_query_output "SELECT COUNT(*) FROM donors WHERE blood_group='A-';")
BPLUS=$(run_query_output "SELECT COUNT(*) FROM donors WHERE blood_group='B+';")
BMINUS=$(run_query_output "SELECT COUNT(*) FROM donors WHERE blood_group='B-';")
ABPLUS=$(run_query_output "SELECT COUNT(*) FROM donors WHERE blood_group='AB+';")
ABMINUS=$(run_query_output "SELECT COUNT(*) FROM donors WHERE blood_group='AB-';")
OPLUS=$(run_query_output "SELECT COUNT(*) FROM donors WHERE blood_group='O+';")
OMINUS=$(run_query_output "SELECT COUNT(*) FROM donors WHERE blood_group='O-';")

zenity --info \
    --title="📊 Dashboard" \
    --width=420 \
    --text="
            BLOOD DONATION SYSTEM
🩸 ============================= 🩸

👥 Total Registered Users : $TOTAL_USERS
🩸 Total Donors           : $TOTAL_DONORS
🚨 Total Requests         : $TOTAL_REQUESTS
⏳ Pending Requests       : $PENDING
✅ Fulfilled Requests     : $FULFILLED
⚠️  Critical Blood Stock   : $CRITICAL

----------------------------------------------------------
 🩸 DONORS BY BLOOD GROUP 🩸
----------------------------------------------------------

 A+  : $APLUS
 A-  : $AMINUS
 B+  : $BPLUS
 B-  : $BMINUS
 AB+ : $ABPLUS
 AB- : $ABMINUS
 O+  : $OPLUS
 O-  : $OMINUS

======================================="
