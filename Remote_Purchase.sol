// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

contract PurchaseAgreement{
    uint  public  itemPrice;
    address payable public  seller;
    address payable public buyer;


    enum State { Created, Locked, Release, Inactive}
    State public state;
    

    constructor() payable{
        seller = payable(msg.sender);
        itemPrice = (msg.value) / 2;
    }

    
    ///The function cannot be callled at present state.
    error invalidState();
    ///Only the Seller can call this function.
    error OnlySeller();
    ///Only the Buyer can call this function.
    error OnlyBuyer();

    modifier inState(State _state){
        if(state != _state){
            revert invalidState(); 
        }
        _;
    }

    modifier onlySeller() {
        if(msg.sender != seller){
            revert OnlySeller();
        }
        _;
    }

    modifier onlyBuyer(){
        if(msg.sender != buyer){
            revert OnlyBuyer();
        }
        _;
    }

    function confirmPurchase() external inState(State.Created) payable{
        require(msg.value == 2 * itemPrice, "Please deposit the 2x of Item Price foe security");
        buyer = payable(msg.sender);
        state = State.Locked;
    }

    function confirmReceived() external onlyBuyer inState(State.Locked) payable{
        state = State.Release;
        buyer.transfer(itemPrice);
    }

    function paySeller() external onlySeller inState(State.Release) payable{
        state = State.Inactive;
        seller.transfer(3 * itemPrice);
    }    

    function abort() external onlySeller inState(State.Created){
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }
}