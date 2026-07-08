// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract UserRegistry{
    struct User{
        string name;
        address wallet;
        bool registered;
    }

    // address => User
    mapping(address => User) public users;

    //name has => alreadu used
    mapping(bytes32 => bool) public usedNames;

    // Registered addresses
    address[] public registeredUsers;

    event UserRegistered(
        address indexed user, string name
    );

    event UserRemoved(address indexed user);

    //Register user
    function register(string calldata _name) external {
        require(bytes(_name).length > 0,"Name is required");

        require(!users[msg.sender].registered , "Address already registered");

        bytes32 nameHash = keccak256(bytes(_name));

        require(!usedNames[nameHash],"Name already taken");

        users[msg.sender] = User({
            name : _name,
            wallet: msg.sender,
            registered: true
        });

        usedNames[nameHash] = true;
        registeredUsers.push(msg.sender);

        emit UserRegistered(msg.sender, _name);
    }

    // Remove user
    function removeUser() external {
        require(users[msg.sender].registered,"User not registered");

        bytes32 nameHash = keccak256(bytes(users[msg.sender].name));

        usedNames[nameHash] = false;

        delete users[msg.sender];

        // remove from array
        for(uint256 i=0; i<registeredUsers.length; i++) {

            if(registeredUsers[i] == msg.sender) {
                registeredUsers[i] = registeredUsers[registeredUsers.length];

                registeredUsers.pop();

                break;
            }
        }
        emit UserRemoved(msg.sender);
    }

    function getUser(address _user) external view returns(string memory, address, bool ) {
        User storage user = users[_user];

        return (user.name,user.wallet,user.registered);
    }

    function getAllUsers() external view returns(address[] memory) {
        return registeredUsers;
    }

    function totalUsers() external view returns(uint256) {
        return registeredUsers.length;
    }

}