# Change Chia Owned Mirrors

Have numerous Chia Datalayer subscriptions that you are mirroring and want to change the address of your mirrors in bulk?  Then this Bash script is for you!

`fix_mirrors.sh` is for finding a mirror you own with the wrong URL and replacing it with a new mirror with the right URL.

`delete_mirrors.sh` will loop through all of your owned subscriptions and delete them one by one.

# Usage

    Options:
      -n, --newURL URL          New mirror URL (required)
      -b, --badURL URL          Old mirror URL to replace (required)"
      -f, --fee VALUE           Fee in XCH (default: 0 XCH)
      -a, --amount VALUE        Mirror coin amount in mojo (default: 100 mojos)
      -w, --waitForTransactions BOOLEAN"
                                Boolean - Wait for transactions to finish (default: true)"
      -h, --help                Display help

**Example:**  
`./fix_mirrors.sh -b 127.0.0.1 -n https://my-dl-domain.com -a 300 -f 0.00000001 -w false"`
    
Note that if waitForTransactions is false, you must have enough individual coins in your Chia wallet to cover the mirror updates. You can check how many coins are in your Chia wallet with 'chia wallet coins list' and create more coins with 'chia wallet coins split'.

# Coin Splitting

In order to change the mirror URL for many subscriptions at once, you'll need enough individual coins for each transaction to come from a different coin.  You can use the Chia CLI with `chia wallet coins split` to split one of your existing coins into enough coins to cover all your subscriptions. Make sure each new coin is big enough to cover the `amount` and `fee`. 
