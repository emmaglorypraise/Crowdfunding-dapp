// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


contract CrowdFund {
   
   uint public noOfCampaigns;
   uint public totalDonation;
   address public admin;

   event CampaignCreated(uint id);
   event Donation(uint amount, uint when);
   event Withdrawal(uint amount, uint when);

   constructor() {
    admin = msg.sender;
   }

   struct Campaign {
    uint campaignID;
    uint noOfDonations;
    uint totalAmountDonated;
    uint campaignTarget;
    bool isApproved;
    string campaignName;
    address owner;
   }

   mapping (uint => Campaign) public Campaigns;

   modifier onlyAdmin {
    require(msg.sender == admin, "Only admin can approve campaign"); 
    _;
   }

   function Donate(uint _campaignID) payable  external {

    Campaign storage s = Campaigns[_campaignID];

    require(msg.value > 0, "Please donate to this cause");
    // require(_campaignID > 000, "Please specify campaign to donate to");
    require(s.isApproved == true, "You can only donate to approved Campaigns");


    s.noOfDonations++;
    s.totalAmountDonated += msg.value;
    totalDonation += msg.value;

    emit Donation(msg.value, block.timestamp);

   }

   function SetCampaign(uint _campaignID, string memory _campaignName, address _campaignOwner, uint _campaignTarget) external {
    Campaign storage s = Campaigns[_campaignID];

    s.campaignID = _campaignID;
    s.campaignName = _campaignName;
    s.campaignTarget = _campaignTarget;
    s.noOfDonations = 0;
    s.totalAmountDonated = 0;
    s.owner = _campaignOwner;

    noOfCampaigns++;

    emit CampaignCreated(_campaignID);
   }

   function ApproveCampaign(uint _campaignID) external onlyAdmin {
    Campaign storage s = Campaigns[_campaignID];
    s.isApproved = true;
   }

   function Withdraw(uint _campaignID , address _campaignOwner) external {
    Campaign memory s = Campaigns[_campaignID];
    address _owner = s.owner;

    require(_campaignOwner == _owner, "Only owner can withdraw");
    require(_owner != address(0), "invalid owner address");

    uint amountToWithdraw;
    amountToWithdraw = s.totalAmountDonated;
    s.totalAmountDonated == 0;
    
    if(s.totalAmountDonated < s.campaignTarget) {
      payable(_owner).transfer(amountToWithdraw);
    } else {
      uint deduction;
      deduction = amountToWithdraw * 7/100;
      amountToWithdraw = amountToWithdraw - deduction;
      
     payable(_owner).transfer(amountToWithdraw);
    }

    emit Withdrawal(amountToWithdraw, block.timestamp);
   }
}

