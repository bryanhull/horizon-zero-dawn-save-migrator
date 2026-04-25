# Horizon Zero Dawn: Remastered Save Migrator (Steam Deck / Linux)

A Bash script designed to easily migrate your saves from *Horizon Zero Dawn: Complete Edition* (or from downloaded Steam Cloud backups) into the new *Horizon Zero Dawn Remastered* edition.

This is especially useful for Steam Deck and Linux users where the two games are installed in completely isolated "Proton prefixes" (compatdata folders), making the in-game "Import Game Saves" feature fail to find your old data by default.

## The Problem
When playing on Steam Deck or Linux via Proton, Steam treats the Complete Edition and the Remastered Edition as two completely separate Windows environments. 
Furthermore, if you download your old saves directly from the Steam Cloud website, they download as a messy list of flat files with names like `%WinMyDocuments%Horizon Zero Dawn_Saved Game_autosave0_checkpoint.dat`. The Remastered game *requires* these files to be perfectly organized into specific subfolders (`autosave0/`, `quicksave5/`, etc.) for its Import tool to recognize them.

## What This Script Does
*   **Locates the correct hidden folders:** Automatically finds the Proton prefix for the Remastered game (`2561580`). 
    *   *Note on Proton Prefixes:* The folder ID `2561580` is the official Steam AppID for Horizon Zero Dawn Remastered and is the exact same for every user who purchased the game directly through Steam. If you are using a non-Steam version of the game (e.g., Epic, GOG) added to Steam via "Add a Non-Steam Game", Steam will generate a long, random 10-digit number instead of `2561580`. In that case, you will need to manually adjust the `REMASTERED_APPID` in the script.
*   **Automatic Backups:** Backs up any existing Remastered saves into a timestamped folder before making changes.
*   **Direct Migration (Option 1):** If you still have the Complete Edition (`1151640`) installed, it copies the saves directly over.
*   **Cloud Save Rebuilding (Option 2):** If you uninstalled the old game and downloaded your saves from the Steam Cloud website, you simply point the script to your Downloads folder. It will parse the messy filenames, intelligently rebuild the required classic directory structure, and place them exactly where the Remastered game expects them.

## Usage Instructions

### Step 1: Get Your Saves
*   **If the Complete Edition is still installed on your Deck:** Skip to Step 2.
*   **If you need your Steam Cloud saves:**
    1. Switch your Steam Deck to **Desktop Mode**.
    2. Open a browser and go to [Steam Cloud](https://store.steampowered.com/account/remotestorage).
    3. Find *Horizon Zero Dawn: Complete Edition* and click **Show Files**.
    4. Download the files for the save slots you want to keep. For each save (e.g., `autosave0`), download the `checkpoint.dat`, `icon.png`, and `slotinfo.ini`.
    5. Save them to a single folder (like your `~/Downloads` folder).

### Step 2: Run the Script
1.  Download `hzd_save_migrator.sh` to your Steam Deck.
2.  Open the Terminal (Konsole) in Desktop Mode.
3.  Make the script executable:
    ```bash
    chmod +x ~/Downloads/hzd_save_migrator.sh
    ```
4.  Run the script:
    ```bash
    ~/Downloads/hzd_save_migrator.sh
    ```
5.  Follow the on-screen menu to choose your migration method.

### Step 3: Import In-Game
1.  Return to **Gaming Mode** (or launch Steam from Desktop).
2.  Launch **Horizon Zero Dawn Remastered**.
3.  On the Main Menu or the Load Game screen, select **Import Game Saves**.
4.  The game will detect the structure built by this script and convert your old saves to the new format!

## Disclaimer
This script is provided as-is. It automatically backs up your destination folder, but it is always good practice to keep a manual copy of your most important save files.