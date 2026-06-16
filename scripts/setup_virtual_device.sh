#!/bin/bash

# USB Serial Device Symlink Manager
# Purpose: Create persistent symlinks for USB serial devices
# Usage: See help message below

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[38;5;208m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_help() {
    echo "=================================================="
    echo "USB Serial Device Symlink Manager"
    echo "=================================================="
    echo ""
    echo "USAGE:"
    echo -e "  ${RED}$0 list${NC}"
    echo "      List all connected USB serial devices with details"
    echo ""
    echo -e "  ${RED}$0 create <VENDOR_ID> <PRODUCT_ID> <SYMLINK_NAME>${NC}"
    echo "      Create symlink using vendor/product ID only (first matching device)"
    echo "      Example: $0 create 1a86 5723 msfbarcode"
    echo ""
    echo -e "  ${RED}$0 create <VENDOR_ID> <PRODUCT_ID> serial:<SERIAL> <SYMLINK_NAME>${NC}"
    echo "      Create symlink using USB serial number (RECOMMENDED if available)"
    echo "      Example: $0 create 1a86 5723 serial:ABC123 msfbarcode"
    echo ""
    echo -e "  ${RED}$0 create <VENDOR_ID> <PRODUCT_ID> port:<USB_PORT> <SYMLINK_NAME>${NC}"
    echo "      Create symlink using physical USB port location"
    echo "      Example: $0 create 1a86 5723 port:1-1.2 msfbarcode"
    echo ""
    echo -e "  ${RED}$0 remove <SYMLINK_NAME>${NC}"
    echo "      Remove udev rule and symlink"
    echo "      Example: $0 remove msfbarcode"
    echo ""
    echo -e "  ${RED}$0 verify <SYMLINK_NAME>${NC}"
    echo "      Verify if symlink is working"
    echo "      Example: $0 verify msfbarcode"
    echo ""
}

list_devices() {
    echo -e "${BLUE}=================================================="
    echo "Connected USB Serial Devices"
    echo -e "==================================================${NC}"
    echo ""DEVICE_COUNT=0
    declare -a DEVICE_RECOMMENDATIONS

    for DEVICE in /dev/ttyACM* /dev/ttyUSB*; do
        [ -e "$DEVICE" ] || continue

        DEVICE_COUNT=$((DEVICE_COUNT + 1))

        VENDOR=$(udevadm info --query=property --name="$DEVICE" 2>/dev/null | grep "^ID_VENDOR_ID=" | cut -d'=' -f2)
        PRODUCT=$(udevadm info --query=property --name="$DEVICE" 2>/dev/null | grep "^ID_MODEL_ID=" | cut -d'=' -f2)
        VENDOR_NAME=$(udevadm info --query=property --name="$DEVICE" 2>/dev/null | grep "^ID_VENDOR=" | grep -v "ID_VENDOR_ID" | cut -d'=' -f2)
        MODEL_NAME=$(udevadm info --query=property --name="$DEVICE" 2>/dev/null | grep "^ID_MODEL=" | grep -v "ID_MODEL_ID" | cut -d'=' -f2)
        SERIAL=$(udevadm info --query=property --name="$DEVICE" 2>/dev/null | grep "^ID_SERIAL_SHORT=" | cut -d'=' -f2)
        USB_SERIAL=$(udevadm info --query=property --name="$DEVICE" 2>/dev/null | grep "^ID_SERIAL=" | grep -v "ID_SERIAL_SHORT" | cut -d'=' -f2)
        DEVPATH=$(udevadm info --query=property --name="$DEVICE" 2>/dev/null | grep "^DEVPATH=" | cut -d'=' -f2)

        # Extract physical USB port from DEVPATH
        PHYSICAL_PORT=$(echo "$DEVPATH" | grep -oP '(?<=usb[0-9]/)[\d\-\.]+(?=/)')

        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}[$DEVICE_COUNT] $DEVICE${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo "  Vendor ID:        $VENDOR"
        echo "  Product ID:       $PRODUCT"
        [ ! -z "$VENDOR_NAME" ] && echo "  Vendor Name:      $VENDOR_NAME"
        [ ! -z "$MODEL_NAME" ] && echo "  Model Name:       $MODEL_NAME"
        echo ""

        # Build recommendation for this device
        RECOMMENDATION=""
        if [ ! -z "$SERIAL" ]; then
            echo -e "  ${YELLOW}★★★ USB Serial:   $SERIAL${NC}"
            echo -e "      ${YELLOW}(BEST OPTION - Device specific!)${NC}"
            RECOMMENDATION="$0 create $VENDOR $PRODUCT serial:$SERIAL <SYMLINK_NAME>"
        else
            echo -e "  ${RED}USB Serial:       NOT AVAILABLE${NC}"
            if [ ! -z "$PHYSICAL_PORT" ]; then
                RECOMMENDATION="$0 create $VENDOR $PRODUCT port:$PHYSICAL_PORT <SYMLINK_NAME>"
            else
                RECOMMENDATION="$0 create $VENDOR $PRODUCT <SYMLINK_NAME>"
            fi
        fi

        DEVICE_RECOMMENDATIONS+=("$RECOMMENDATION")

        [ ! -z "$USB_SERIAL" ] && echo "  Full USB Serial:  $USB_SERIAL"
        [ ! -z "$PHYSICAL_PORT" ] && echo -e "  ${BLUE}Physical Port:    $PHYSICAL_PORT${NC}" || echo -e "  ${RED}Physical Port:    NOT FOUND${NC}"
        echo ""

        # Show ATTRS
        echo "  UDEV Attributes:"
        udevadm info -a -n "$DEVICE" 2>/dev/null | \
            grep -E "ATTRS\{serial\}|ATTRS\{idVendor\}|ATTRS\{idProduct\}|KERNELS" | \
            head -n 6 | sed 's/^/    /'
        echo ""
    done

    if [ $DEVICE_COUNT -eq 0 ]; then
        echo -e "${RED}✗ No USB serial devices found${NC}"
        exit 1
    else
        echo -e "${BLUE}=================================================="
        echo "Total devices found: $DEVICE_COUNT"
        echo -e "==================================================${NC}"
        echo ""
        echo -e "${YELLOW}RECOMMENDED COMMANDS:${NC}"
        echo ""

        for i in "${!DEVICE_RECOMMENDATIONS[@]}"; do
            echo -e "${GREEN}Device $((i+1)):${NC}"
            echo -e "  ${RED}${DEVICE_RECOMMENDATIONS[$i]}${NC}"
            echo ""
        done

        echo -e "${YELLOW}USAGE NOTES:${NC}"
        echo ""
        echo "1. If you see ★★★ USB Serial:"
        echo "   → Use the serial-based command (MOST RELIABLE)"
        echo "   → Device will be recognized regardless of USB port"
        echo ""
        echo "2. If USB Serial is NOT AVAILABLE:"
        echo "   → If physical port is shown: Use port-based command"
        echo "   → Port location MUST remain fixed (same USB socket)"
        echo ""
        echo "3. If both serial and port are NOT FOUND:"
        echo "   → Use vendor/product only (first matching device)"
        echo "   → May cause issues with multiple identical devices"
        echo ""
    fi
}

create_symlink() {
    local VENDOR_ID="$1"
    local PRODUCT_ID="$2"
    local IDENTIFIER="$3"
    local SYMLINK_NAME="$4"

    local USE_SERIAL=false
    local USE_PORT=false
    local SERIAL_NUMBER=""
    local USB_PORT=""

    # Parse identifier
    if [[ "$IDENTIFIER" == serial:* ]]; then
        USE_SERIAL=true
        SERIAL_NUMBER="${IDENTIFIER#serial:}"
    elif [[ "$IDENTIFIER" == port:* ]]; then
        USE_PORT=true
        USB_PORT="${IDENTIFIER#port:}"
    else
        # No identifier, just vendor/product
        SYMLINK_NAME="$IDENTIFIER"
    fi

    echo -e "${BLUE}Creating symlink for:${NC}"
    echo "  Vendor ID:  $VENDOR_ID"
    echo "  Product ID: $PRODUCT_ID"
    [ "$USE_SERIAL" = true ] && echo "  USB Serial: $SERIAL_NUMBER"
    [ "$USE_PORT" = true ] && echo "  USB Port:   $USB_PORT"
    echo "  Symlink:    /dev/$SYMLINK_NAME"
    echo ""

    # Search for matching device
    DEVICE_FOUND=false
    MATCHED_DEVICE=""

    for DEVICE in /dev/ttyACM* /dev/ttyUSB*; do
        [ -e "$DEVICE" ] || continue

        CURRENT_VENDOR=$(udevadm info --query=property --name="$DEVICE" 2>/dev/null | grep "^ID_VENDOR_ID=" | cut -d'=' -f2)
        CURRENT_PRODUCT=$(udevadm info --query=property --name="$DEVICE" 2>/dev/null | grep "^ID_MODEL_ID=" | cut -d'=' -f2)

        # Check vendor/product match
        if [ "$CURRENT_VENDOR" != "$VENDOR_ID" ] || [ "$CURRENT_PRODUCT" != "$PRODUCT_ID" ]; then
            continue
        fi

        # Check serial if specified
        if [ "$USE_SERIAL" = true ]; then
            CURRENT_SERIAL=$(udevadm info --query=property --name="$DEVICE" 2>/dev/null | grep "^ID_SERIAL_SHORT=" | cut -d'=' -f2)

            if [ -z "$CURRENT_SERIAL" ]; then
                echo -e "${YELLOW}⚠ Device $DEVICE has no USB serial number${NC}"
                continue
            fi

            if [ "$CURRENT_SERIAL" != "$SERIAL_NUMBER" ]; then
                echo "  Skipping $DEVICE (serial: $CURRENT_SERIAL, expected: $SERIAL_NUMBER)"
                continue
            fi
        fi

        # Check port if specified
        if [ "$USE_PORT" = true ]; then
            DEVPATH=$(udevadm info --query=property --name="$DEVICE" 2>/dev/null | grep "^DEVPATH=" | cut -d'=' -f2)
            CURRENT_PORT=$(echo "$DEVPATH" | grep -oP '(?<=usb[0-9]/)[\d\-\.]+(?=/)')

            if [ "$CURRENT_PORT" != "$USB_PORT" ]; then
                echo "  Skipping $DEVICE (port: $CURRENT_PORT, expected: $USB_PORT)"
                continue
            fi
        fi

        DEVICE_FOUND=true
        MATCHED_DEVICE="$DEVICE"
        echo -e "${GREEN}✓ Device found: $DEVICE${NC}"
        break
    done

    if [ "$DEVICE_FOUND" = false ]; then
        echo -e "${RED}✗ ERROR: No matching device found${NC}"
        echo ""
        echo "Run '$0 list' to see available devices"
        exit 1
    fi

    # Create udev rule
    RULE_FILE="/etc/udev/rules.d/99-${SYMLINK_NAME}.rules"

    if [ "$USE_SERIAL" = true ]; then
        RULE="SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"$VENDOR_ID\", ATTRS{idProduct}==\"$PRODUCT_ID\", ATTRS{serial}==\"$SERIAL_NUMBER\", SYMLINK+=\"$SYMLINK_NAME\", MODE=\"0666\", GROUP=\"dialout\""
    elif [ "$USE_PORT" = true ]; then
        RULE="SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"$VENDOR_ID\", ATTRS{idProduct}==\"$PRODUCT_ID\", KERNELS==\"$USB_PORT\", SYMLINK+=\"$SYMLINK_NAME\", MODE=\"0666\", GROUP=\"dialout\""
    else
        RULE="SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"$VENDOR_ID\", ATTRS{idProduct}==\"$PRODUCT_ID\", SYMLINK+=\"$SYMLINK_NAME\", MODE=\"0666\", GROUP=\"dialout\""
    fi

    echo "$RULE" | sudo tee "$RULE_FILE" > /dev/null

    echo -e "${GREEN}✓ Udev rule created: $RULE_FILE${NC}"
    echo "  Rule: $RULE"
    echo ""

    # Reload udev
    sudo udevadm control --reload-rules
    sudo udevadm trigger

    sleep 2

    # Verify
    if [ -L "/dev/$SYMLINK_NAME" ]; then
        ACTUAL_DEVICE=$(readlink -f "/dev/$SYMLINK_NAME")
        echo -e "${GREEN}✓ SUCCESS!${NC}"
        echo "  Symlink: /dev/$SYMLINK_NAME → $ACTUAL_DEVICE"
    else
        echo -e "${YELLOW}⚠ Symlink not yet active${NC}"
        echo "  Try unplugging and replugging the device"
        echo "  Or run: sudo udevadm trigger"
    fi

    echo ""
    echo "Verification: ls -la /dev/$SYMLINK_NAME"
}

remove_symlink() {
    local SYMLINK_NAME="$1"
    local RULE_FILE="/etc/udev/rules.d/99-${SYMLINK_NAME}.rules"

    if [ -f "$RULE_FILE" ]; then
        sudo rm "$RULE_FILE"
        echo -e "${GREEN}✓ Removed rule: $RULE_FILE${NC}"

        sudo udevadm control --reload-rules
        sudo udevadm trigger

        echo -e "${GREEN}✓ Udev reloaded${NC}"
    else
        echo -e "${YELLOW}⚠ Rule file not found: $RULE_FILE${NC}"
    fi

    if [ -L "/dev/$SYMLINK_NAME" ]; then
        echo -e "${YELLOW}⚠ Symlink still exists: /dev/$SYMLINK_NAME${NC}"
        echo "  It will be removed after device reconnection"
    else
        echo -e "${GREEN}✓ Symlink removed${NC}"
    fi
}

verify_symlink() {
    local SYMLINK_NAME="$1"

    echo -e "${BLUE}Verifying symlink: /dev/$SYMLINK_NAME${NC}"
    echo ""

    if [ -L "/dev/$SYMLINK_NAME" ]; then
        ACTUAL_DEVICE=$(readlink -f "/dev/$SYMLINK_NAME")
        echo -e "${GREEN}✓ Symlink exists${NC}"
        echo "  Points to: $ACTUAL_DEVICE"

        if [ -c "$ACTUAL_DEVICE" ]; then
            echo -e "${GREEN}✓ Device is accessible${NC}"

            # Show permissions
            ls -la "/dev/$SYMLINK_NAME"
            echo ""

            # Show udev info
            echo "Device properties:"
            udevadm info --query=property --name="$ACTUAL_DEVICE" | \
                grep -E "ID_VENDOR_ID|ID_MODEL_ID|ID_SERIAL" | sed 's/^/  /'
        else
            echo -e "${RED}✗ Device is not accessible${NC}"
        fi
    else
        echo -e "${RED}✗ Symlink does not exist${NC}"

        RULE_FILE="/etc/udev/rules.d/99-${SYMLINK_NAME}.rules"
        if [ -f "$RULE_FILE" ]; then
            echo ""
            echo "Rule exists: $RULE_FILE"
            echo "Content:"
            cat "$RULE_FILE" | sed 's/^/  /'
            echo ""
            echo "Try: sudo udevadm trigger"
        else
            echo "No rule found: $RULE_FILE"
        fi
    fi
}

# Main script logic
case "${1:-}" in
    list)
        list_devices
        ;;
    create)
        if [ $# -eq 4 ]; then
            create_symlink "$2" "$3" "$4" ""
        elif [ $# -eq 5 ]; then
            create_symlink "$2" "$3" "$4" "$5"
        else
            echo -e "${RED}✗ Invalid arguments${NC}"
            echo ""
            print_help
            exit 1
        fi
        ;;
    remove)
        if [ $# -eq 2 ]; then
            remove_symlink "$2"
        else
            echo -e "${RED}✗ Invalid arguments${NC}"
            echo ""
            print_help
            exit 1
        fi
        ;;
    verify)
        if [ $# -eq 2 ]; then
            verify_symlink "$2"
        else
            echo -e "${RED}✗ Invalid arguments${NC}"
            echo ""
            print_help
            exit 1
        fi
        ;;
    *)
        print_help
        exit 1
        ;;
esac

exit 0
