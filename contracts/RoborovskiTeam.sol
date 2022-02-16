// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract RoborovskiTeam is Ownable {
    address[] private _team = [
        0x8cb7Da476cef0882e75d7e335BCB9a7B7a1E94B9, // TODO
        0xD513072998e38FC66d715357fb2D09c544F648cb // TODO
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
