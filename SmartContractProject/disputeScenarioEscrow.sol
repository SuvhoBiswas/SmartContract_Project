// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Escrow {

    enum Status {
        AWAITING_PAYMENT,
        AWAITING_DELIVERY,
        DISPUTED,
        COMPLETE,
        REFUNDED
    }

    address public buyer;
    address public seller;
    address public arbitrator;

    Status public status;

    event Deposited(address indexed buyer, uint256 amount);
    event Released(address indexed seller, uint256 amount);
    event Refunded(address indexed buyer, uint256 amount);
    event DisputeRaised(address indexed buyer);


    modifier onlyBuyer() {
        require(msg.sender == buyer,"Only buyer");
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller,"Only seller");
        _;
        
    }

    modifier onlyArbitrator() {
        require(msg.sender == arbitrator,"Only arbitrator");
        _;
    }

    constructor(address _seller, address _arbitrator) {
        buyer = msg.sender;
        seller = _seller;
        arbitrator = _arbitrator;

        status = Status.AWAITING_PAYMENT;



        
    }

    function deposit() external payable onlyBuyer {
        require(status == Status.AWAITING_PAYMENT,"Invalid status");

        require (msg.value > 0,"Send ETH");

        status = Status.AWAITING_DELIVERY;

        emit Deposited(msg.sender, msg.value);



    }

    function releasePayment() external onlyBuyer {
        require(status == Status.AWAITING_PAYMENT, "Cannot release");

        status = Status.COMPLETE;

        uint256 amount = address(this).balance;
        (bool success ,) = payable(seller).call{value: amount} ("");
        require(success);
        emit Released(seller,amount);
    }

    function raiseDisput() external onlyBuyer {
        require(status == Status.AWAITING_DELIVERY," Cannot disput");

        status = Status.DISPUTED;

        emit DisputeRaised(msg.sender);
    }

    function resolveToSeller() external onlyArbitrator {
        require(status == Status.DISPUTED,"No dispute");

        status = Status.COMPLETE;

        uint256 amount = address(this).balance;
        (bool success,) = payable(seller).call{value:amount}("");
        require(success);

        emit Released(seller, amount);


    }

    function refoundBuyer() external onlyArbitrator {
        require(status == Status.DISPUTED,"No dispte");

        status = Status.REFUNDED;

        uint256 amount = address(this).balance;

        (bool success ,) = payable(buyer).call{value:amount}("");
        require(success);


        emit Refunded(buyer, amount);


    }

    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }



    
}