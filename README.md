# deploy_agent_Joseph-D-Thon - Joseph D Thon
Student: Joseph D Thon
Video: [PASTE DRIVE LINK - REQUIRED]

## How to Run
chmod +x deploy_agent.sh
./deploy_agent.sh
Menu: 1 Deploy 2 Run 3 Archive 4 Exit - re-run without restart.

## Feature 1 - Deploy
- Checks: python3 --version, zip, templates/ exists
- Name: A-Za-z0-9_- non-empty else error return to menu (not re-prompt)
- Creates attendance_tracker_{input}/ with Helpers/ reports/ ONLY. archives/ NOT at deploy
- Overwrite y/n if exists
- Roster: A copy N+header from templates/assets.csv, B fresh NAMES[] EMAILS[] 0 counts, A/B and 1-10 re-prompt
- total_sessions: A=5 (4 prior+today) B=1
- Perms: chmod +x .py and chmod 600 config.json => -rwxr-xr-x and -rw-------
- Thresholds: default 75/50 y/n update digits 0-100 else re-prompt

## Feature 2 - Run
cd attendance_tracker_{input} && python3 attendance_checker.py
p/a, updates csv, writes reports/. Tested via menu 2.

## Feature 3 - Archive
TS=$(date +"%Y%m%d_%H%M%S")
cp reports/attendance.log archives/attendance/attendance_${TS}.log
Creates archives/attendance/ and archives/absent/. Timestamp YYYYMMDD_HHMMSS unique. Graceful if absent.log missing.

## Trap SIGINT SIGTSTP
Trigger: Ctrl+C / Ctrl+Z during deploy
Code: trap cleanup SIGINT SIGTSTP
Cleanup: zip -r PROJECT_archive.zip PROJECT/, if success rm -rf PROJECT, exits, trap - before return
Zip: attendance_tracker_TrapDemo_archive.zip contains .py, config.json, assets.csv, empty reports/. Real zip verified unzip -l
Test: ./deploy_agent.sh -> 1 -> TrapDemo -> Ctrl+C at A/B prompt -> ls *.zip

## Edge Cases
Empty/invalid name return to menu, overwrite y/n, permission denied deletes partial and clears trap, A/B re-prompt, threshold 0-100, missing absent.log graceful, EOF Ctrl+D exits

## Expected Structure
Deploy: attendance_tracker_{name}/ with .py, Helpers/, reports/
Archive: plus archives/attendance/attendance_YYYYMMDD_HHMMSS.log and archives/absent/absent_YYYYMMDD_HHMMSS.log
