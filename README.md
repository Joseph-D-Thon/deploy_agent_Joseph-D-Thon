# Automated Project Bootstrapping & Process Management - Joseph D Thon
Student: Joseph D Thon
Repo: deploy_agent_Joseph-D-Thon
Video: [PASTE DRIVE LINK]

## How to Run
chmod +x deploy_agent.sh
./deploy_agent.sh
Menu: 1) Deploy 2) Run 3) Archive 4) Exit

## Feature 1: Deploy
- Pre-flight: python3 --version, zip, templates/ - fail early
- Input: read Project name -> attendance_tracker_{name}/
- Structure: Helpers/, reports/, archives/attendance/, archives/absent/
- If exists: prompt Overwrite? y/n
- Option A: copy N rows + header from templates/assets.csv, total_sessions=5
- Option B: generate fresh from NAMES[] EMAILS[] arrays, total_sessions=1
- Perms: chmod +x attendance_checker.py, chmod 600 config.json + echo
- Threshold: y/n, validate numeric, sed -i for warning and failure without reformatting

## Feature 2: Run
cd attendance_tracker_{p} && python3 attendance_checker.py
Interactive p/a, updates assets.csv, writes reports/

## Feature 3: Archive
TS=$(date +"%Y%m%d_%H%M%S")
cp reports/attendance.log -> archives/attendance/attendance_${TS}.log
cp reports/absent.log -> archives/absent/absent_${TS}.log
Graceful if missing: prints not found - handled gracefully
Verified timestamped

## Signal Handling Trap
trap cleanup SIGINT SIGTSTP during deploy
cleanup: zip -r PROJECT_DIR_archive.zip PROJECT_DIR/ && rm -rf PROJECT_DIR
Test: ./deploy_agent.sh -> 1 -> name -> Ctrl+C at A/B prompt -> prints Interrupted! -> zip + delete -> exit
Fix: on cp failure, rm -rf PROJECT_DIR; PROJECT_DIR=""; trap - SIGINT SIGTSTP; return 1 prevents ghost trap
Tested: chmod 000 templates/config.json -> fail -> Ctrl+C at menu -> quiet exit PASS

## Testing
Option A 10: 11 lines, 5 sessions, 600 OK
Option B 3: OK, 1 session
Archive: attendance_20261010_134230.log OK, graceful absent missing OK
Trap: creates real .zip, deletes dir, failure clears trap
Templates: diff identical to original download
