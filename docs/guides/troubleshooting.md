# Troubleshooting

## PDF Tools are failing on Windows
**Symptom**: You click "Convert" but it instantly fails, or the loading spinner spins infinitely.
**Cause**: The bundled Python engine may have been blocked by an overzealous antivirus, or the path contains unsupported characters.
**Fix**: Ensure Dastra is extracted to a directory where you have write permissions (e.g., your Desktop or Documents folder). Check your antivirus quarantine.

## Android App Crashes on Start
**Symptom**: The app closes immediately upon opening.
**Cause**: Usually caused by a corrupted SQLite database from a previous aborted installation.
**Fix**: Go to Android Settings > Apps > Dastra > Storage and click "Clear Data".

## "Feature Not Available on this Platform"
**Symptom**: A tool is grayed out or shows an error when opened.
**Cause**: Some tools rely on Windows-specific runtimes (like COM automation for Microsoft Word). These tools are intentionally disabled on Android or Linux.
