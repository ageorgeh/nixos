#!/usr/bin/env bash

# Check if help is requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  echo "Usage: $(basename "$0") [--address] [--class-order \"class1 class2 ...\"] [--after class] <command> <monitor_number>"
  echo "  - --address: Use window addresses explicitly instead of focusing (optional)"
  echo "  - --class-order: Order windows by class names, space-separated list (requires --address)"
  echo "  - --after: Start executing commands after finding first window of specified class"
  echo "  - command: Hyprland command to run on each window (required)"
  echo "  - monitor_number: Which monitor to operate on (required)"
  echo ""
  echo "Examples:"
  echo "  $(basename "$0") 'hy3:changegroup untab' 1     # Ungroups windows on monitor 1"
  echo "  $(basename "$0") --address 'togglefloating' 1  # Toggles floating on all windows on monitor 1"
  echo "  $(basename "$0") --address --class-order \"firefox-devedition firefox kitty\" 'togglefloating' 1"
  echo "  $(basename "$0") --after kitty 'movetoworkspace special' 1  # Move windows after kitty to special workspace"
  exit 0
fi

# Parse arguments
use_address=false
class_order=""
after_class=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --address)
      use_address=true
      shift
      ;;
    --class-order)
      if [[ -z "$2" || "$2" == --* ]]; then
        echo "Error: --class-order requires a space-separated list of class names"
        exit 1
      fi
      class_order="$2"
      shift 2
      ;;
    --after)
      if [[ -z "$2" || "$2" == --* ]]; then
        echo "Error: --after requires a class name"
        exit 1
      fi
      after_class="$2"
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

