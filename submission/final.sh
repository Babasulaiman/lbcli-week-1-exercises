#!/bin/bash

# Import helper functions
source .github/functions.sh

# Week One Exercise: Bitcoin Address Generation and Transaction Verification
# This script demonstrates using the key concepts from previous exercises in a practical scenario

# Ensure script fails fast on errors
set -e

# ========================================================================
# STUDENT EXERCISE PART BEGINS HERE - Complete the following sections
# ========================================================================

# Set up the challenge scenario
setup_challenge

# CHALLENGE PART 1: Create a wallet to track your discoveries
echo "CHALLENGE 1: Create your explorer wallet"
echo "----------------------------------------"
echo "Create a wallet named 'btrustwallet' to track your Bitcoin exploration"

# STUDENT TASK: Use bitcoin-cli to create a wallet named "btrustwallet"
bitcoin-cli -regtest createwallet "btrustwallet"
check_cmd "Creating btrustwallet"

# Create a second wallet that will hold the treasure
echo "Now, create another wallet called 'treasurewallet' to fund your adventure"

# STUDENT TASK: Create another wallet called "treasurewallet"
bitcoin-cli -regtest createwallet "treasurewallet"
check_cmd "Creating treasurewallet"

# Generate an address for mining in the treasure wallet
# STUDENT TASK: Generate a new address in the treasurewallet
TREASURE_ADDR=$(bitcoin-cli -regtest -rpcwallet=treasurewallet getnewaddress)
check_cmd "Address generation"
echo "Mining to address: $TREASURE_ADDR"

# Mine some blocks to get initial coins
mine_blocks 101 $TREASURE_ADDR

# CHALLENGE PART 2: Check your starting balance
echo ""
echo "CHALLENGE 2: Check your starting resources"
echo "-----------------------------------------"
echo "Check your wallet balance to see what resources you have to start"

# STUDENT TASK: Get the balance of btrustwallet
BALANCE=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getbalance)
check_cmd "Balance check"
echo "Your starting balance: $BALANCE BTC"

# CHALLENGE PART 3: Generate different address types to collect treasures
echo ""
echo "CHALLENGE 3: Create a set of addresses for your exploration"
echo "---------------------------------------------------------"
echo "The treasure hunt requires 4 different types of addresses to collect funds."
echo "Generate one of each address type (legacy, p2sh-segwit, bech32, bech32m)"

# STUDENT TASK: Generate addresses of each type
LEGACY_ADDR=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getnewaddress "" legacy)
check_cmd "Legacy address generation"

P2SH_ADDR=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getnewaddress "" p2sh-segwit)
check_cmd "P2SH address generation"

SEGWIT_ADDR=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getnewaddress "" bech32)
check_cmd "SegWit address generation"

TAPROOT_ADDR=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getnewaddress "" bech32m)
check_cmd "Taproot address generation"

echo "Your exploration addresses:"
echo "- Legacy treasure map: $LEGACY_ADDR"
echo "- P2SH ancient vault: $P2SH_ADDR"
echo "- SegWit digital safe: $SEGWIT_ADDR"
echo "- Taproot quantum vault: $TAPROOT_ADDR"


echo ""
echo "The treasure hunt begins! Coins are being sent to your addresses..."

send_with_fee "treasurewallet" "$LEGACY_ADDR" 1.0 "First clue: Verify this transaction"
send_with_fee "treasurewallet" "$P2SH_ADDR" 2.0 "Second clue: Needs validation"
send_with_fee "treasurewallet" "$SEGWIT_ADDR" 3.0 "Third clue: Check descriptor"
send_with_fee "treasurewallet" "$TAPROOT_ADDR" 4.0 "Final clue: Message verification"

mine_blocks 6 $TREASURE_ADDR

# CHALLENGE PART 4: Find the total treasure collected
echo ""
echo "CHALLENGE 4: Count your treasures"
echo "-------------------------------"
echo "Treasures have been sent to your addresses. Check how much you've collected!"

NEW_BALANCE=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getbalance)
check_cmd "New balance check"
echo "Your treasure balance: $NEW_BALANCE BTC"

COLLECTED=$(echo "$NEW_BALANCE - $BALANCE" | bc)
check_cmd "Balance calculation"
echo "You've collected $COLLECTED BTC in treasures!"

# CHALLENGE PART 5: Verify that one of your addresses is valid
echo ""
echo "CHALLENGE 5: Validate the ancient vault address"
echo "--------------------------------------------"
echo "To ensure the P2SH vault is secure, verify it's a valid Bitcoin address"

P2SH_VALID=$(bitcoin-cli -regtest validateaddress "$P2SH_ADDR" | jq -r '.isvalid')
check_cmd "Address validation"
echo "P2SH vault validation: $P2SH_VALID"

if [[ "$P2SH_VALID" == "true" ]]; then
    echo "Vault is secure! You may proceed to the next challenge."
else
    echo "WARNING: Vault security compromised!"
    exit 1
fi

# CHALLENGE PART 6: Decode a signed message to reveal a secret
echo ""
echo "CHALLENGE 6: Decode the hidden message"
echo "------------------------------------"
echo "You've found a message signed with the legacy address key."
echo "Verify the signature to reveal the hidden message!"

SECRET_MESSAGE="You've successfully completed the Bitcoin treasure hunt!"
SIGNATURE=$(bitcoin-cli -regtest -rpcwallet=btrustwallet signmessage "$LEGACY_ADDR" "$SECRET_MESSAGE")
check_cmd "Message signing"

echo "Address: $LEGACY_ADDR"
echo "Signature: $SIGNATURE"

echo "In an interactive environment, you would guess the message content."
echo "For CI testing, we'll verify the correct message directly:"

VERIFY_RESULT=$(bitcoin-cli -regtest verifymessage "$LEGACY_ADDR" "$SIGNATURE" "$SECRET_MESSAGE")
check_cmd "Message verification"

echo "Message verification result: $VERIFY_RESULT"

if [[ "$VERIFY_RESULT" == "true" ]]; then
    echo "Message verified successfully! The secret message is:"
    echo "\"$SECRET_MESSAGE\""
else
    echo "ERROR: Message verification failed!"
    exit 1
fi
