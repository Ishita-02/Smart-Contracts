//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Escrow {
    address public seller;
    address public buyer;
    address public arbiter;

    enum State {
        Created, Locked, Released, InDispute
    }
    State public state;

    // Functions: deposit, release funds, refund buyer, raise dispute, resolve dispute
    event FundsDeposited(address indexed depositer, uint amount);
    event FundsReleased(address indexed beneficiary, uint amount);
    event RefundInitiated(address indexed refundRecipient, uint amount);
    event DisputeRaised();

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only the buyer can call this function");
        _;
    }

    modifier inState(State _state) {
        require( state == _state,"Invalid state for this operation");
        _;
    }

    constructor(address _seller, address _arbiter) {
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
        state = State.Created;
    }

    function deposit() external payable onlyBuyer inState(State.Created) {
        emit FundsDeposited(msg.sender, address(this).balance);
        state = State.Locked;
    }

    function releaseFunds() external onlyBuyer inState(State.Locked) {
        emit FundsReleased(seller, address(this).balance);
        payable(seller).transfer(address(this).balance);
        state = State.Released;
    }

    function refundBuyer() external onlyBuyer inState(State.Locked) {
        emit RefundInitiated(buyer, address(this).balance);
        payable(buyer).transfer(address(this).balance);
        state = State.Released;
    }

    function raiseDispute() external{
        require(msg.sender == seller || msg.sender == buyer, "Only the buyer and seller can raise dispute");
        state = State.InDispute;
        emit DisputeRaised();
    }

    function resolveDispute(bool _buyerWins) external {
        require(msg.sender == arbiter, " Only the arbiter can resolve dispute" );
        if(_buyerWins) {
            payable(buyer).transfer(address(this).balance);
            emit RefundInitiated(buyer, address(this).balance);
        }
        else {
            payable(seller).transfer(address(this).balance);
            emit FundsReleased(seller, address(this).balance);
        }
        state = State.Released;
    }
}