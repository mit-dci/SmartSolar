pragma solidity ^0.4.11;
contract SolarProperty {

// ### TODO ### ENERGY TARIFF ORACLE ### Electricity Tariff setting ###
// Functionality: scrape docs and APIs of energy utilities and regulations, considering geographic location, and provide a harmonized price. Allow manual configuration and fixed prices. 
// Repeat monthly checks (or eg. every 6 months),i.e. before the begining of a payment cycle.
// Save the files that are used as source and references in the final harmonized prize in IPFS. Hash the IPFS files to block that sets the Tariff (i.e. for this specific system and customer) at that payment cycle.
// Provide proof and certification that ——if the tariff is set by 3rd party variables and computer analyses (i.e. not manually configured)— the oracle has not been compromised and outputs without issues.
// Note: consider yearly adjustment of prices

    uint constant PREPA_PRICE = 0.25; //$/kWh Now set fixed based on an average of Puerto Rico's tariffs. 
    
// # STRUCTURE OF SOLAR SYSTEM #
// The information details and properties that each specific solar system should have 
    struct SolarSystem {
        uint panelSize;     
        uint totalValue;
        address consumer;
        uint percentageHeld;
        uint lastFullPaymentTimestamp;
        uint unpaidUsage; // measured in kWh
        // ADD // This will at least also need the size of the battery bank, inverter size, and geo location.
        // Note: Consider onboarding here the energy meter. The main and most accurate energy meter for the solar system will come from datalogger and IoT monitor of the actual inverter/regulator. The brand and comms protocol these have may defer eg. Schneider vs SMA. 
    }

//  Investor or Issuer puts out the value of the system they want
    struct ProposedDeployment {
        uint panelSize; // insert other physical properties here. /// MW /// Why not insert the whole info in the struct of SolarSystem or of a ProposedSolarSystem (i.e. a struct in a struct)?
        uint totalValue;
        uint256 contractorPayout;

    //  ### WALLETS & ACCOUNTS ### These are the wallets that will interact with this specific solar system. 
    //  Other wallets/agents could be added: Eg. Originator: starts the project and for ex. gets a fixed fee;
    //  eg. a Project "Originator" can do a first System Proposal (i.e. design, engineering, quote/budget) or hire/partner with a solar developer (or e.g. 3rd party consultant) to co-develop the System Proposal 
    //  Subcontractor: works with and not for the contractor; Guarantor: covers payments in case of a breach; Insurer: protects against risks --i.e. financial, social and environmental.
    //  Note: Wallets could be replaced by "Anchor Points" of financial institutions and thus link directly to a bank account (i.e. personal, corporate). (see Stellar funcionality here)
    //  Note: Investor here could be a single finance platform Eg. Neighborly and have a whole set of contracts and processes

        address contractor;
        address consumer;
        address investor;
        address guarantor;
        
        // Must have both confirmations to be valid
        // Other confirmations may be required if it eg. wants to be "3rd party verified"
        bool isConfirmedByContractor;
        bool isConfirmedByConsumer;
    }

    // ### TODO ### STRUCT OF IOT SENSORS RELEVANT TO THE INSTALL ###
    // The 'secure' and open source IoT sensors we have developed and installed by non-invasively 'clamping' the wires in the install should be onboarded and thus have a struct? 
    // Consider its eventual onboarding as separate entity to the solar system but assigned to a solar system to act as a witness that will inform the energy oracle of what its 'seeing'

    /// ### TO-DO ###  DEFINE INVESTOR ### eg. Emulate the role of a Neighborly Muni Bond ####
    /// Set maybe a Struct for investors, which maybe is represented by a single 'investor platfor' eg. Neighborly.
    /// Consider bond structure at first with interest rates. Then make compatible for equity crowdfunding and normal crowdfunding.
    
    /* public variables */
    /// Sets the directory of Solar Systems and deployments that can be accessed in the "network"
    address admin;
    mapping(uint => SolarSystem) public solarSystems;
    mapping(uint => ProposedDeployment) public proposedDeployments;

    /* runs at initialization when contract is executed */
    constructor() public {
        admin = msg.sender;
    }
    
    // getter for proposed deployment
    // Allows key variables of the proposed system and finance model to be called and used throughout the contract
    function getProposedDeploymentDetails(uint _ssAddress) view public returns(uint, uint, uint256, address, address, address, bool){
        return(
            proposedDeployments[_ssAddress].panelSize, 
            proposedDeployments[_ssAddress].totalValue, 
            proposedDeployments[_ssAddress].contractorPayout, 
            proposedDeployments[_ssAddress].consumer,
            proposedDeployments[_ssAddress].contractor,
            proposedDeployments[_ssAddress].investor,
            proposedDeployments[_ssAddress].isConfirmedByContractor
        );
    }
    
    //getter for solar system details
    // # Allows key variables of the proposed system and model to be called and used throughout the contract. 
    function getSolarSystemDetails(uint _ssAddress) view public returns(uint, uint, address, uint){
        return(
            solarSystems[_ssAddress].panelSize, 
            solarSystems[_ssAddress].totalValue,  
            solarSystems[_ssAddress].consumer,
            solarSystems[_ssAddress].percentageHeld
        );
    }

    // ### TO- DO ###  TENDER PROCESS & REQUEST FOR PROPOSALS ###
    // Once an Originator initiates a propoed solar System and Deployment, it needs to be put out for a RFP (Request for Proposal) from contractors/solar developers.
    // The call for RFP should receive an engineering proposal (i.e. not an engineering blueprint level but a general system architecture level), a quote for materials and labor, a deployment plan. 
    // Note: The tender, review and selection process needs to be flexible to cater for different project modalities (eg. a Public tender vs. a private project)

    // ## TODO ## PROCESS OF PRE-VERIFICATION BEFORE IT GETS CONFIRMED //
    // Consider payment before setting the system live. 

    // CONFIRMATION
    // agreement between contractor, participant, and investor
    // Adds the actual numbers and variables, details to the struct proposed Deployments
    function proposeDeployment(uint _ssAddress, uint _payout,  uint _panelSize, uint _totalValue, address _contractor, address _consumer) payable public {
        // TODO: this should be called by a verified investor, so need some way to onboard investors/contractors
        ProposedDeployment memory newDeployment;
        newDeployment.panelSize = _panelSize;
        newDeployment.totalValue = _totalValue;
        newDeployment.contractorPayout = _payout;
        newDeployment.contractor = _contractor;
        newDeployment.consumer = _consumer;
        newDeployment.investor = msg.sender;
        newDeployment.isConfirmedByContractor = false;
        newDeployment.isConfirmedByConsumer = false;
        proposedDeployments[_ssAddress] = newDeployment;
    }

    // TODO // SOLAR ENGINERING DOCUMENTS
    // The developers must present the blueprints of the proposed work before working on it. These must be stored in IPFS and hashed to the contract.
    // These documents will have to get updated at the end of the install and are saved as the blueprint of the 'installed system'

    // Contractor confirms the system has been installed. 
    function confirmDeployment(uint _ssAddress) public {
        if (proposedDeployments[_ssAddress].contractor == msg.sender) {
            proposedDeployments[_ssAddress].isConfirmedByContractor = true;
        } else if (proposedDeployments[_ssAddress].isConfirmedByContractor && proposedDeployments[_ssAddress].consumer == msg.sender) {
            
            //for record keeping
            proposedDeployments[_ssAddress].isConfirmedByConsumer = true;
            
            //create a solarsystem
            addSolarSystem(_ssAddress, msg.sender);
        }
    }

    // ## TODO ## // VERIFICATION OF INSTALLMENT & SENSORS
    // The signature of a 3rd party verifier should be considered as part of onboarding a system and its data. 
    // The verifier confirms system was built according to plan, is compliant with regulation, and has the appropriate working sensors and associated public keys. 
    // This digital signature will allow the sensor data and oracle to commit payment transactions and REC minting. 
    
    // ### CONTRACTOR PAYMENTS ###
    // Allow contractor to collect payout on system, once its confirmed
    // ## TODO ## Consider payouts to be based on installments throughout the buildout process and with energy generation data. 
    // Eg. the contractors receives an upfront payment before the process begins but once the deployment is confirmed, and receives another payment once the witness sensors shows the first generation data.
    //      Final payment to contractor should occur once the system shows steady data and behavior after a selected period of time. It also requires a 3rd party verification of system engineering and metering sensors. 
    function collectPayout(uint _ssAddress) public {
        require(msg.sender == proposedDeployments[_ssAddress].contractor);
        require(proposedDeployments[_ssAddress].isConfirmedByConsumer && proposedDeployments[_ssAddress].isConfirmedByContractor);
        msg.sender.transfer(proposedDeployments[_ssAddress].contractorPayout);
    }

    // ### SOLAR SYSTEM IS INSTALLED & LIVE ###
    // This function will be called once there is confirmation of this system
    // add a new solar panel to our platform and set its properties (_totalValue), 
    // and its uniquely identifying address on the chain
    // Note: There might be multiple addresses of sensor data that will relate to the system and should be live by this time (eg. main 'Testimony Energy Meter' and 'Witness sensors')
    function addSolarSystem(uint _ssAddress, address _consumer) private {
        
        SolarSystem memory newSystem;
        newSystem.totalValue = proposedDeployments[_ssAddress].totalValue;
        
        //TODO: must change this because now refers to block timestamp not current time
        newSystem.lastFullPaymentTimestamp = now;
        newSystem.unpaidUsage = 0;
        newSystem.percentageHeld = 0;
        newSystem.panelSize = proposedDeployments[_ssAddress].panelSize;
        newSystem.consumer = _consumer;

        solarSystems[_ssAddress] = newSystem;
    }

////////// THE BELOW SECTION DEALS WITH OPERATION, PAYMENTs, TRANSFER OF OWNERSHIP etc //////////

    // ## TODO ### ENERGY ORACLE ###
    // Needs to take the data that comes from the official "invasive" datalogger and benchmatk the info 
    // from the non-invasive IoT witness sensors and also check with the solar radiation for that dat. 

    // // ## ENERGY CONSUMED ##
    // Record energy consumed by panel at target SSAddress by consumer (called by solar panel)
    function energyConsumed(address ssAddress, address consumer, uint energyConsumed) {
         require((msg.sender == admin) || (msg.sender == ssAddress));

         solarSystems[ssAddress].holders[consumer].unpaidUsage += energyConsumed;
     }
    
    // ## TODO ## Solar energy Generated ##
    // The amount of energy consumed at some point in the customer building may be less or more than the solar energy generated. 
    // These two numbers (i.e. generation and consumption) need to be differentiated, and define payments based on theit relationship.

    // ## TODO ## Define the payment cycle ##
    // Consider making payments every two weeks or every month

    // // ## MAKE PAYMENTS ##
    // Make a payment from consumer toward any unpaid balance on the panel at ssAddress
    function makePayment(address ssAddress, address consumer, uint amountPaid) public {
        require((msg.sender == admin) || (msg.sender == consumer));

         uint amountPaidInEnergy = amountPaid/PREPA_PRICE; 

         Holder storage consumerHolder = solarSystems[ssAddress].holders[consumer];
         if (amountPaidInEnergy >= consumerHolder.unpaidUsage) {
             consumerHolder.lastFullPaymentTimestamp = now;
         }
        
         addSSHolding(amountPaid/solarSystems[ssAddress].totalValue*100, ssAddress, consumer); // transfer over a portion of ownership
         consumerHolder.unpaidUsage -= amountPaidInEnergy; // update the unpaid balance 
     }

    // // ## TRANSFER % OWNERSHIP OF SOLAR ##
    // Transfer percentTransfer percent of holding of solar system at targetSSAddress to the user with address 'to'
     function addSSHolding(uint percentTransfer, address targetSSAddress, address to) public {
         require(msg.sender == admin);

         mapping(address => Holder) targetSSHolders = solarSystems[targetSSAddress].holders;
         require(targetSSHolders[admin].percentageHeld >= percentTransfer);

         if (targetSSHolders[to].holdingStatus == HoldingStatus.HELD) {
             if (targetSSHolders[to].percentageHeld + percentTransfer >= 100) { // fully paid off!
                 grantOwnership(targetSSAddress, to);
             } else {
                 targetSSHolders[to].percentageHeld += percentTransfer;
                 targetSSHolders[admin].percentageHeld -= percentTransfer;
             }
         } else { // this is their first payment towards this solar system
             targetSSHolders[to] = Holder({
                 percentageHeld: percentTransfer,
                 holdingStatus: HoldingStatus.HELD,
                 lastFullPaymentTimestamp: now,
                 unpaidUsage: 0
             });
         }
     }

    // MW // Why are add and remove Holding separate functions if they have to happen simulatenously and are dependent?
    // shouldn't there be a function transferOwnerships that does both of these things at once?

    // // Reclaim percentTransfer percent of holding of solar system at targetSSAddress currently held by user with address 'from' 
     function removeSSHolding(uint percentTransfer, address targetSSAddress, address from) public {
         require((msg.sender == admin) || (msg.sender == from));

         mapping(address => Holder) targetSSHolders = solarSystems[targetSSAddress].holders;
         require(targetSSHolders[from].percentageHeld >= percentTransfer);

         targetSSHolders[from].percentageHeld -= percentTransfer;
         targetSSHolders[admin].percentageHeld += percentTransfer;
     }

     // ## TODO ## REQUEST THE MINTING OR A RENEWABLE ENERGY AND CARBON CERTIFICATE
     // Integrate the devices with swytch (maybe do this previously) and receive here their an erc721 REC token. 
     // Use EIA carbon data for puerto rico to prototype the carbon offset. 
     // Consider using oraclize.it to API the data from the EIA website https://www.eia.gov/state/data.php?sid=RQ#CarbonDioxideEmissions)

    // // Grant ownership to newOwner of whatever portion of the solar panel at targetSSAddress they currently hold
    // MW // what is the difference between changing holdings and granting ownership? Should ownership be the step applied once the system is fully paid?
        // if so, why would it consider portions?
     function grantOwnership(address targetSSAddress, address newOwner) public {
         require(msg.sender == admin);

         mapping(address => Holder) targetSSHolders = solarSystems[targetSSAddress].holders;
         targetSSHolders[newOwner].holdingStatus = HoldingStatus.OWNED;
     }

     // ## TODO ## // LEGAL OWNERSHIP ///
     // Come up with a step so that when ownership is fully transfered, there is an automatic report that can change a registry that has legal validity

    // // functions that require no gas, but will check the state of the system

    // // Returns true if consumer has completely paid of any outstanding balance on the panel at ssAddress within their consumerBuffer period
     function isConsumerLiquidForSystem(address ssAddress, address consumer, uint consumerBuffer) view public returns (bool) {
         return (now - solarSystems[ssAddress].holders[consumer].lastFullPaymentTimestamp) <= consumerBuffer;
     }

}
    // ## TODO ## BREACH SCENARIOS ##
    // Add all the situations and scenarios that need to be considered if the payments are not made or the wallet accounts have insufficient funds
    // Consider sending email notifications, bringing in the guarantors, activating hardware etc.
