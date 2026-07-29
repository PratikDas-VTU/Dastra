# Upgrade Guide

## Upgrading to v1.0 RC1

If you are upgrading from an internal alpha or beta build, please note the following breaking changes to local storage:

### 1. Database Schema Changes
The SQLite schema for the `WorkspaceRepository` was significantly upgraded in RC1 to support dynamic tool IDs and better file tracking. 

**Action Required**: The database migration should happen automatically. However, if you experience crashes on launch, you must clear your application data:
- **Windows (Installed)**: Delete `%APPDATA%\Dastra\dastra_workspace.db`
- **Windows (Portable)**: Delete `data\dastra_workspace.db`
- **Android**: Go to App Info > Storage > Clear Data.

### 2. File Output Locations
Dastra now defaults to saving output files in the same directory as the input file, appending `_dastra` to the name. Previous versions saved to a dedicated app folder. You can revert this behavior in Settings.
