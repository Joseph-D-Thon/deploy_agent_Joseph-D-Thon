# deploy_agent_Joseph-D-Thon - Joseph D Thon
Student: Joseph D Thon
Video: Pending recording - will update before deadline Oct 16

## How to Run
chmod +x deploy_agent.sh
./deploy_agent.sh
Menu: 1 Deploy 2 Run 3 Archive 4 Exit

## Feature 1 - Deploy
Pre-flight: python3 --version, zip, templates/ exists, fail early
Name: regex ^[A-Za-z0-9_-]+$ non-empty else error return to menu
If exists: y/n overwrite, n abort to menu
Creates: attendance_tracker_{name}/ with Helpers/ reports/ ONLY, no archives/ at deploy
Roster: A copy N+header from templates/assets.csv, B fresh NAMES[] EMAILS[] 0 counts, A/B and 1-10 re-prompt
total_sessions: A=5 (4 prior+today) B=1 consistent
Perms: chmod +x .py => -rwxr-xr-x, chmod 600 config.json => -rw-------, ls -l confirmation
Thresholds: default 75/50, numeric ^[0-9]+$ 0-100 re-prompt, sed warning failure number only
Verify: runs Feature 2 at end

## Feature 2 - Run
cd attendance_tracker_{name} && python3 attendance_checker.py
p/a interactive, updates csv, writes reports/attendance.log and absent.log

## Feature 3 - Archive
TS=$(date +%%Y%%m%%d_%%H%%M%%S)
mkdir -p archives/attendance archives/absent
cp reports/attendance.log archives/attendance/attendance_TS.log if exists
Graceful if absent.log missing, prints paths, timestamp unique

## Trap SIGINT SIGTSTP - Process Management
Trigger: Ctrl+C / Ctrl+Z during deploy
Code: trap cleanup SIGINT SIGTSTP
cleanup(): echo interrupted, zip -r PROJECT_archive.zip PROJECT/, rm -rf PROJECT, exit 1
trap - SIGINT SIGTSTP cleared on normal return and all error returns
Zip: attendance_tracker_TrapDemo_archive.zip real zip verified with unzip -l
Test: ./deploy_agent.sh -> 1 -> TrapDemo -> Ctrl+C at A/B prompt -> ls *.zip -> unzip -l zip

## Edge Cases
Empty/invalid name return menu, overwrite y/n, permission denied deletes partial and clears trap, A/B invalid re-prompt, 1-10 re-prompt, threshold 0-100, missing log graceful, EOF Ctrl+D exit

## Expected Structure
Deploy: .py Helpers/ reports/
After Run: reports/*.log
After Archive: archives/attendance/attendance_YYYYMMDD_HHMMSS.log
Trap: attendance_tracker_TrapDemo_archive.zip and no dir

## Git
Repo deploy_agent_Joseph-D-Thon, branch docs/readme-accuracy, script runs without crash
