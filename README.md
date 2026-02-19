
# Individual Summative Lab 

---

## Overview


This script (`setup_project.sh`) automates workspace creation, dynamic configuration, validation, and safe interruption handling.


## Project  Implementation

The script fulfills the lab objectives by:

* Creating the required directory structure automatically.
* Allowing runtime configuration using command-line prompts.
* Editing configuration files using `sed`.
* Handling user interrupts using a **SIGINT trap**.
* Performing environment validation before completion.

---

## Directory Architecture Created

When the script runs, it generates:

```
attendance_tracker_<input>/
│
├── attendance_checker.py
│
├── Helpers/
│   ├── assets.csv
│   └── config.json
│
└── reports/
    └── reports.log
```

`<input>` is the identifier entered by the user.

---

## Prerequisites

Before running the script, ensure:

* Bash environment (Linux / macOS / WSL)
* `python3` installed 

Clone the repo

```bash

git clone https://github.com/lnjoroge-alu/deploy_agent_lnjoroge-alu
```
You will get:
```
setup_project.sh
README.md
source_files/
├── attendance_checker.py
├── assets.csv
├── config.json
└── reports.log
```

---

## How to Run the Script

Make the script executable:

```bash

chmod +x setup_project.sh
```

Run the bootstrap process:

```bash

./setup_project.sh
```

You will be prompted to enter a project identifier (name)

---

## Dynamic Configuration 

The script asks whether you want to update attendance thresholds:

```
Do you want to update attendance thresholds? (y/n)
```

If selected:

* Accepts new **Warning** and **Failure** values.
* Validates numeric input.
* Ensures values are between `0–100`.
* Ensures Failure < Warning.
* Uses `sed` to modify `config.json` **in-place**.

---

## Process Management — Signal Trap

The script includes a **SIGINT handler**:

```bash

trap cleanup_on_interrupt INT
```

If the script is interrupted using **Ctrl+C**:

1. The signal is caught.
2. The partially created directory is archived:

   ```
   attendance_tracker_<input>_archive.tar.gz
   ```
3. The incomplete project directory is deleted.
4. The script exits safely.

This prevents workspace clutter and incomplete environments.

---

## Environment Validation (Health Check)

Before finishing, the script performs checks:

* Verifies Python installation:

  ```bash
  python3 --version
  ```
* Confirms required files exist.
* Ensures directory structure is correct.

Warnings are shown if Python is missing, but execution remains controlled.

---

## Concepts Demonstrated

 Automation        -     Bash scripting           
 Validation         -    Regex + `awk`            
 Configuration Editing  -`sed`                    
 Signal Handling    -    `trap`                   
 Archiving         -     `tar`                    
 Error Handling     - Custom logging functions 

---

## Running the Application After Setup

After successful bootstrapping:

```bash

cd attendance_tracker_<input>
python3 attendance_checker.py
```

