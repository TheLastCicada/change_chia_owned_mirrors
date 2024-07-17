#!/bin/bash

# Fee to include with each transaction (in XCH)
fee=0

subscriptions_array=( $(nice -n 19 chia data get_subscriptions | jq -r .store_ids[]) )

for sub in "${subscriptions_array[@]}"
do
    echo "Subscription ID: ${sub}"
    if [ ${sub} = "1019153f631bb82e7fc4984dc1f0f2af9e95a7c29df743f7b4dcc2b975857409" ]
    then
	echo "Owned store found, skipping"
    elif [ ${sub} = "18b6ff2ebf73574d30a39e1ee58efa3b7e8f1b35a4f9e6abd41690ab87bd15c7" ]
    then
	echo "Owned store found, skipping"
    else    
        echo "Unsubscribing from ${sub}"
	chia data unsubscribe --id ${sub} --retain
    fi
done
