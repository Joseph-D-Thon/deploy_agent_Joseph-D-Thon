#!/bin/bash
PROJECT_DIR=""
cleanup(){
 echo "[!] Interrupted"
 if [ -d "$PROJECT_DIR" ]; then
  zip -r "${PROJECT_DIR}_archive.zip" "$PROJECT_DIR" >/dev/null 2>&1
  rm -rf "$PROJECT_DIR"
  echo "[V] Created zip and cleaned"
 fi
 exit 1
}
deploy(){
trap cleanup SIGINT SIGTSTP
python3 --version
read -p "Project name: " pname
PROJECT_DIR="attendance_tracker_${pname}"
if [ -d "$PROJECT_DIR" ]; then
 read -p "Overwrite? y/n: " ow
 if [[ "$ow" !=  y ]]; then trap - SIGINT SIGTSTP; return 1; fi
 rm -rf "$PROJECT_DIR"
fi
mkdir -p "$PROJECT_DIR/Helpers" "$PROJECT_DIR/reports"
cp templates/attendance_checker.py "$PROJECT_DIR/"
cp templates/config.json "$PROJECT_DIR/Helpers/"
chmod +x "$PROJECT_DIR/attendance_checker.py"
chmod 600 "$PROJECT_DIR/Helpers/config.json"
echo "[V] Permissions set"
head -n 1 templates/assets.csv > "$PROJECT_DIR/Helpers/assets.csv"
read -p "A)Copy B)Generate: " opt
read -p "How many? " num
if [[ $opt == A ]]; then
 tail -n +2 templates/assets.csv | head -n $num >> "$PROJECT_DIR/Helpers/assets.csv"
 sed -i 's/"total_sessions":.*/"total_sessions": 5/' "$PROJECT_DIR/Helpers/config.json"
else
 echo "m.john@alustudent.com,Malong John,0,0" >> "$PROJECT_DIR/Helpers/assets.csv"
 echo "d.leek@alustudent.com,Deng Leek,0,0" >> "$PROJECT_DIR/Helpers/assets.csv"
 echo "m.derick@alustudent.com,Micheal Derick,0,0" >> "$PROJECT_DIR/Helpers/assets.csv"
 echo "j.lagum@alustudent.com,Jonathan Lagum,0,0" >> "$PROJECT_DIR/Helpers/assets.csv"
 echo "a.tabby@alustudent.com,Achol Tabby,0,0" >> "$PROJECT_DIR/Helpers/assets.csv"
 echo "a.bior@alustudent.com,Aguet Bior,0,0" >> "$PROJECT_DIR/Helpers/assets.csv"
 echo "u.honorine@alustudent.com,Uwase Honorine,0,0" >> "$PROJECT_DIR/Helpers/assets.csv"
 echo "d.ngoga@alustudent.com,David Ngoga,0,0" >> "$PROJECT_DIR/Helpers/assets.csv"
 echo "k.imanzi@alustudent.com,Karemera Ochri,0,0" >> "$PROJECT_DIR/Helpers/assets.csv"
 echo "j.rufora@alustudent.com,Jeremie Rufora,0,0" >> "$PROJECT_DIR/Helpers/assets.csv"
 sed -i 's/"total_sessions":.*/"total_sessions": 1/' "$PROJECT_DIR/Helpers/config.json"
fi
(cd "$PROJECT_DIR" && python3 attendance_checker.py)
trap - SIGINT SIGTSTP
}
run_app(){
 read -p "Project name: " p
 cd "attendance_tracker_${p}" && python3 attendance_checker.py
}
archive_logs(){
 read -p "Project name: " p
 TS=$(date +"%Y%m%d_%H%M%S")
 mkdir -p "attendance_tracker_${p}/archives/attendance"
 mkdir -p "attendance_tracker_${p}/archives/absent"
 if [ -f "attendance_tracker_${p}/reports/attendance.log" ]; then
  cp "attendance_tracker_${p}/reports/attendance.log" "attendance_tracker_${p}/archives/attendance/attendance_${TS}.log"
  echo "[V] Archived attendance"
 else
  echo "[!] No attendance.log"
 fi
 if [ -f "attendance_tracker_${p}/reports/absent.log" ]; then
  cp "attendance_tracker_${p}/reports/absent.log" "attendance_tracker_${p}/archives/absent/absent_${TS}.log"
  echo "[V] Archived absent"
 else
  echo "[!] No absent.log - handled gracefully"
 fi
}
while true; do
 echo "1)Deploy 2)Run 3)Archive 4)Exit"
 read -p "Select: " c
 case $c in
  1) deploy;;
  2) run_app;;
  3) archive_logs;;
  4) exit;;
 esac
done
