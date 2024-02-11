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
}