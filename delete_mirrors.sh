#!/bin/bash

subscriptions_array=( $(nice -n 19 chia data get_subscriptions | jq -r .store_ids[]) )

for sub in "${subscriptions_array[@]}"
do
    echo "Subscription ID: ${sub}"
    coin_id=''
    coin_id=$(nice -n 19 chia data get_mirrors --id ${sub} | jq -r '.mirrors[] | select(.ours == true) | .coin_id')
    if [ ! -z "$coin_id" ]
    then
        echo "Deleting and mirror for coin_id: ${coin_id}"
        nice -n 19 chia data delete_mirror -c ${coin_id}
    else
        echo "None of our mirrors here"
    fi
done
