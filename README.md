# MyUtils

Started writing some Utility programs

**trxCalci.sh**  (This is just draft version , I shall update when required)

This progran is intended to determine number of transactions executed on fabric

use curl command to download this file
```curl -L https://raw.githubusercontent.com/ratnakar-asara/MyUtils/master/trxCalci.sh -o TransactionsCalci.sh```

__USAGE__ :
```
TransactionsCalci.sh -i http://IP:PORT -b <BLOCK_NUMBER_FROM> -e
Example: 

./TransactionsCalci.sh -i http://127.0.0.1:5000 -b 2 -e

here flag e is to enable logging
```
