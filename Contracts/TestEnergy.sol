pragma solidity ^0.4.17;

//use to test interaction with hardware
//Pi on board should ping stillLiquid 


contract TestEnergy { 
    
    mapping(address => int) lastPayment;
    
    //Create new participant in the network and log the starting datetime
    function makePayment(int date) payable public {
        require(msg.value != 0);
        lastPayment[msg.sender] = date;
    }
    
    //Check if user has kept up with payments
    function stillLiquid(int date) view public returns(bool){
        //set threshold to 24 hours for now
        if (date - lastPayment[msg.sender] < 86400){
            return true;
        } else {
            return false;
        }
    }
    
    //Debugging function to check if datetimes are being logged currectly
    function getLastPaymentDate() view public returns(int){
        return(lastPayment[msg.sender]);
    }
}