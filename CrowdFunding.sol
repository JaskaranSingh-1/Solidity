// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding
{
    mapping (address=>uint) public contributers;
    address public manager;
    uint public minimumContribution;
    uint public targetAmount;
    uint public deadline;
    uint public raisedAmount;
    uint public totalContributers;

    
    mapping(uint=>Request) public requests;
    uint public numRequests;

    struct Request
    {
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint totalVoters;
        mapping (address=>bool) voters;

    }

    constructor(uint _targetAmount, uint _deadline) 
    {
        targetAmount=_targetAmount;
        deadline= block.timestamp + _deadline;  
        minimumContribution=1000 wei;
        manager=msg.sender;
    }

    function sendETH () public payable
    {
        require (block.timestamp<deadline, "The Deadline is over, You Can't Contribute Now");
        require(msg.value >= minimumContribution," Your Contribution is not met the minimum contribution");

        if (contributers[msg.sender]==0)
        {
            totalContributers++;           
        }
        contributers[msg.sender]+=msg.value;
        raisedAmount+=msg.value;

    }

    function contractBalance() public view returns (uint)
    {
        return address(this).balance;
    }

    function refund() public
    {
     require(block.timestamp>deadline && targetAmount<raisedAmount," You are not eligible for refund" );
     require(contributers[msg.sender]>0);
     address payable user = payable (msg.sender);
     user.transfer(contributers[msg.sender]);
     contributers[msg.sender]=0;   

    }


    modifier onlyManager()
    {
        require(msg.sender==manager, " You are not Manager, Only Manager can call this function");
        _;
    }

    function createRequests(string memory  _description, address payable _recipient, uint _value) public onlyManager
    {
        
        Request storage newRequest=requests[numRequests];
        numRequests++;
        newRequest.description=_description;
        newRequest.value=_value;
        newRequest.recipient=_recipient;
        newRequest.completed=false;
        newRequest.totalVoters=0;

    }


    function voteRequest(uint _requestNo) public
    {
        require (contributers[msg.sender]>0, " You cannot Vote, Because you are not a contributer");
        Request storage thisRequest= requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false, 'You have already voted');
        thisRequest.voters[msg.sender]=true;
        thisRequest.totalVoters++;
    }





}