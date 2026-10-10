#!/bin/bash
PROJECT_DIR=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/templates"

cleanup(){
 echo ""
 echo "Interrupted! Archiving incomplete project..."
 if [ -d "$PROJECT_DIR" ] && [ -n "$PROJECT_DIR" ]; then
  if zip -r "${PROJECT_DIR}_archive.zip" "$PROJECT_DIR" >/dev/null 2>&1; then
   echo "Archived to ${PROJECT_DIR}_archive.zip"
   rm -rf "$PROJECT_DIR"
   echo "Deleted incomplete directory $PROJECT_DIR"
  else
   echo "Archive failed - keeping $PROJECT_DIR for inspection"
  fi
 fi
 echo "Exiting cleanly."
 exit 1
}

check_env(){
 if ! command -v python3 >/dev/null 2>&1; then echo "Error: python3 not installed"; exit 1; fi
 if ! command -v zip >/dev/null 2>&1; then echo "Error: zip not installed"; exit 1; fi
 if [ ! -d "$TEMPLATE_DIR" ]; then echo "Error: templates/ missing"; exit 1; fi
 echo "Pre-flight: python3 $(python3 --version) OK"
 echo "Pre-flight: zip OK"
 echo "Pre-flight: templates/ OK"
}

deploy(){
 trap cleanup SIGINT SIGTSTP
 check_env
  read -r -p "Project name (e.g. Joseph-D-Thon): " pname
 if [ -z "$pname" ]; then echo "Error: name empty"; trap - SIGINT SIGTSTP; return 1; fi
 if [[ ! "$pname" =~ ^[A-Za-z0-9_-]+$ ]]; then echo "Error: invalid project name - only letters, numbers, underscore and hyphen allowed"; trap - SIGINT SIGTSTP; return 1; fi

 local target_dir="attendance_tracker_${pname}"
 if [ -d "$target_dir" ]; then
  read -r -p "Directory $target_dir exists. Overwrite? y/n: " ow
  if [[ "$ow" != "y" && "$ow" != "Y" ]]; then echo "Aborted: $target_dir already exists. Choose different name or overwrite."; trap - SIGINT SIGTSTP; return 1; fi
  rm -rf "$target_dir"
 fi
 PROJECT_DIR="$target_dir"
  mkdir -p "$PROJECT_DIR/Helpers" "$PROJECT_DIR/reports" || { echo "Error: cannot create project folder - permission denied"; PROJECT_DIR=""; trap - SIGINT SIGTSTP; return 1; }
  cp "$TEMPLATE_DIR/attendance_checker.py" "$PROJECT_DIR/" || { echo "Error: failed to copy attendance_checker.py"; rm -rf "$PROJECT_DIR"; PROJECT_DIR=""; trap - SIGINT SIGTSTP; return 1; }
cp "$TEMPLATE_DIR/config.json" "$PROJECT_DIR/Helpers/" || { echo "Error: failed to copy config.json"; rm -rf "$PROJECT_DIR"; PROJECT_DIR=""; trap - SIGINT SIGTSTP; return 1; }
 chmod +x "$PROJECT_DIR/attendance_checker.py"
 echo "Set permission: +x attendance_checker.py"

 head -n 1 "$TEMPLATE_DIR/assets.csv" > "$PROJECT_DIR/Helpers/assets.csv"

 while true; do
read -r -p "Roster build - Option A copy template or B generate fresh (A/B): " opt
case "$opt" in
A|a) break ;;
B|b) break ;;
*) echo "Error: invalid option - choose A or B"; continue ;;
esac
done
 while true; do
