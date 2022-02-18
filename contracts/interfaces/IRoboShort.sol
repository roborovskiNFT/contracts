// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRoboShort {
    function rawOwnerOf(uint256 tokenId) external view returns (address owner);
    function isMintedBeforeSale(uint256 tokenId) external view returns (bool);
    function tokenName(uint256 tokenId) external view returns (string memory);
}
