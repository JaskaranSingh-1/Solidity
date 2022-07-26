// SPDX-License-Identifier: UNLICENCED
pragma solidity >=0.7.0 <0.9.0;

contract Auction{
    address payable public auctioneer;
    address payable public highestBidder;
    uint public startBlock;
    uint public endBlock;
    uint public highestPayableBid;
    uint public bidIncrement;

    enum Auc_State{Started, Running, Ended, Cancelled}
    Auc_State public auctionState;

    mapping(address => uint) public bids;

    constructor(){
        auctioneer = payable(msg.sender);
        startBlock = block.number;
        endBlock = startBlock + 240;
        auctionState = Auc_State.Running;
        bidIncrement = 1 ether;
    }

    modifier owner(){
        require(msg.sender == auctioneer,"Auctioneer cannot bid in Auction");
        _;
    }

    modifier notOwner(){
        require(msg.sender != auctioneer,"Auctioneer cannot bid in Auction");
        _;
    }

    modifier started(){
        require(block.number > startBlock);
        _;
    }

    modifier beforeEnding(){
        require(block.number < endBlock);
        _;
    }
    
    function cancelAuction() public owner{
        auctionState = Auc_State.Cancelled;
    }

    function endAuction() public owner{
        auctionState = Auc_State.Ended;
    }

    function minimum(uint a, uint b) pure private returns(uint){
        if(a > b){
            return b;
        }
        else{
            return a;
        }
    }

    function bid() public payable notOwner started beforeEnding{
        require(auctionState == Auc_State.Running);
        require(msg.value >= 1 ether,"Minimum 1 Ether Bid");
        uint currentBid = bids[msg.sender] + msg.value;
        require(currentBid > highestPayableBid);
        bids[msg.sender] = currentBid;

        if(currentBid < bids[highestBidder]){
            highestPayableBid = minimum(currentBid + bidIncrement, bids[highestBidder]);
        }
        else{
            highestPayableBid = minimum(currentBid, bids[highestBidder] + bidIncrement);
            highestBidder = payable(msg.sender);
        }
    }

    function finalizeAuction() public {
        require(auctionState == Auc_State.Cancelled || auctionState == Auc_State.Ended || block.number >= endBlock);
        require(msg.sender == auctioneer || bids[msg.sender] > 0);

        address payable person;
        uint value;

        if(auctionState == Auc_State.Cancelled){
            person = payable(msg.sender);
            value = bids[msg.sender];
        }
        else {
            if(msg.sender == auctioneer){
                person = auctioneer;
                value = highestPayableBid;
            }
            else if(msg.sender == highestBidder){
                person = highestBidder;
                value = bids[highestBidder] - highestPayableBid;
            }
            else{
                person = payable(msg.sender);
                value = bids[msg.sender];
            }
        }
        bids[msg.sender] = 0;
        person.transfer(value);
    }
}
