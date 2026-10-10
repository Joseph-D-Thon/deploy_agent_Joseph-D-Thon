# deploy_agent_Joseph-D-Thon - Joseph D Thon
Student: Joseph D Thon
Video: [PASTE DRIVE LINK - REQUIRED]

How to Run:
chmod +x deploy_agent.sh
./deploy_agent.sh
Menu: 1 Deploy 2 Run 3 Archive 4 Exit
Why menu? Brief says choice up to you if documented.

Feature 1 Deploy:
Pre-flight checks python3 --version, zip command, templates/ folder.
Name input via read, validates non-empty and A-Za-z0-9_- only else re-prompt.
Creates attendance_tracker_{input}/ with Helpers/ and reports/ ONLY. archives/ NOT at deploy - created by Feature 3.
If exists: Overwrite? y/n prompt.
Roster: Option A copy N rows + header from templates/assets.csv. 10 = header +10 = 11 lines. Option B generate fresh from NAMES[] EMAILS[] arrays 0 counts. Invalid A/B or count not 1-10 re-prompts.
total_sessions: Option A has 4 prior sessions per student so 4+today=5. Option B fresh has none so 1.
Permissions: chmod +x attendance_checker.py and chmod 600 Helpers/config.json. Verified -rwxr-xr-x and -rw-------
Thresholds: defaults 75 warning 50 failure. Asks y/n to update. Validates digits-only and 0-100 else re-prompt. Uses sed to change only number keeping format.

Feature 2 Run:
cd attendance_tracker_{input} && python3 attendance_checker.py
Interactive p/a marking, updates csv, writes reports/. Tested via menu option 2.

Feature 3 Archive:
Trigger: menu option 3 after marking creates logs.
TS=$(date +"%Y%m%d_%H%M%S")
cp reports/attendance.log archives/attendance/attendance_${TS}.log
cp reports/absent.log archives/absent/absent_${TS}.log
Creates archives/attendance/ and archives/absent/. Timestamp YYYYMMDD_HHMMSS unique. Prints paths like Archived -> archives/attendance/attendance_20261010_134230.log. Graceful if absent.log missing (0 absent) prints not found handled gracefully. Verified file created.

Trap SIGINT SIGTSTP:
Trigger: Ctrl+C or Ctrl+Z during deploy.
Implementation: trap cleanup SIGINT SIGTSTP, zip -r ${PROJECT_DIR}_archive.zip ${PROJECT_DIR}/, rm -rf ${PROJECT_DIR}, trap - SIGINT SIGTSTP
Zip contains: attendance_checker.py, Helpers/config.json, Helpers/assets.csv header only if interrupted before roster else full, empty reports/. Real zip extension.
Test Ctrl+C: ./deploy_agent.sh -> 1 -> TrapDemo -> press Ctrl+C at A/B prompt
Test Ctrl+Z: same but Ctrl+Z
Verify: unzip -l TrapDemo_archive.zip shows contents
On copy failure: deletes incomplete dir, clears PROJECT_DIR variable, clears trap with trap - before return so next Ctrl+C at menu exits quietly. Script does not leave ghost trap.

Edge Cases:
Empty name re-prompt, invalid chars A-Za-z0-9_- only, overwrite y/n, permission denied deletes partial and clears trap, A/B re-prompt, count 1-10 re-prompt, threshold digits 0-100 re-prompt, missing absent.log graceful, EOF Ctrl+D exits.

Testing Summary:
Option A 10: 11 lines header+10 sessions 5 perms verified. Option B 3: fresh sessions 1. Run option 2 tested. Archive timestamped 20261010_134230.log verified, graceful missing verified. Trap Ctrl+C and Ctrl+Z zip+delete verified unzip -l, failure clears trap verified chmod 000. Templates diff identical to originals.

Expected Structure:
After deploy: attendance_tracker_{name}/ with .py, Helpers/, reports/
After archive: plus archives/attendance/attendance_YYYYMMDD_HHMMSS.log and archives/absent/absent_YYYYMMDD_HHMMSS.log
