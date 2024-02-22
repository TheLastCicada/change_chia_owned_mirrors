# change_chia_owned_mirrors

Have numerous Chia Datalayer subscriptions that you are mirroring and want to change the address of your mirrors in bulk?  Then this Bash script is for you!

`fix_mirrors.sh` is for finding a mirror you own with the wrong URL and replacing it with a new mirror with the right URL.

`delete_mirrors.sh` will loop through all of your owned subscriptions and delete them one by one.

# Variables

At the top of the file are 5 variables that need to be set:

* **newURL**: This is what the new mirror should be set to.  Can have a path, could be an IP.  Should have http:// or https://.
* **badURL**: URL to replace. Mirror URLs will only be replaced if they contain this bad URL.
* **fee**: Fee to use for the new mirror transaction.
* **amount**: Coin amount for the mirror coin. 

# Coin Splitting

In order to change the mirror URL for many subscriptions at once, you'll need enough individual coins for each transaction to come from a different coin.  You can use the Chia CLI with `chia wallet coins split` to split one of your existing coins into enough coins to cover all your subscriptions. Make sure each new coin is big enough to cover the `amount` and `fee`. 
