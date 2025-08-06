#!/bin/bash

# --- Configuration ---
# Application to use for the quake window
QUAKE_APP_CLASS="Wave"
# QUAKE_APP_NAME="MyQuakeTerminal" # Alternative: if you identify by a specific window name/title
QUAKE_APP_COMMAND="/usr/bin/waveterm"       # Command to launch the app if not running

# File to store the current state of the quake window ("shown" or "hidden")
STATE_FILE_PATH="${HOME}/.waveterm_quake_state"

# Brief pause to allow window to appear after launch (in seconds)
LAUNCH_SLEEP_DURATION="1.5"
# --- End Configuration ---

# --- Helper Functions ---
log_debug() {
    # Uncomment the next line for verbose debugging output
    # echo "DEBUG: $(date +%T.%N) $$: $1" >&2
    : # No-op if commented
}

get_quake_window_id() {
    if [[ -n "$QUAKE_APP_CLASS" ]]; then
        local ids_output
        ids_output=$(kdotool search "$QUAKE_APP_CLASS" 2>/dev/null)

        if [[ -z "$ids_output" ]]; then
            log_debug "No window IDs found for search pattern: $QUAKE_APP_CLASS"
            return 1
        fi
        log_debug "Found potential IDs for pattern '$QUAKE_APP_CLASS': $ids_output"

        for id_from_search in $ids_output; do
            local actual_class_name
            actual_class_name=$(kdotool getwindowclassname "$id_from_search" 2>/dev/null)
            log_debug "Checking ID: $id_from_search, Found Class: '$actual_class_name', Target Class: '$QUAKE_APP_CLASS'"

            if [[ "$actual_class_name" == "$QUAKE_APP_CLASS" ]]; then
                log_debug "Found matching window ID: $id_from_search"
                echo "$id_from_search"
                return 0
            fi
        done
        log_debug "No window ID truly matched class verification for $QUAKE_APP_CLASS after checking all candidates."
        return 1

    elif [[ -n "$QUAKE_APP_NAME" ]]; then
        log_debug "Searching by name: $QUAKE_APP_NAME"
        local id_by_name # Requires similar loop and verification as class-based search if used robustly
        id_by_name=$(kdotool search "$QUAKE_APP_NAME" 2>/dev/null | head -n 1)
        if [[ -n "$id_by_name" ]]; then
             # TODO: Add verification for name-based search similar to class-based
            log_debug "Found window ID by name (basic search): $id_by_name"
            echo "$id_by_name"
            return 0
        else
            log_debug "No window found by name: $QUAKE_APP_NAME"
            return 1
        fi
    else
        echo "Error: QUAKE_APP_CLASS or QUAKE_APP_NAME must be set." >&2
        exit 1
    fi
}

# --- Main Logic ---
log_debug "Script started. Reading state from $STATE_FILE_PATH"
CURRENT_STORED_STATE=$(cat "$STATE_FILE_PATH" 2>/dev/null || echo "hidden") # Default to "hidden" if file not found or empty
log_debug "Current stored state: '$CURRENT_STORED_STATE'"

QUAKE_WINDOW_ID=$(get_quake_window_id)
log_debug "Initial Quake Window ID check: '$QUAKE_WINDOW_ID'"

if [[ "$CURRENT_STORED_STATE" == "shown" ]]; then
    log_debug "State is 'shown'. Attempting to hide (minimize) window."
    if [[ -n "$QUAKE_WINDOW_ID" ]]; then
        log_debug "Minimizing window $QUAKE_WINDOW_ID."
        kdotool windowminimize "$QUAKE_WINDOW_ID"
    else
        log_debug "Window not found to minimize, but that's okay for hiding."
    fi
    echo "hidden" > "$STATE_FILE_PATH"
    log_debug "Updated state to 'hidden' in $STATE_FILE_PATH"
else # Current state is "hidden" or was not set
    log_debug "State is 'hidden'. Attempting to show (activate) window."
    if [[ -z "$QUAKE_WINDOW_ID" ]]; then
        log_debug "Quake window not found initially. Attempting to launch $QUAKE_APP_COMMAND..."
        $QUAKE_APP_COMMAND &
        log_debug "Launched '$QUAKE_APP_COMMAND'. Waiting for $LAUNCH_SLEEP_DURATION s..."
        sleep "$LAUNCH_SLEEP_DURATION"
        QUAKE_WINDOW_ID=$(get_quake_window_id) # Try to get ID after launch

        if [[ -z "$QUAKE_WINDOW_ID" ]]; then
            echo "Error: Failed to find quake window (Class: $QUAKE_APP_CLASS) after launching. Exiting." >&2
            # Do not change state if launch failed
            exit 1
        fi
        log_debug "Found window ID after launch: $QUAKE_WINDOW_ID"
    else
        log_debug "Found existing quake window ID: $QUAKE_WINDOW_ID. Will attempt to activate."
    fi

    # At this point, we should have a QUAKE_WINDOW_ID (either pre-existing or newly launched)
    if [[ -n "$QUAKE_WINDOW_ID" ]]; then
        log_debug "Activating window $QUAKE_WINDOW_ID."
        # Use a more robust window activation sequence
        # First raise the window, then activate it
        kdotool windowraise "$QUAKE_WINDOW_ID"
        kdotool windowactivate "$QUAKE_WINDOW_ID"
        echo "shown" > "$STATE_FILE_PATH"
        log_debug "Updated state to 'shown' in $STATE_FILE_PATH"
    else
        # This should ideally not be reached if launch logic is correct and window appears
        echo "Error: Could not obtain Quake Window ID to activate, even after launch attempt. State remains '$CURRENT_STORED_STATE'." >&2
        exit 1
    fi
fi

log_debug "Script finished."
exit 0
