//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface auction {
    function bid() external payable;
    function bidderWithdrawal() external;
    function getBalance() external view returns(uint);
}

contract auctionHack {
    auction public auctionContract;
    uint public loopcounter;

    constructor(address _auctionContract) {
        auctionContract = auction(_auctionContract);
    }

    function bidderWithdrawal2() public {
        auctionContract.bidderWithdrawal();
    }

    function bid() public payable {
        auctionContract.bid{value: msg.value}();
    }

    fallback() external payable {

    }

}