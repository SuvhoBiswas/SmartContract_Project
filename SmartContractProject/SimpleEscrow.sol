// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleEscrow {

    address public buyer;
    address public seller;

    bool public deposited;
    bool public released;

    event Deposited(address indexed buyer, uint256 amount);
    event Released(address indexed seller, uint256 amount);

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call");
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call");
        _;
    }

    constructor(address _seller) {
        require(_seller != address(0),"Invalid seller");

        buyer = msg.sender;
        seller = _seller;
    }

    // Buyer Deposit ether
    function deposit() external payable onlyBuyer {
        require(!deposited,"Already deposited");
        require(msg.value > 0,"Send some ether");

        deposited = true;

        emit Deposited(msg.sender, msg.value);

    }

    // Buyer releases payment to seller
    function releasePayment() external onlyBuyer {

        require(deposited, "No deposit found");
        require(!released ," Already released");

        released = true;

        uint256 amount = address(this).balance;

        (bool success,) = payable(seller).call{value: amount}("");

        require(success, "Transfer Failed");

        emit Released(seller, amount);
    }

    function getContractBalance() external view returns(uint256) {
        return address(this).balance;
    }

    
}