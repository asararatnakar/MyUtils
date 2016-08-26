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

#3. CheckHeight.sh

This script is limted to get you the heights of a 4 peer network (Network created from Docker composer or Bluemix Starter/HSBN network type)
compares the heights and tell if all the peers are in sync or not
```
curl -L https://raw.githubusercontent.com/ratnakar-asara/MyUtils/master/CheckHeight.sh -o CheckHeight.sh

chmod +x CheckHeight.sh
```

__USAGE__ :
```
QuickTrxCounter.sh [OPTIONS]

 SAMPLE 1 :
	./ChainHeight.sh

       No IP provided hence defaults to http://127.0.0.1:5000 and get height of a single peer, I assume you are outside vagrant, while peers are running inside vagrant)

 SAMPLE 2 :
	./ChainHeight.sh http://172.17.0.3:5000

       I assume, this IP is used when script is running inside Vagrant env. Get heights of 4 peers and compare their block heights to check if they are in sync or not

 SAMPLE 3 :
	./ChainHeight.sh https://e405f46f-dfaf-abcd-8995-6dd4a6e2d915_vp0-api.zone.blockchain.ibm.com/

       I assume this is a 4 peer network (Bluemix Starter/HSBN) and gets you the heights of the peers and compare their block heights to check if they in sync or not.

```

 **TBD** : __Blocks height alone might not be sufficient for comparision, Should we check hashcodes aswell__

#4. ascii2text.js

Just a simple script to convert Ascii to charecters

**USAGE**: `node ascii2text.js < value in decima>`

ex:

`node ascii2text.js "65 83 67 73 73"`

Output:

`Text now is : ASCII`

**NOTE**
- As a prerequisite, you need to install **NodeJs**
