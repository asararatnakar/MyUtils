# Install and Instantiate

This tutorial requires the latest builds for `hyperledger/fabric-baseimage`, `hyperledger/fabric-peer`
and `hyperledger/fabric-orderer`.  Rather than pull from docker hub, you can compile
these images locally to ensure they are up to date.  It is up to the user how to build
the images, although a typical approach is through vagrant.  If you do choose to build
through vagrant, make sure you have followed the steps outlined in
[setting up the development environment](dev-setup/devenv.md).  Then from the
fabric directory within your vagrant environment, execute the `make peer-docker`
and `make orderer-docker` commands.

### Start the network of 2 peers, an orderer, and a CLI
Navigate to the fabric/docs directory in your vagrant environment and start your network:
```bash
docker-compose -f docker-2peer.yml up
```
View your active containers:
```bash
docker ps -a
```

### Get into the CLI container
Now, open a second terminal and navigate once again to your vagrant environment.  
```bash
docker exec -it cli bash
```
You should see the following in your terminal:
```bash
root@ccd3308afc73:/opt/gopath/src/github.com/hyperledger/fabric/peer#
```

### Create and join channel from a remote CLI
From your second terminal, lets create a channel by the name of "myc":
```bash
peer channel create -c myc
```
This will return a genesis block - `myc.block`.  Now, direct both peers to join
channel - `myc` - by passing in the genesis block - `myc.block` in the peer channel
join command:
```bash
CORE_PEER_ADDRESS=peer0:7051 peer channel join -b myc.block
CORE_PEER_ADDRESS=peer1:7051 peer channel join -b myc.block
```

### Install the chaincode on peer0 from the remote CLI
From your second terminal, and still within the CLI container, issue the following
command to install a chaincode named `mycc` with a version of `v0` onto `peer0`.
```bash
CORE_PEER_ADDRESS=peer0:7051 peer chaincode install -n mycc -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 -v v0
```

### Instantiate the chaincode on the channel from a remote CLI
Now, still within the cli container in your second terminal, instantiate the chaincode
`mycc` with version `v0` onto `peer0`.  This instantiation will initialize the chaincode
with key value pairs of ["a","100"] and ["b","200"].
```bash
CORE_PEER_ADDRESS=peer0:7051 peer chaincode instantiate -C myc -n mycc -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 -v v0 -c '{"Args":["init","a","100","b","200"]}'
```

### Query for the value of "a" to make sure the chaincode container has successfully started
Send a query to `peer0` for the value of key `"a"`:
```bash
CORE_PEER_ADDRESS=peer0:7051 peer chaincode query -C myc -n mycc -v v0 -c '{"Args":["query","a"]}'
```
This query should return "100".

### Invoke to make a state change
Send an invoke request to `peer0` to move 10 units from "a" to "b":
```bash
CORE_PEER_ADDRESS=peer0:7051 peer chaincode invoke -C myc -n mycc -v v0 -c '{"Args":["invoke","a","b","10"]}'
```

### Query on the second peer
Issue a query against the key "a" to `peer1`.  Recall that `peer1` has successfully
joined the channel.
```bash
CORE_PEER_ADDRESS=peerX:7051 peer chaincode query -C myc -n mycc -v v0 -c '{"Args":["query","a"]}'
```
This will return an error response because `peer1` does not have the chaincode installed.

### Install on the second peer
Now add the chaincode to `peer1` so that you can successfully perform read write operations.
```bash
CORE_PEER_ADDRESS=peer1:7051 peer chaincode install -n mycc -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 -v v0
```

### Query on the second peer
Now issue the same query request to `peer1`.  
```bash
CORE_PEER_ADDRESS=peerX:7051 peer chaincode query -C myc -n mycc -v v0 -c '{"Args":["query","a"]}'
```

### What does this demonstrate?
- the ability to invoke (alter key value states) is restricted to peers that have the chaincode installed
- the world state of the chaincode is available to all peers on the channel - even those that do not have the chainode installed
- once the chaincode is installed on a peer, invokes and queries can access those states normally
