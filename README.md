# MyUtils

Started writing some Utility programs

**TransactionsCalci.sh**  (This is initial version, more to come)

This progran is intended to determine number of transactions executed on fabric

use curl command to download this file

```
curl -L https://raw.githubusercontent.com/ratnakar-asara/MyUtils/master/TransactionsCalci.sh -o TransactionsCalci.sh
```

__USAGE__ :
```
TransactionsCalci.sh -i http://IP:PORT -b <BLOCK_NUMBER_FROM> -f

Example: 

./TransactionsCalci.sh -i http://127.0.0.1:5000 -b 1 -f

 -i	 - IP along with HOST (Default value http://127.0.0.1:5000 )
 -b 	- Block number from where to begin (Default value 1)
 -f 	- To enable logging (Write Block info to blocks.txt file)
```

**NOTE**
- This is just initial version, Yet to add more funcationality ex: time calculations etc.,(suggestions welcome)
