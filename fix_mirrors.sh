#!/bin/bash

#
# Variables
#
#!/bin/bash

# Define default values
fee='0'
amount='100'
waitForTransactions=true

# Function to display help
display_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -n, --newURL URL          New mirror URL (required)"
    echo "  -b, --badURL URL          Old mirror URL to replace (required)"
    echo "  -f, --fee VALUE           Fee in XCH (default: 0 XCH)"
    echo "  -a, --amount VALUE        Mirror coin amount in mojos (default: 100 mojos)"
    echo "  -w, --waitForTransactions BOOLEAN"
    echo "                            Boolean - Wait for transactions to finish (default: true)"
    echo "  -h, --help                Display this help message"
    echo ""
    echo ""
    echo "Example: ./fix_mirrors.sh -b 127.0.0.1 -n https://my-dl-domain.com -a 300 -f 0.00000001 -w false"
    echo ""
    echo "Note that if waitForTransactions is false, you must have enough individual coins in your"
    echo "Chia wallet to cover the mirror updates. You can check how many coins are in your Chia"
    echo "wallet with 'chia wallet coins list' and create more coins with 'chia wallet coins split'."
    exit 0
}

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -n | --newURL)
            shift
            newURL="$1"
            ;;
        -b | --badURL)
            shift
            badURL="$1"
            ;;
        -f | -m | --fee)
            shift
            fee="$1"
            ;;
        -a | --amount)
            shift
            amount="$1"
            ;;
        -w | --waitForTransactions)
            shift
            waitForTransactions="$1"
            ;;
        -h | --help)
            display_help
            ;;
        *)
            if [[ "$1" == --badURL=* ]]; then
                badURL="${1#*=}"
            else
                echo "Invalid argument: $1"
                exit 1
            fi
            ;;
    esac
    shift
done

# Check for required arguments
if [ -z "$newURL" ] || [ -z "$badURL" ]; then
    echo "Error: --newURL (-n) and --badURL (-b) are required."
    exit 1
fi

# Rest of your script using the variables
echo "newURL: $newURL"
echo "badURL: $badURL"
echo "fee: $fee"
echo "amount: $amount"
echo "waitForTransactions: $waitForTransactions"

#
# /Variables
#

subscriptions_array=( $(nice -n 19 chia data get_subscriptions | jq -r .store_ids[]) )

for sub in "${subscriptions_array[@]}"
do
    coin_id=''
    coin_id=$(nice -n 19 chia data get_mirrors --id ${sub} | jq -r --arg badURL "${badURL}" '.mirrors[] | select(.ours == true and any(.urls[]; contains($badURL))) | .coin_id')
    if [ ! -z "$coin_id" ]
    then
        if $waitForTransactions
        then
            confirmedCount=$(nice -n 19 chia wallet get_transactions --no-paginate | grep "Status: Confirmed" | wc -l)
            totalCount=$(nice -n 19 chia wallet get_transactions --no-paginate | grep "Status:" | wc -l)
            while [ $confirmedCount != $totalCount ]
            do
                echo "Waiting for transaction to be confirmed..."
                confirmedCount=$(nice -n 19 chia wallet get_transactions --no-paginate | grep "Status: Confirmed" | wc -l)
                totalCount=$(nice -n 19 chia wallet get_transactions --no-paginate | grep "Status:" | wc -l)
                sleep 5
            done
        fi
        echo "Deleting mirror for subscription ${sub} with coin_id ${coin_id}"
        nice -n 19 chia data delete_mirror -m ${fee} -c ${coin_id}
        if $waitForTransactions
        then
            confirmedCount=0
            totalCount=1
            while [ $confirmedCount != $totalCount ]
            do
                echo "Waiting for transaction to be confirmed..."
                confirmedCount=$(nice -n 19 chia wallet get_transactions --no-paginate | grep "Status: Confirmed" | wc -l)
                totalCount=$(nice -n 19 chia wallet get_transactions --no-paginate | grep "Status:" | wc -l)
                sleep 5
            done
        fi
        echo "Adding mirror for subscription ${sub}"
        nice -n 19 chia data add_mirror -m ${fee} --id ${sub} --amount ${amount} --url ${newURL}
        if $waitForTransactions
        then
            confirmedCount=0
            totalCount=1
            while [ $confirmedCount != $totalCount ]
            do
                echo "Waiting for transaction to be confirmed..."
                confirmedCount=$(nice -n 19 chia wallet get_transactions --no-paginate | grep "Status: Confirmed" | wc -l)
                totalCount=$(nice -n 19 chia wallet get_transactions --no-paginate | grep "Status:" | wc -l)
                sleep 5
            done
        fi
    else
        echo "No bad mirrors here on subscription ${sub}"
    fi
done

