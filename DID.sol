// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract DID {
    address owner;
    uint count = 0;

    struct User {
        string name;
        string email;
        mapping(string => string) userClaims; 
        string[] claimTypes;  
        string[] claimValues;  
        mapping(string => bool) claimVerified; 
    }

    mapping(address => User) users;
    mapping(address => bool) isRegistered;

    event UserRegistered(address user);
    event ClaimAdded(address user, string claimType);
    event ClaimVerified(address user, string claimType);
    event ClaimRevoked(address user, string claimType);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You are not the owner of the contract.");
        _;
    }

    function registerIdentity(string memory _name, string memory _email) public {
        require(!isRegistered[msg.sender], "You have already registered");

        User storage newUser = users[msg.sender];
        newUser.name = _name;
        newUser.email = _email;

        isRegistered[msg.sender] = true;
        emit UserRegistered(msg.sender);
    }

    function addClaim(string memory _claimType, string memory _claimValue) public {
        require(isRegistered[msg.sender], "You are not registered");

        users[msg.sender].userClaims[_claimType] = _claimValue;
        users[msg.sender].claimTypes.push(_claimType);
        users[msg.sender].claimValues.push(_claimValue);

        emit ClaimAdded(msg.sender, _claimType);
    }

    function verifyClaim(address _user, string memory _claimType) public {
        require(isRegistered[_user], "User not registered.");
        require(bytes(users[_user].userClaims[_claimType]).length > 0, "Claim does not exist.");

        users[_user].claimVerified[_claimType] = true;
        emit ClaimVerified(_user, _claimType);
    }

    function getClaims(address _user) public view returns (string[] memory claimTypes, string[] memory claimValues) {
        require(isRegistered[_user], "User not registered.");

        return (users[_user].claimTypes, users[_user].claimValues);
    }

    function revokeClaim(address _user, string memory _claimType) public {
        require(isRegistered[_user], "User not registered.");
        require(bytes(users[_user].userClaims[_claimType]).length > 0, "Claim does not exist.");

        users[_user].userClaims[_claimType] = "";
        users[_user].claimVerified[_claimType] = false;

        for (uint i = 0; i < users[_user].claimTypes.length; i++) {
            if (keccak256(abi.encodePacked(users[_user].claimTypes[i])) == keccak256(abi.encodePacked(_claimType))) {
                for (uint j = i; j < users[_user].claimTypes.length - 1; j++) {
                    users[_user].claimTypes[j] = users[_user].claimTypes[j + 1];
                    users[_user].claimValues[j] = users[_user].claimValues[j + 1];
                }
                users[_user].claimTypes.pop();
                users[_user].claimValues.pop();
                break;
            }
        }

        emit ClaimRevoked(_user, _claimType);
    }
}
