# deploy_agent_Joseph-D-Thon - Joseph D Thon
Student: Joseph D Thon
Video: https://drive.google.com/file/d/REPLACE_WITH_YOUR_LINK/view?usp=sharing

## How to Run
chmod +x deploy_agent.sh
./deploy_agent.sh
Menu: 1 Deploy 2 Run 3 Archive 4 Exit
Why menu? Brief says choice up to you if documented.

## Feature 1 - Deploy
- Pre-flight: python3 --version, zip, templates/
- Name validates A-Za-z0-9_- non-empty else re-prompt
- Creates attendance_tracker_{input}/ with Helpers/ and reports/ ONLY. archives/ NOT at deploy - created by Feature 3
- Overwrite? y/n if exists
- Roster: Option A copy N+header from templates/assets.csv (10=11 lines). Option B fresh from NAMES[] EMAILS[] 0 counts. A/B and 1-10 re-prompt
- total_sessions: Option A 4 prior + today =5, Option B fresh =1
- Perms: chmod +x .py and chmod 600 config.json Verified -rwxr-xr-x and -rw-------
- Thresholds: defaults 75/50. y/n to update. digits-only 0-100 else re-prompt. sed changes only number

## Feature 2 - Run
cd attendance_tracker_{input} && python3 attendance_checker.py
Interactive p/a, updates csv, writes reports/. Tested via menu option 2

## Feature 3 - Archive
Trigger: menu option 3 after marking creates logs
TS=$(date +"%Y%m%d_%H%M%S")
cp reports/attendance.log archives/attendance/attendance_${TS}.log
cp reports/absent.log archives/absent/absent_${TS}.log
Creates archives/attendance/ and archives/absent/. Timestamp YYYYMMDD_HHMMSS unique. Prints Archived -> archives/attendance/attendance_20261010_134230.log. Graceful if absent.log missing.

## Trap SIGINT SIGTSTP
Trigger: Ctrl+C or Ctrl+Z during deploy
Implementation: trap cleanup SIGINT SIGTSTP, zip -r ${PROJECT_DIR}_archive.zip ${PROJECT_DIR}/, rm -rf ${PROJECT_DIR}, trap - SIGINT SIGTSTP
Zip contains: attendance_checker.py, Helpers/config.json, Helpers/assets.csv header only if interrupted before roster else full, empty reports/. Real zip extension
Test Ctrl+C: ./deploy_agent.sh -> 1 -> TrapDemo -> Ctrl+C at A/B prompt
Test Ctrl+Z: same but Ctrl+Z
Verify: unzip -l TrapDemo_archive.zip shows contents
On failure: deletes incomplete dir, clears PROJECT_DIR, clears trap with trap - before return so next Ctrl+C at menu exits quietly

## Edge Cases
Empty name, invalid chars, overwrite y/n, permission denied deletes partial and clears trap, A/B re-prompt, 1-10 re-prompt, threshold digits 0-100, missing absent.log graceful, EOF Ctrl+D exits

## Testing Summary
Option A 10: 11 lines, sessions 5, perms verified. Option B 3: sessions 1. Run tested. Archive timestamped verified, graceful missing verified. Trap Ctrl+C and Ctrl+Z zip+delete verified unzip -l, failure clears trap verified chmod 000. Templates diff identical.

## Expected Structure
After deploy: attendance_tracker_{name}/ with .py, Helpers/, reports/
After archive: plus archives/attendance/attendance_YYYYMMDD_HHMMSS.log and archives/absent/absent_YYYYMMDD_HHMMSS.log
