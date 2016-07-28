# MyUtils

Started writing some Utility programs

**TransactionsCalci.sh**  (This is initial version, more to come)

This program is intended to determine number of transactions executed on fabric based on optional start and end block numbers provided (else it will)
Please note if -s (Starting block number) option is not provided it defaults to block 1, similarly if -e (End block number) option is not provided it defaults to chain height. Also caluclates the time taken to execute the number of transactions

use curl command to download this file

```
curl -L https://raw.githubusercontent.com/ratnakar-asara/MyUtils/master/TransactionsCalci.sh -o TransactionsCalci.sh

chmod +x TransactionsCalci.sh
```

__USAGE__ :
```
TransactionsCalci.sh [OPTIONS]

./TransactionsCalci.sh -i http://IP:PORT -s <START_BLOCK_NUM> -e <END_BLOCK_NUM> -l

OPTIONS:
 -h/?   - Prints usage message
 -i	    - IP along with HOST (Default value http://127.0.0.1:5000 )
 -s 	- Block number from where to begin (Default value 1)
 -e 	- Last Block number (Default value chain height)
 -l 	- To enable logging (Write Block info to blocks.txt file)
 
 Example: 

./TransactionsCalci.sh -i http://127.0.0.1:5000 -s 1 -e 10 -l

```

**NOTE**
- As a prerequisite, you need to install Jq - https://stedolan.github.io/jq/download/
- This is just initial version, Yet to add more funcationality (suggestions welcome)
