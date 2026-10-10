# deploy_agent_Joseph-D-Thon

**Video:** [PASTE LINK HERE]

`deploy_agent.sh` deploys the Student Attendance Tracker, runs it, and archives its logs. It also handles Ctrl+C and Ctrl+Z during deployment.

## Repository
- `deploy_agent.sh` - the script
- `templates/` - the three unmodified source files (`attendance_checker.py`, `assets.csv`, `config.json`)

## How to run
```bash
chmod +x deploy_agent.sh
./deploy_agent.sh
```
I used an interactive menu because the app is interactive too, so deploy, run and archive stay in one place:
```
1) Deploy  2) Run  3) Archive  4) Exit
```
Invalid choices are rejected, and Ctrl+D at the menu exits.

## Feature 1: Deploy
1. **Pre-flight:** checks python3 (prints its version), zip, and the `templates/` folder. It stops with a clear message if one is missing.
2. **Project name:** only letters, numbers, `_` and `-` are allowed, because the script deletes folders by name. An empty or invalid name prints an error and returns to the menu.
3. **Existing project:** if `attendance_tracker_{name}/` exists, the script asks `Overwrite? y/n`. Anything but `y` or `Y` aborts and leaves it untouched.
4. **Structure created:**
```
attendance_tracker_{name}/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
```
`archives/` is created later by Feature 3.
5. **Errors:** if `mkdir` or a `cp` fails (for example permission denied), the script prints an error, removes the half-made folder and returns to the menu.
6. **Roster:** Option A copies the header plus N rows from `templates/assets.csv`. Option B builds N rows from arrays of names and emails inside the script, with both counts at 0. An invalid option, or a count outside 1-10, asks again.
7. **`total_sessions`:** it is one more than the prior sessions in the roster. Each sample row has 4 prior sessions (attendance plus absences), so Option A sets 5. A fresh Option B roster has none, so it sets 1.
8. **Permissions:** `chmod +x` on `attendance_checker.py` and `chmod 600` on `Helpers/config.json`. On a deployed project, `ls -l` showed:
```
-rwxr-xr-x ... attendance_checker.py
-rw------- ... Helpers/config.json
```
9. **Thresholds:** see below.
10. **Verify:** the script prints `ls -R` and `config.json`, then starts the app. A successful start shows the structure, roster and config work together.

## Threshold update
After the roster, the script asks `Update alert thresholds? y/n`. On `y`:
- It asks for warning (default 75) and failure (default 50). Enter takes the default.
- Each value must be digits only and 0-100, otherwise it asks again (tested with `abc` and `150`).
- `sed -i` changes only the number after `"warning":` and `"failure":`, so the file layout stays the same.

## Feature 2: Run
Menu option 2 asks for the project name, checks the folder exists, and runs `python3 attendance_checker.py` inside it. A missing project prints an error and returns to the menu.

## Feature 3: Archive
Menu option 3 asks for the project name and checks the folder exists. It copies each log into its own folder with a timestamp:
```
archives/attendance/attendance_YYYYMMDD_HHMMSS.log
archives/absent/absent_YYYYMMDD_HHMMSS.log
```
For example, `attendance_20261010_194025.log` and `absent_20261010_194025.log`. The script prints each source and destination path. The originals stay in `reports/`. `absent.log` only exists if someone was marked absent. If a log is missing, the script says so and continues.

## Signal handling (the archive trigger)
During a deployment, `trap` catches SIGINT (Ctrl+C) and SIGTSTP (Ctrl+Z). The script then:
1. prints that the deployment was interrupted,
2. zips the incomplete project into `attendance_tracker_{name}_archive.zip`,
3. deletes the incomplete folder, but only if the zip succeeded,
4. exits.

If the signal comes before the project folder exists (for example at the name prompt), nothing is archived. The trap is turned off before the marking session, so Ctrl+C there only stops the app.

### How to test it
```bash
./deploy_agent.sh      # choose 1, name it trapdemo
# at the roster prompt press Ctrl+C (repeat with Ctrl+Z)
ls
unzip -l attendance_tracker_trapdemo_archive.zip
```
You should see the `.zip` and no `attendance_tracker_trapdemo` folder. The zip holds `attendance_checker.py`, `Helpers/config.json`, `Helpers/assets.csv` (header only, because the roster was not built yet) and an empty `reports/`.

## How I tested
- Option A with 10 students, and Option B with 3 (`total_sessions` 5 and 1).
- Thresholds: Enter for defaults, `abc`, `150`, and valid values.
- Ctrl+C and Ctrl+Z mid-deploy; Ctrl+C at the overwrite prompt (existing project kept); Ctrl+C during marking (nothing deleted).
- Project names such as `my test` and `../x` (rejected).
- A read-only folder (mkdir fails) and an unreadable `templates/config.json` (copy fails).
- Archive with both logs, with only `attendance.log`, and with a missing project.
- Structure: the `ls -R` output from deploy, the printed `config.json`, and the app starting.

## Known limitations
- The script does not check that the failure threshold is lower than the warning threshold.
- Running the app a second time on the same project makes the counts exceed `total_sessions`. The app prints a note and carries on.
