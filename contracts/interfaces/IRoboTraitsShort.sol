// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRoboTraitsShort {
    function contractURI() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
