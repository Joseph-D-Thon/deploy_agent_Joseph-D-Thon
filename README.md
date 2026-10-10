# deploy_agent_Joseph-D-Thon - Joseph D Thon
Student: Joseph D Thon
Video: Pending recording - will update before deadline Oct 16

## How to Run
chmod +x deploy_agent.sh
./deploy_agent.sh

## Feature 1 Deploy
Pre-flight python3 --version zip templates/, name regex ^[A-Za-z0-9_-]+$ return menu, overwrite y/n, creates Helpers reports ONLY, Roster A/B 1-10 validation, total_sessions A=5 B=1, chmod +x and 600, thresholds numeric 0-100 sed, verify runs app

## Feature 2 Run
cd attendance_tracker_{name} && python3 attendance_checker.py

## Feature 3 Archive
TS date +%Y%m%d_%H%M%S, cp to archives/attendance/ and archives/absent/ with timestamp, graceful missing log

## Trap
trap cleanup SIGINT SIGTSTP, cleanup zip -r PROJECT_archive.zip PROJECT/ + rm -rf PROJECT + exit, trap - before return, test TrapDemo Ctrl+C ls unzip -l
Zip attendance_tracker_TrapDemo_archive.zip verified real zip

## Edge Cases
All handled with trap - clearing