read -r -p "How many students (1-10): " num
if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le 10 ]; then break; fi
echo "Error: enter number 1-10"
done
 if [[ $opt == "A" || $opt == "a" ]]; then
  tail -n +2 "$TEMPLATE_DIR/assets.csv" | head -n "$num" >> "$PROJECT_DIR/Helpers/assets.csv"
  python3 -c "import json; p='$PROJECT_DIR/Helpers/config.json'; d=json.load(open(p)); d['total_sessions']=5; json.dump(d,open(p,'w'),indent=4)"
  echo "Option A: copied $num rows + header, total_sessions=5 (4 prior + today)"
 else
  NAMES=("Malong John" "Deng Leek" "Ayak Chol" "Akon Garang" "Mawien Dut" "Abuk Deng" "Maker Thon" "Adut Ajak" "Kuol Lual" "Achol Majok")
  EMAILS=("malong.john@alustudent.com" "deng.leek@alustudent.com" "ayak.chol@alustudent.com" "akon.garang@alustudent.com" "mawien.dut@alustudent.com" "abuk.deng@alustudent.com" "maker.thon@alustudent.com" "adut.ajak@alustudent.com" "kuol.lual@alustudent.com" "achol.majok@alustudent.com")
  for ((i=0;i<num;i++)); do echo "${EMAILS[$i]},${NAMES[$i]},0,0" >> "$PROJECT_DIR/Helpers/assets.csv"; done
  python3 -c "import json; p='$PROJECT_DIR/Helpers/config.json'; d=json.load(open(p)); d['total_sessions']=1; json.dump(d,open(p,'w'),indent=4)"
  echo "Option B: generated $num fresh rows with 0 counts, total_sessions=1"
 fi
 chmod 600 "$PROJECT_DIR/Helpers/config.json"
 echo "Set permission: 600 Helpers/config.json (owner read/write only)"

 read -r -p "Update alert thresholds? y/n: " up
 if [[ "$up" == "y" || "$up" == "Y" ]]; then
   while true; do
    read -r -p "Enter warning threshold (default 75): " warn
    if [ -z "$warn" ]; then warn=75; fi
    if ! [[ "$warn" =~ ^[0-9]+$ ]]; then
     echo "Error: numbers only"
     continue
    fi
    if [ "$warn" -gt 100 ]; then
     echo "Error: must be 0 to 100"
     continue
    fi
    break
   done
   while true; do
 read -r -p "Enter failure threshold (default 50): " fail
    if [ -z "$fail" ]; then fail=50; fi
    if ! [[ "$fail" =~ ^[0-9]+$ ]]; then
     echo "Error: numbers only"
     continue
    fi
    if [ "$fail" -gt 100 ]; then
     echo "Error: must be 0 to 100"
     continue
    fi
    break
   done
   sed -i "s/\"failure\": [0-9]*/\"failure\": $fail/" "$PROJECT_DIR/Helpers/config.json"
   sed -i "s/\"warning\": [0-9]*/\"warning\": $warn/" "$PROJECT_DIR/Helpers/config.json"
   echo "Updated thresholds: warning=$warn, failure=$fail"
 fi

 echo "Verifying deployment..."
 ls -R "$PROJECT_DIR"
 cat "$PROJECT_DIR/Helpers/config.json"
 trap - SIGINT SIGTSTP
 (cd "$PROJECT_DIR" && python3 attendance_checker.py)
 PROJECT_DIR=""
}

run_app(){ 
 read -r -p "Project name to run: " p
 if [ ! -d "attendance_tracker_${p}" ]; then echo "Error: attendance_tracker_${p} not found"; return 1; fi
 (cd "attendance_tracker_${p}" && python3 attendance_checker.py)
}

archive_logs(){ 
 read -r -p "Project name to archive: " p
 local base="attendance_tracker_${p}"
 if [ ! -d "$base" ]; then echo "Error: $base not found"; return 1; fi
 TS=$(date +"%Y%m%d_%H%M%S")
 mkdir -p "$base/archives/attendance" "$base/archives/absent"
 if [ -f "$base/reports/attendance.log" ]; then 
  cp "$base/reports/attendance.log" "$base/archives/attendance/attendance_${TS}.log"
  echo "Archived: $base/reports/attendance.log -> $base/archives/attendance/attendance_${TS}.log"
 else
  echo "attendance.log not found in $base/reports/"
 fi
 if [ -f "$base/reports/absent.log" ]; then 
  cp "$base/reports/absent.log" "$base/archives/absent/absent_${TS}.log"
  echo "Archived: $base/reports/absent.log -> $base/archives/absent/absent_${TS}.log"
 else
  echo "absent.log not found (e.g., no absents) - handled gracefully"
 fi
}

while true; do 
 echo ""
 echo "=== deploy_agent - Joseph-D-Thon ==="
 echo "1) Deploy  2) Run  3) Archive  4) Exit"
  read -r -p "Select: " c || exit
 case $c in 1) deploy;; 2) run_app;; 3) archive_logs;; 4) echo "Bye"; exit 0;; *) echo "Invalid option";; esac
done
