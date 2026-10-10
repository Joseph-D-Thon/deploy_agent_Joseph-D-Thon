# deploy_agent_Joseph-D-Thon - Automated Attendance Tracker Deployment

## How to Run
chmod +x deploy_agent.sh
./deploy_agent.sh
Menu: 1) Deploy 2) Run 3) Archive 4) Exit

## Feature 1: Deploy
- Pre-flight: checks python3 --version and zip, fails early with clear message
- Asks project name -> creates attendance_tracker_{name}/ with Helpers/, reports/, archives/attendance/, archives/absent/
- If dir exists: asks overwrite y/n, aborts if no
- Populate: attendance_checker.py and config.json unmodified from templates/
- Option A: copy header + N rows from templates/assets.csv (each row has 4 prior sessions, so total_sessions=5)
- Option B: generate fresh roster from arrays of sample names/emails, Attendance 0 Absence 0, total_sessions=1. Explains consistency in this README.
- Permissions: chmod +x attendance_checker.py, chmod 600 Helpers/config.json with confirmation print
- Thresholds: asks y/n to update warning(75)/failure(50), validates numeric 0-100 before sed -i on "warning": and "failure": lines
- Verify: ls -R and runs Feature 2

## Feature 2: Run
cd attendance_tracker_{name} && python3 attendance_checker.py (interactive P/A marking)

## Feature 3: Archive
Checks reports/attendance.log and reports/absent.log exist
Moves to archives/attendance/attendance_YYYYMMDD_HHMMSS.log and archives/absent/absent_YYYYMMDD_HHMMSS.log
Prints final paths, handles missing log gracefully without crash

## Signal Handling Trap
trap cleanup SIGINT SIGTSTP during deploy and main loop
On Ctrl+C/Z: prints "Interrupted! Archiving incomplete project...", zip -r {project}_archive.zip {project}/, rm -rf {project}/, exits cleanly
Test: ./deploy_agent.sh -> at Select prompt press Ctrl+C -> see .zip created, dir deleted. unzip -l shows contents.
Archive contains whatever was created so far.

## Tested Structure
Deploy A 2 -> assets.csv with Alice/Bob, config total_sessions 5, permissions 600/+x
Run -> logs in reports/
Archive -> moves to archives/*/
