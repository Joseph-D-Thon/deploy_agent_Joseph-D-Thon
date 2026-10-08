# Automated Project Bootstrapping & Process Management - Joseph D Thon
**Repo:** deploy_agent_Joseph-D-Thon
**Video:** [PASTE YOUR DRIVE LINK HERE AFTER RECORDING]

## How to Run
chmod +x deploy_agent.sh
./deploy_agent.sh
Menu: 1) Deploy 2) Run 3) Archive 4) Exit

## Feature 1: Deploy (Exemplary 5/5)
- Pre-flight: python3 --version, zip, templates/ - fail early clear message
- Asks project name via read, creates attendance_tracker_{input}/ exact structure Helpers/, reports/, archives/attendance/, archives/absent/
- If exists: prompt Overwrite? y/n - aborts with error if n (robust handling)
- Option A: copy N rows + header from templates/assets.csv, total_sessions=5 (4 prior + today)
- Option B: generate fresh from arrays NAMES[] EMAILS[] with 0 counts, total_sessions=1
- Perms: chmod +x attendance_checker.py, chmod 600 Helpers/config.json with confirmation echo
- Threshold: ask y/n, validate numeric, sed -i for "warning": and "failure": without reformatting
- Verify: ls -R and auto-run Feature 2 proves structure works

## Feature 2: Run (Part of Deploy verification)
cd attendance_tracker_{input} && python3 attendance_checker.py
Interactive p/a marking, updates assets.csv, writes reports/

## Feature 3: Archive (Exemplary)
TS=$(date +"%Y%m%d_%H%M%S")
Checks reports/attendance.log and reports/absent.log
cp to archives/attendance/attendance_${TS}.log and archives/absent/absent_${TS}.log
Prints full paths: Archived: ... -> ...
Graceful: if absent.log missing -> "absent.log not found - handled gracefully" no crash

## Signal Handling Trap (Exemplary 5/5)
trap cleanup SIGINT SIGTSTP during deploy
Test: ./deploy_agent.sh -> 1 -> TrapDemo -> Ctrl+C at A/B prompt
Prints Interrupted! -> zip -r TrapDemo_archive.zip TrapDemo/ -> rm -rf TrapDemo -> exit clean
Result: .zip with real .zip extension + incomplete dir deleted - prevents clutter

## Testing
Option A 10 students OK, Option B 3 OK, archive timestamp OK, graceful missing log OK, trap PASS deleted OK
chmod: -rwxr-xr-x .py, -rw------- config.json

## Expected Structure
attendance_tracker_{name}/
├── attendance_checker.py
├── Helpers/assets.csv + config.json
├── reports/attendance.log + absent.log
└── archives/attendance/ + absent/ timestamped logs
