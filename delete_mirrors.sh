#!/bin/bash

# Fee to include with each transaction (in XCH)
fee=0

subscriptions_array=( $(nice -n 19 chia data get_subscriptions | jq -r .store_ids[]) )

for sub in "${subscriptions_array[@]}"
do
    echo "Subscription ID: ${sub}"
    coin_id=''
    coin_id=$(nice -n 19 chia data get_mirrors --id ${sub} | jq -r '.mirrors[] | select(.ours == true) | .coin_id')
    if [ ! -z "$coin" ]
    then
            coin_ids=($coin_id) # Handle a situation with multiple owned mirrors....
            echo "coin_id is ${coin_id} and array coin_ids is ${coin_ids[*]}"
            for coin in "${coin_ids[@]}"
            do
                echo "Deleting and mirror for coin_id: ${coin}"
                set -x
                nice -n 19 chia data delete_mirror -c ${coin} -m ${fee}
                set +x
            done
    else
        echo "None of our mirrors here"
    fi
done
