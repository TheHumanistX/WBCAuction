//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract auction {

    address payable public seller;
    uint public auctionEndTime;
    bool public isAuctionRunning;
    mapping(address => uint) public bidderDeposits;
    bool public started = false;

    address public highestBidder;
    uint public highestBid;

    constructor() {
        seller = payable(msg.sender);
    }

    modifier noAttack() {
        require(!started, "You can't loop!");
        started = true;
        _;
        started = false;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "You are not the seller! You don't have permission to do this!");
        _;
    }

    function getBalance() public view returns(uint) {
        return bidderDeposits[msg.sender];
    }

    function startAuction() public onlySeller {
        require(!isAuctionRunning, "Auction is already running!");

        isAuctionRunning = true;
        auctionEndTime = block.timestamp + 1 minutes;
    }

    function bid() public payable  {
        require(isAuctionRunning, "Auction is not running, you cannot bid!");
        require(msg.value > highestBid, "Your bid is not higher than the current highest bid!");
        
        bidderDeposits[msg.sender] += msg.value;

        highestBidder = msg.sender;
        highestBid = msg.value;
    }

    function bidderWithdrawal() public noAttack {
        require(bidderDeposits[msg.sender] > 0, "You have no deposited bids to withdraw!");
        
        // uint bidderDeposit = bidderDeposits[msg.sender];
        // bidderDeposits[msg.sender] = 0;
        (bool tryToSend, /*Data*/) = msg.sender.call{value: bidderDeposits[msg.sender]}("");
        require(tryToSend, "Transaction failed.");
        bidderDeposits[msg.sender] = 0;
    }

    function win() onlySeller public {
        require(isAuctionRunning, "Auction is not running!");
        require(block.timestamp >= auctionEndTime, "It is not time for the auction to end!");

        isAuctionRunning = false;
        seller.transfer(highestBid);
        bidderDeposits[highestBidder] -= highestBid;
    }

}