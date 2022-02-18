// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract RoborovskiTeam is Ownable {
    address[] private _team = [
        0xA28F5fD46DC3C9b4399492fF81827983F2555600,
        0xBd0AD46710D75Fb936F01aA5DBEA6Eeb8845C1d0
    ];

    event Withdrawed(address indexed recipient, uint256 amount);

    function withdraw(uint256 amount) external onlyOwner {
        if (amount > address(this).balance)
            amount = address(this).balance;
        uint256 share = (amount * 50) / 100;
        _widthdraw(_team[0], share);
        _widthdraw(_team[1], amount - share);
    }

    function _widthdraw(address recipient, uint256 amount) private {
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "ROBOROVSKI: ETH_TRANSFER_FAILED");
        emit Withdrawed(recipient, amount);
    }
}
