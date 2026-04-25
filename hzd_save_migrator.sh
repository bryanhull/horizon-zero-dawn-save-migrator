#!/usr/bin/env bash

# Horizon Zero Dawn: Remastered Save Migrator
# This script helps migrate saves from Horizon Zero Dawn: Complete Edition 
# or Steam Cloud backups to the Remastered edition on Steam Deck / Linux.

set -e

# Define paths and AppIDs
STEAM_COMPAT_DIR="$HOME/.local/share/Steam/steamapps/compatdata"
REMASTERED_APPID="2561580"
CLASSIC_APPID="1151640"

REMASTERED_DOCS="$STEAM_COMPAT_DIR/$REMASTERED_APPID/pfx/drive_c/users/steamuser/Documents"
REMASTERED_SAVE_DIR="$REMASTERED_DOCS/Horizon Zero Dawn/Saved Game"
CLASSIC_SAVE_DIR="$STEAM_COMPAT_DIR/$CLASSIC_APPID/pfx/drive_c/users/steamuser/Documents/Horizon Zero Dawn/Saved Game"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}    Horizon Zero Dawn: Remastered Save Migrator       ${NC}"
echo -e "${GREEN}======================================================${NC}"

# Check if Remastered compatdata exists
if [ ! -d "$REMASTERED_DOCS" ]; then
    echo -e "${RED}Error: Horizon Zero Dawn Remastered compatdata folder not found.${NC}"
    echo -e "Please ensure the game is installed and has been launched at least once."
    echo -e "Expected path: $REMASTERED_DOCS"
    exit 1
fi

mkdir -p "$REMASTERED_SAVE_DIR"

show_menu() {
    echo ""
    echo "Please select an option:"
    echo "1) Migrate saves directly from local Complete Edition installation"
    echo "2) Migrate saves from a folder (e.g., downloaded Steam Cloud backups)"
    echo "3) Exit"
    echo ""
    read -p "Enter your choice [1-3]: " choice
    echo ""
}

migrate_from_classic() {
    if [ ! -d "$CLASSIC_SAVE_DIR" ]; then
        echo -e "${RED}Error: Complete Edition save directory not found.${NC}"
        echo -e "Path checked: $CLASSIC_SAVE_DIR"
        return 1
    fi

    echo -e "${YELLOW}Backing up existing Remastered saves (if any)...${NC}"
    mkdir -p "$REMASTERED_SAVE_DIR/backup_$(date +%s)"
    find "$REMASTERED_SAVE_DIR" -maxdepth 1 -type d -name "*save*" -exec cp -r {} "$REMASTERED_SAVE_DIR/backup_$(date +%s)/" \; 2>/dev/null || true

    echo -e "${YELLOW}Copying saves from Complete Edition...${NC}"
    cp -r "$CLASSIC_SAVE_DIR"/* "$REMASTERED_SAVE_DIR/"
    echo -e "${GREEN}Success! Saves migrated. Launch the game and select 'Import Game Saves'.${NC}"
}

migrate_from_folder() {
    read -p "Enter the full path to the folder containing your downloaded saves: " src_dir
    
    # Expand tilde if present
    src_dir="${src_dir/#\~/$HOME}"

    if [ ! -d "$src_dir" ]; then
        echo -e "${RED}Error: Directory does not exist: $src_dir${NC}"
        return 1
    fi

    echo -e "${YELLOW}Backing up existing Remastered saves (if any)...${NC}"
    mkdir -p "$REMASTERED_SAVE_DIR/backup_$(date +%s)"
    find "$REMASTERED_SAVE_DIR" -maxdepth 1 -type d -name "*save*" -exec cp -r {} "$REMASTERED_SAVE_DIR/backup_$(date +%s)/" \; 2>/dev/null || true

    echo -e "${YELLOW}Processing saves from $src_dir...${NC}"
    
    local count=0

    # This loop finds all checkpoint.dat files and intelligently recreates the folder structure.
    # It handles both standard subfolders and "flat" files downloaded from Steam Cloud 
    # (e.g., %WinMyDocuments%Horizon Zero Dawn_Saved Game_autosave0_checkpoint.dat)
    while read -r file; do
        if [[ "$file" =~ (autosave[0-9]+|quicksave[0-9]+|manualsave[0-9]+) ]]; then
            slot="${BASH_REMATCH[1]}"
            mkdir -p "$REMASTERED_SAVE_DIR/$slot"
            
            # Base name for finding corresponding .ini and .png files
            base_name="${file%checkpoint.dat}"
            
            cp "$file" "$REMASTERED_SAVE_DIR/$slot/checkpoint.dat"
            
            if [[ -f "${base_name}slotinfo.ini" ]]; then
                cp "${base_name}slotinfo.ini" "$REMASTERED_SAVE_DIR/$slot/slotinfo.ini"
            fi
            
            if [[ -f "${base_name}icon.png" ]]; then
                cp "${base_name}icon.png" "$REMASTERED_SAVE_DIR/$slot/icon.png"
            fi
            
            echo " -> Imported $slot"
            ((count++))
        fi
    done < <(find "$src_dir" -type f -name "*checkpoint.dat")

    if [ "$count" -gt 0 ]; then
        echo -e "${GREEN}Success! $count save slot(s) imported.${NC}"
        echo -e "${GREEN}Launch the Remastered game and select 'Import Game Saves' from the menu.${NC}"
    else
        echo -e "${RED}No valid Horizon Zero Dawn saves (*checkpoint.dat) found in that directory.${NC}"
    fi
}

while true; do
    show_menu
    case $choice in
        1)
            migrate_from_classic
            ;;
        2)
            migrate_from_folder
            ;;
        3)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please try again.${NC}"
            ;;
    esac
done
