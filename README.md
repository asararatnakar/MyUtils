# MyUtils

Some basic utility scripts/programs

##1. TransactionsCalci.sh

This program is intended to determine number of transactions executed on fabric, based on optional flags start and end block numbers provided.Please note if -s (Starting block number) option is not provided it defaults to block 1, similarly if -e (End block number) option is not provided it defaults to chain height. Also caluclates the time taken to execute the number of transactions

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

#2. QuickTrxCounter.sh

This is a pretty basic version of the above script `TransactionsCalci.sh`.
It just gets the total transactions executed on a Blockchain.
All you need to do is submit the Ip/Port and as a resulult you get Total transactions executed
(Includes both Successful and failure transactions)

```
curl -L https://raw.githubusercontent.com/ratnakar-asara/MyUtils/master/QuickTrxCounter.sh -o QuickTrxCounter.sh

chmod +x QuickTrxCounter.sh
```

__USAGE__ :
```
QuickTrxCounter.sh [OPTIONS]

./QuickTrxCounter.sh http://IP:PORT

OPTIONS:
-http://127.0.0.1:5000 - Provide the http://IP:HOST

 Example: 

./QuickTrxCounter.sh http://127.0.0.1:5000

```

**NOTE**
- As a prerequisite, you need to install **JQ** - https://stedolan.github.io/jq/download/
- These are just initial versions, Yet to add more funcationality (Please suggest for imporvements)

Issue: 
- Cuurently deploy is not cpaturing the timestamp information in Block, hence script considers time stamp from first transaction after deploy trxn (i.e, Invokes)

#3. ascii2text.js

Just a simple script to convert Ascii to charecters

**USAGE**: `node ascii2text.js < value in decima>`

ex:

`node ascii2text.js "65 83 67 73 73"`

Output:

`Text now is : ASCII`

**NOTE**
- As a prerequisite, you need to install **NodeJs**
