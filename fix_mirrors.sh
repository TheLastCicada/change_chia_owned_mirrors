#!/bin/bash

#
# Variables
#

newUrl='https://the-ip-or-url-of-your-new-mirror-address.com/' #New mirror address
badURL='127.0.0.1'  #Old mirror address you want to replace
fee='0'
amount='100'

# If your wallet has enough coins to do all the mirror transactions simultaneously,
# set this variable to false.  Use `chia coins split` to create enough coins to
# cover the mirror coin amount and fees for each subscription.  If you don't want
# to ensure you have enough coins, change this to "true" and the script will wait
# for the previous transaction to finish before starting a new one.
wait_for_transactions=true

#
# /Variables
#

subscriptions_array=( $(nice -n 19 chia data get_subscriptions | jq -r .store_ids[]) )

for sub in "${subscriptions_array[@]}"
do
    echo "Subscription ID: ${sub}"
    coin_id=''
    coin_id=$(nice -n 19 chia data get_mirrors --id ${sub} | jq -r --arg badURL "${badURL}" '.mirrors[] | select(.ours == true and any(.urls[]; contains($badURL))) | .coin_id')
    if [ ! -z "$coin_id" ]
    then
        if $wait_for_transactions
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
        echo "Deleting mirror with coin_id ${coin_id}"
        nice -n 19 chia data delete_mirror -m ${fee} -c ${coin_id}
        if $wait_for_transactions
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
        echo "Adding mirror for store_id ${sub}"
        nice -n 19 chia data add_mirror -m ${fee} --id ${sub} --amount ${amount} --url ${newUrl}
        if $wait_for_transactions
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
        echo "No bad mirrors here"
    fi
done

