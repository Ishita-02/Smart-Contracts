// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MultiSig {
    
    address[] public owners;
    uint256 public required;
    uint public balance;

    constructor(address[] memory _owners, uint256 _required) {
        require(_required > 0 && _required <= _owners.length, "Enter correct number");
        require(_owners.length > 0, "Owners required");
        owners = _owners;
        required = _required;
    }

    struct Transaction {
        address dest;
        uint256 value;
        bool executed;
        bytes data;
    }

    uint id = 0;
    mapping(uint => Transaction) public transactions;
    mapping(uint => mapping(address => bool)) public confirmations;
    mapping(uint => uint) public countConfirmation;

    modifier onlyOwner() {
        require(isOwner(msg.sender), "Not an owner");
        _;
    }

    function isOwner(address _address) public view returns (bool) {
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == _address) {
                return true;
            }
        }
        return false;
    }

    function transactionCount() public view returns (uint) {
        return id;
    }

    function addTransaction(address _destAddress, uint256 _value, bytes memory _data) internal returns(uint) {
        transactions[id] = Transaction({
            dest: _destAddress,
            value: _value,
            executed: false,
            data: _data
        });
        id++;
        return id - 1;
    }

    function confirmTransaction(uint _id) public onlyOwner {
        require(!confirmations[_id][msg.sender], "Transaction already confirmed");
        require(transactions[_id].dest != address(0), "Transaction does not exist");

        confirmations[_id][msg.sender] = true;
        countConfirmation[_id]++;
        
        if (isConfirmed(_id)) {
            executeTransaction(_id);
        }
    }

    function getConfirmationsCount(uint _id) public view returns(uint256) {
        return countConfirmation[_id];
    }

    function submitTransaction(address _destAddress, uint _value, bytes memory _data) external onlyOwner {
        uint txnId = addTransaction(_destAddress, _value, _data);
        confirmTransaction(txnId);
    }

    receive() external payable {
    }

    function isConfirmed(uint _id) public view returns(bool) {
        return countConfirmation[_id] >= required;
    }

    function executeTransaction(uint _id) public {
        Transaction storage txn = transactions[_id];
        require(isConfirmed(_id), "Transaction not confirmed");
        require(!txn.executed, "Transaction already executed");
        
        (bool success,) = txn.dest.call{value: txn.value}(txn.data);
        require(success, "Transaction execution failed");
        txn.executed = true;
    }
}
