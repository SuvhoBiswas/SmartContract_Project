// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleRegistry {

    struct User {
        string name;
        address wallet;
        bool registered;
    }

    // address => User
    mapping(address => User) public users;

    // Store all regiisted addresses
    address[] public registeredUsers;

    event UserRegistered(address indexed user, string name);

    // Register a new user
    function register(string calldata _name) external {
        
        require(bytes(_name).length > 0,"Name cannot be empty");

        require(!users[msg.sender].registered,"User already registered");

        users[msg.sender] = User({
            name: _name,
            wallet: msg.sender,
            registered: true
        });

        registeredUsers.push(msg.sender);

        emit UserRegistered(msg.sender, _name);


    }

    //get user information
    function getUser(address _user) external view returns(string memory, address, bool) {

        User storage user = users[_user];

        return (
            user.name,
            user.wallet,
            user.registered
        );

    }

    //Total registerd users
    function getTotalUsers() external view returns (uint256) {
        return registeredUsers.length;
    }

    // Get all registerd address

    function getRegisteredUsers() external view returns(address[] memory) {
        return registeredUsers;
    }
}