# Jellyfin recovery (media host)

Troubleshooting reference for the NixOS `media` host. Configuration: [`hosts/media/services.nix`](../../hosts/media/services.nix), [`hosts/media/default.nix`](../../hosts/media/default.nix).

## Deployment reference

- Service: `jellyfin.service`, managed by systemd/NixOS (not Docker).
- Runs as `plex:plex` (the `plex` user belongs to the `media` group). **Do not assume the service runs as `jellyfin`.**
- Media: `/srv/media/movies` and `/srv/media/tv`. Media files are separate from Jellyfin's application database.
- NixOS default data directory: `/var/lib/jellyfin` (includes `config/`, `log/`, and normally `data/`).
- NixOS default cache directory: `/var/cache/jellyfin`.
- Database location/name can change by Jellyfin version; **discover it**, rather than assuming `jellyfin.db` is the only database.

Confirm actual runtime paths and service arguments after configuration or version changes:

```sh
systemctl cat jellyfin
sudo find /var/lib/jellyfin -type f -name '*.db' -print
```

## 1. Diagnose before changing anything

```sh
systemctl status jellyfin
journalctl -u jellyfin -b -n 250 --no-pager
journalctl -u jellyfin -f  # while reproducing one failed scan
findmnt /srv/media
ls -ld /srv/media /srv/media/movies /srv/media/tv
sudo -u plex test -r /srv/media/movies && sudo -u plex test -x /srv/media/movies && echo 'movies accessible'
sudo -u plex test -r /srv/media/tv && sudo -u plex test -x /srv/media/tv && echo 'tv accessible'
```

Look for the **first concrete error**: missing/unmounted files, permissions, metadata/provider failures, SQLite errors, foreign-key/constraint failures, or scan task failures. A stalled scan does not by itself establish database corruption. Check Jellyfin **Dashboard → Libraries** and **Dashboard → Scheduled Tasks** for the affected library/task. Record the Jellyfin version from the UI and the exact error.

## 2. Back up before database work

Stop Jellyfin first. SQLite may use WAL sidecar files; copying a live `.db` alone is **not** a reliable backup. Archive the complete application data directory, not just one DB.

```sh
sudo systemctl stop jellyfin
df -h /srv/backups
backup="/srv/backups/jellyfin-$(date +%Y%m%d-%H%M%S).tar.gz"
sudo tar -C /var/lib -czf "$backup" jellyfin
sudo tar -tzf "$backup" | head
echo "$backup"  # keep the exact path for restoration
```

The archive includes configuration, database, metadata and other state under `/var/lib/jellyfin`, but **not** the media files in `/srv/media` or the separate disposable cache. Jellyfin 10.11+ also has built-in backups under **Dashboard → Backups**; a stopped-service archive is useful for offline repair and covers this NixOS host's complete data directory.

## 3. Inspect SQLite read-only

With Jellyfin stopped and an archive confirmed, find the actual database. Open it using SQLite (for example, `nix shell nixpkgs#sqlite` if the CLI is not installed):

```sh
sudo find /var/lib/jellyfin -type f -name '*.db' -print
sudo sqlite3 -readonly /var/lib/jellyfin/data/jellyfin.db
```

The database path in the second command is **only an example**; substitute a path found above.

```sql
.tables
.schema BaseItems
PRAGMA table_info('BaseItems');
PRAGMA foreign_key_check;
PRAGMA integrity_check;
SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name;
```

SQLite uses `.tables`, **not** `SHOW tables`. A clean `integrity_check` does not rule out incorrect application records. Inspect columns and relationships before forming queries; table names and columns can change between Jellyfin versions. Quit with `.quit`.

The database inspected on **2026-10-22** had `BaseItems`, `AncestorIds`, `UserData`, `MediaStreamInfos`, `Chapters`, `ItemValues`, `ItemValuesMap`, `BaseItemProviders`, and other tables. It **did not** have `TypedBaseItems`. Don't use old SQL snippets targeting that table or assume columns such as `Type` / `UnratedType` exist without checking `PRAGMA table_info`.

If `BaseItems` has `Id` and `Path` columns, a useful **read-only** starting point for movie-path records is:

```sql
SELECT Id, Path FROM BaseItems
WHERE Path LIKE '/srv/media/movies/%'
LIMIT 50;
```

This is **not** a complete list of all movie-related records: folders, metadata and related rows may have different or empty paths.

## 4. Recovery decision

1. **Bad filesystem access:** repair the mount or permissions, then rescan; don't edit SQLite.
2. **One problematic library:** use Jellyfin's library settings / scan tasks first, making sure the TV library and its watch history remain untouched. Removing a library definition is not the same as deleting its media files.
3. **Evidence of bad database rows:** identify the exact failing item and related tables/foreign keys from the installed schema and logs. Work only on an offline copy or after the full backup above. If a targeted SQL fix is necessary, validate its affected rows and a rollback path before applying it.
4. **Unclear corruption or failed repair:** restore the archive instead of escalating to blanket deletes.

**Never paste broad `DELETE FROM BaseItems`, orphan-cleanup statements, or `rm -rf metadata` from an unrelated Jellyfin version.** Those can remove TV metadata, playback state or linked records. Clearing the cache is not a fix for corrupted SQLite rows. Don't delete `/srv/media/movies` or `/srv/media/tv` when trying to reset the library database.

After a successful repair:

```sh
sudo systemctl start jellyfin
systemctl status jellyfin
journalctl -u jellyfin -b -n 100 --no-pager
```

Verify **both** movie scans and TV series, especially watched state/user data, before treating the incident as resolved.

## 5. Restore the manual backup

Stop Jellyfin. Check that the archive contains `jellyfin/` and that the restored backup is compatible with the installed Jellyfin version. **Do not overwrite the current data without preserving it.**

```sh
sudo systemctl stop jellyfin
archive="/srv/backups/jellyfin-YYYYMMDD-HHMMSS.tar.gz"  # replace with real path
sudo tar -tzf "$archive" | head
sudo mv /var/lib/jellyfin "/var/lib/jellyfin.before-restore-$(date +%Y%m%d-%H%M%S)"
sudo tar -C /var/lib -xzf "$archive"
sudo systemctl start jellyfin
```

The archive preserves original file ownership; check it if the service cannot access files after restoration. The previous data remains under `/var/lib/jellyfin.before-restore-*` until manually reviewed. Jellyfin database migrations are not generally reversible by downgrading alone: restore a backup from the appropriate version.

## Incident note — 2026-10-22

- **Symptom:** movie scanning/updating stalled; old/stale movie data suspected.
- **Goal:** remove the cause without losing TV library data and watched history.
- **Observed:** current DB had `BaseItems` rather than `TypedBaseItems`; `SHOW tables;` failed because this is SQLite.
- **Not established:** actual error from Jellyfin logs, root cause, or a tested safe movie-only deletion procedure. Earlier generic `DELETE` advice was **not validated** against this schema and must not be treated as a working fix.
- **When resolved, record:** Jellyfin version, relevant log error, exact safe fix, and verification of both movies and TV.

## References

- [NixOS Jellyfin service options/source](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/jellyfin.nix)
- [Jellyfin: backup and restore](https://jellyfin.org/docs/general/administration/backup-and-restore/)
