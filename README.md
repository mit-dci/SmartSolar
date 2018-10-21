# SmartProperty MVP

#### Main Idea 
Each Microgrid energy producer/component will serve as a “lite client” that has access to/exists as an address on the Ethereum blockchain. This address/client will hold funds and continuously execute contract calls on the solar property contract and observe the returned data. With this data, the client will determine if funds are sufficient to continue providing energy from the connected renewable energy source.

#### Key Terms

Infura - An API built by a spoke of Consensys in order to open access to the blockchain through familiar REST patterns.

CloudMQTT - Message queueing service. This system acts as a buffer for data and actions that need to be forwarded. Received messages are organized under “topics” that other devices/servers can listen to. These listeners will be pinged when the topic receives new messages. It’s resources are hosted on AWS

Blockchain - A smart contract will be published on the Ethereum blockchain. This contract will contain the logic for payments by microgrid participants. It will keep track of ownership and transfer ownership as needed (when payments aren’t fulfilled). 

#### Current Implementation
The script found in PhotonClient can be run on the photon which will publish a message to a topic “testTopic” on the MQ. The server code (in InfuraClient) written in go (based on bdjukic's go implememntation) can be run on a local machine to simulate how a cloud hosted server would respond. The server will listen to the topic ”testTopic” and when a message is posted will make an infura call to a dummy contract that was published at "0xec67fad6efe7346d18c908275b879d04454a3dd0". The current transaction doesn’t need gas/to be signed because it’s an eth_call which doesn’t alter or publish to the contract but simply requests information. The InfuraClient will receive the result of the function call.

The current structure for the contract enables new "Solar Systems" to be added, which will be the hardware components that are contributing energy to the system. There is one special role in this contract, which is that of the *approver*. Only the approver has the capability to register new Solar Systems. Each system can be "held" by various parties, also recorded through the contract, where each party holds some portion of the system. When a party makes a payment to the system, they will not only be paying for the energy usage, but also paying off their holding until they eventually own their portion of the system. If a party fails to pay for the energy they have consumed, they will have a grace period over which they can make this late payment; otherwise, the energy coming from the portion of the system that they previously held will be sold back to the grid.

#### Next Steps
The software components are connected and functional. Now we need to begin writing the necessary code that will work with the energy data. We need to parse and hash energy data that is received by the hardware system. Then, write photon script that will publish this data on the MQ service. At the same time, we are working to publish a prototype smart contract (`SolarProperty.sol`) on the testnet that will have the property transaction logic. 


#### Possible Alternative system: 
Because the Raspberry Pi is used in the system as a controller for how energy should be routed from the solar panels, we should explore using the Pi as the main point of communication with the blockchain. The Pi should have the capabilities to make direct HTTP calls using Infura to the blockchain which would completely avoid the need of using the message queuing service and hosting another server. This is advisable because the message queuing service and Go server would be hosted on centralized services and cost more money to maintain. 
The Pi would receive all the sensor data from the batteries/solar panels/critical loads and make smart contract function calls that the Go server previously was making. The smart contract would directly return results to the Pi. The Pi can then proceed with determining how the energy in the system should be distributed.