# deploy_agent_Joseph-D-Thon - Joseph D Thon

## How to Run
chmod +x deploy_agent.sh
./deploy_agent.sh
Interactive menu: 1) Deploy 2) Run 3) Archive 4) Exit

## Feature 1: Deploy
- Pre-flight checks: python3 --version, zip --version, templates/ files exist. Fail early with clear message.
- Project name: read input, regex ^[A-Za-z0-9_-]+$ non-empty else return to menu with error.
- If attendance_tracker_{name} exists: prompts Overwrite? y/n, n aborts to menu.
- Creates: attendance_tracker_{name}/ with Helpers/, reports/ at deploy, archives/ created at archive time (or early). Uses mkdir -p with || error handling.
- Populate: attendance_checker.py and config.json unmodified from templates/. Helpers/assets.csv via:
    - Option A: copy header + N rows (1-10 validation re-prompt) from templates/assets.csv. total_sessions=5 because sample has 4 prior (Attendance+Absence=4) + today.
    - Option B: generate fresh roster from arrays NAMES[] and EMAILS[] you define, Attendance 0 Absence 0. total_sessions=1 (first session). Explained here for consistency.
- Permissions: chmod +x attendance_checker.py (shows -rwxr-xr-x) and chmod 600 Helpers/config.json (-rw-------) with ls -l confirmation print.
- Thresholds: asks Update thresholds? y/n. If y, reads warning (default 75) failure (default 50), validates ^[0-9]+$ and 0-100 range, re-prompts on invalid. Uses sed -i to edit "warning": <num> and "failure": <num> lines only, no reformat.
- Verify: ends by calling Feature 2 to prove structure works.

## Feature 2: Run
cd attendance_tracker_{name} && python3 attendance_checker.py
Interactive P/A prompts, updates assets.csv counts, writes reports/attendance.log and reports/absent.log

## Feature 3: Archive
- Timestamp: TS=$(date +%Y%m%d_%H%M%S)
- Checks reports/attendance.log and reports/absent.log exist
- mkdir -p archives/attendance archives/absent
- cp/mv reports/*.log to archives/attendance/attendance_TS.log and archives/absent/absent_TS.log
- Prints confirmation with final paths, handles missing log gracefully: "No absent.log - nobody absent" without crashing.

## Signal Handling: Ctrl+C and Ctrl+Z
- Trigger: user presses Ctrl+C (SIGINT) or Ctrl+Z (SIGTSTP) while deploying (during name prompt, A/B prompt, or threshold prompt)
- Implementation: trap cleanup SIGINT SIGTSTP at start of deploy() and also main loop. cleanup() prints "Interrupted! Archiving incomplete project...", runs zip -r ${PROJECT}_archive.zip ${PROJECT}/, then rm -rf ${PROJECT}/, then exit 1. trap - SIGINT SIGTSTP cleared on normal return and on all error returns to avoid lingering trap.
- Archive: attendance_tracker_{name}_archive.zip real .zip extension, verified with unzip -l which lists partial files created so far.
- How to test: ./deploy_agent.sh -> 1 -> type TrapDemo -> at A/B prompt press Ctrl+C -> observe message, ls *.zip shows zip, ls shows dir deleted, unzip -l attendance_tracker_TrapDemo_archive.zip shows contents.

## Edge Cases Tested
- Empty/invalid project name -> error return to menu
- Existing dir -> y/n overwrite
- Permission denied mkdir -> deletes partial, clears trap
- Invalid A/B choice -> re-prompt
- Invalid number 1-10 -> re-prompt
- Invalid threshold non-numeric or >100 -> re-prompt
- Missing reports/*.log -> graceful message
- EOF Ctrl+D -> clean exit

## Tested Deployed Structure
Deploy -> ls -R shows attendance_tracker_Joseph-D-Thon/Helpers/assets.csv, config.json (600), attendance_checker.py (+x), reports/ empty
After Run -> reports/attendance.log and absent.log created
After Archive -> archives/attendance/attendance_YYYYMMDD_HHMMSS.log and archives/absent/...

## Video
Link: [Add YouTube/Loom link here - due Oct 16] Will show live marking P/A, archive, and Ctrl+C trap demo with unzip -l

## Git
Repo: deploy_agent_Joseph-D-Thon, main branch, clear commits, script runs end-to-end without crash.