# Check if both command and monitor are provided
if [[ $# -lt 2 ]]; then
  echo "Error: Both command and monitor arguments are required"
  echo "Run '$(basename "$0") --help' for usage information"
  exit 1
fi

custom_command="$1"
target_monitor="$2"

# Validate that the monitor number is a positive integer
if [[ ! "$target_monitor" =~ ^[0-9]+$ ]]; then
  echo "Error: Monitor number must be a positive integer"
  exit 1
fi

if [[ -n "$class_order" && "$use_address" != "true" ]]; then
  echo "Error: --class-order requires --address flag"
  exit 1
fi

if $use_address; then
  echo "Collecting window addresses on monitor $target_monitor"
  
  # Get all windows on the target monitor with their classes
  window_data=$(hyprctl clients -j | jq -r ".[] | select(.monitor == $target_monitor) | \"\(.address)|\(.class)\"")
  
  # Create arrays to hold window addresses and classes
  declare -A windows_by_class
  declare -a all_addresses
  declare -a all_classes
  
  # Parse the window data
  while IFS= read -r line; do
    if [[ -n "$line" ]]; then
      address="${line%%|*}"
      class="${line#*|}"
      
      all_addresses+=("$address")
      all_classes+=("$class")
      
      # Store address by class for ordered processing
      if [[ -z "${windows_by_class[$class]}" ]]; then
        windows_by_class[$class]="$address"
      else
        windows_by_class[$class]+=" $address"
      fi
    fi
  done <<< "$window_data"
  
  echo "Found ${#all_addresses[@]} windows on monitor $target_monitor"
  
  # Create ordered list of window addresses
  declare -a ordered_addresses
  
  if [[ -n "$class_order" ]]; then
    echo "Ordering windows by specified class order: $class_order"
    
    # Process windows in the specified class order
    for class in $class_order; do
      if [[ -n "${windows_by_class[$class]}" ]]; then
        for addr in ${windows_by_class[$class]}; do
          ordered_addresses+=("$addr")
        done
        # Remove these windows from consideration to avoid duplication
        unset windows_by_class["$class"]
      fi
    done
    
    # Add any remaining windows that weren't in the specified class order
    for class in "${!windows_by_class[@]}"; do
      for addr in ${windows_by_class[$class]}; do
        ordered_addresses+=("$addr")
      done
    done
  else
    # If no class order specified, use original order
    ordered_addresses=("${all_addresses[@]}")
  fi
  
  # If --after is specified, find the starting point
  start_processing=false
  if [[ -n "$after_class" ]]; then
    echo "Will start executing after first window with class: $after_class"
    # Find the first window of the specified class
    target_index=-1
    for i in "${!all_addresses[@]}"; do
      if [[ "${all_classes[$i]}" == "$after_class" ]]; then
        target_index=$i
        break
      fi
    done
    
    if [[ $target_index -eq -1 ]]; then
      echo "Warning: No window with class '$after_class' found. No commands will be executed."
    fi
  else
    # If no --after flag, start processing from the beginning
    start_processing=true
  fi
  
  # Apply the command to each window address in the determined order
  for address in "${ordered_addresses[@]}"; do
    # Find class for this address to show in output
    current_class=""
    for i in "${!all_addresses[@]}"; do
      if [[ "${all_addresses[$i]}" == "$address" ]]; then
        current_class="${all_classes[$i]}"
        break
      fi
    done
    
    # If we found the after_class, start processing from the next window
    if [[ -n "$after_class" && "$current_class" == "$after_class" && "$start_processing" == "false" ]]; then
      echo "Found window with class '$after_class', will start processing from next window"
      start_processing=true
      continue
    fi
    
    # Skip if we haven't started processing yet
    if [[ "$start_processing" == "false" ]]; then
      echo "Skipping $address (Class: $current_class) - waiting for '$after_class'"
      continue
    fi
    
    echo "Running '$custom_command address:$address' (Class: $current_class)"
    hyprctl dispatch "$custom_command address:$address" >/dev/null
  done
  
  echo "Completed running '$custom_command' on windows on monitor $target_monitor"
else
  # Focus specified monitor
  hyprctl dispatch focusmonitor "$target_monitor" >/dev/null
  echo "Focusing on monitor $target_monitor, running command: '$custom_command'"

  # If --after is specified, we need to find the window with that class
  start_processing=false
  if [[ -n "$after_class" ]]; then
    echo "Will start executing after first window with class: $after_class"
    
    # Get initial active window
    initial_window=$(hyprctl activewindow -j | jq -r '.address')
    current_window="$initial_window"
    previous_window=""
    
    # First, loop through windows just to find the specified class
    found_after_class=false
    max_iterations=50
    iteration=0
    
    while [ "$iteration" -lt "$max_iterations" ]; do
      ((iteration++))
      
      # Check if current window has the specified class
      current_class=$(hyprctl activewindow -j | jq -r '.class')
      
      if [[ "$current_class" == "$after_class" ]]; then
        echo "Found window with class '$after_class', will start processing from next window"
        found_after_class=true
        break
      fi
      
      # Move focus right
      hyprctl dispatch hy3:movefocus r, visible, nowrap >/dev/null
      
      # Get the new active window
      previous_window="$current_window"
      current_window=$(hyprctl activewindow -j | jq -r '.address')
      
      # If we returned to the initial window or focus didn't change, we didn't find the class
      if [ "$current_window" = "$initial_window" ] && [ "$iteration" -gt 1 ] || [ "$current_window" = "$previous_window" ]; then
        echo "Warning: No window with class '$after_class' found. No commands will be executed."
        break
      fi
    done
    
    # If we didn't find the class, exit
    if [[ "$found_after_class" != "true" ]]; then
      exit 0
    fi
    
    # Move to the next window (past the target class)
    hyprctl dispatch hy3:movefocus r, visible, nowrap >/dev/null
    
    # Reset for the actual command execution
    initial_window=$(hyprctl activewindow -j | jq -r '.address')
  else
    # If no --after flag, get initial active window
    initial_window=$(hyprctl activewindow -j | jq -r '.address')
  fi

  current_window="$initial_window"
  previous_window=""

  # Set a safety maximum number of iterations to prevent infinite loops
  max_iterations=50
  iteration=0

  # Loop through windows, applying the command to each one
  while [ "$iteration" -lt "$max_iterations" ]; do
    # Increment iteration counter
    ((iteration++))
    
    # Run the custom command on current window
    current_class=$(hyprctl activewindow -j | jq -r '.class')
    echo "Running '$custom_command' on window (Class: $current_class)"
    hyprctl dispatch $custom_command >/dev/null
    
    # Move focus right
    hyprctl dispatch hy3:movefocus r, visible, nowrap >/dev/null
    
    # Get the new active window
    previous_window="$current_window"
    current_window=$(hyprctl activewindow -j | jq -r '.address')
    
    # If we returned to the initial window or focus didn't change, we're done
    if [ "$current_window" = "$initial_window" ] && [ "$iteration" -gt 1 ] || [ "$current_window" = "$previous_window" ]; then
      echo "Completed running '$custom_command' on windows on monitor $target_monitor after $iteration iterations"
      break
    fi
  done
fi