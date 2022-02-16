// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRnctShort {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external;
}
