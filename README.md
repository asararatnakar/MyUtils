# MyUtils

Started writing some Utility programs

**trxCalci.sh**  (This is just draft version , I shall update when required)

This progran is intended to determine number of transactions executed on fabric

use curl command to download this file
```curl -L https://raw.githubusercontent.com/ratnakar-asara/MyUtils/master/trxCalci.sh -o TransactionsCalci.sh```

__USAGE__ :
```
TransactionsCalci.sh -i http://IP:PORT -b <BLOCK_NUMBER_FROM> -f

Example: 

./TransactionsCalci.sh -i http://127.0.0.1:5000 -b 1 -f

 -i	- IP along with HOST (Default value http://127.0.0.1:5000 )
 -b 	- Block number from where to begin (Default value 1)
 -f 	- To enable logging (Write Block info to blocks.txt file)
```

