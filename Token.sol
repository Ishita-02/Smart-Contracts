//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Token {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balance;

    event(address indexed to, address indexed from, uint256 amount);

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * 10**uint256(_decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) external returns(bool success) {
        require( _to != address(0), "Invalid address");
        require( balanceOf[msg.sender] >= _value, "You don't have enough balance");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit(_to, msg.sender, _value);
        return true; 
    }

}