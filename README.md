# RotateFile.sh

 Bash script that automates file deletion in a directory according to configurable criteria.

## Features

- Automatic rotation of files in a directory
- File selection using regular expressions (pattern)
- Option to keep only a specific number of recent files
- Silent and dry-run modes for safe testing
- Detailed and customizable output

## Usage

```bash
bash RotateFile.sh --source <directory> [--keep <N>] [--pattern <regex>] [--dry-run] [--silent] [--help]
```

### Options

- `--source <directory>`: **(Required)** Source directory where files will be rotated.
- `--keep <N>`: Number of files to keep (default: 3).
- `--pattern <regex>`: Regular expression to select files (default: generic backup pattern).
- `--dry-run`: Show actions without actually deleting files.
- `--silent`: Reduce output verbosity.
- `--help`, `-h`, `?`: Show help and available options.

### Examples

Keep only the last 5 `.zip` files in `/var/backups`:
```bash
bash RotateFile.sh --source /var/backups --keep 5 --pattern '.*\.zip$'
```

Simulate actions without deleting anything:
```bash
bash RotateFile.sh --source /var/backups --dry-run
```

Scheduled Execution with Crontab:<br>
to run the script every day at 2:00 AM, keeping only the last 7 `.tar.gz` files in `/var/backups` and suppressing output (`--silent`):

```cron
0 2 * * * /bin/bash /path/to/RotateFile.sh --source /var/backups --keep 7 --pattern '.*\.tar\.gz$' --silent
```

## Requirements

- Bash 4+
- Standard Unix commands: `find`, `grep`, `sort`, `awk`, `rm`

## Security Notes

- The script does not contain hardcoded credentials.
- Always verify the directory and pattern before performing actual deletions.

## License

This project is licensed under the MIT License.

## Author

CtrlAltJon
