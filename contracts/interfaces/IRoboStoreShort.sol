// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRoboStoreShort {
    function getIpfsHashHex(uint256 tokenId) external view returns (bytes memory);
    function getIpfsHash(uint256 tokenId) external view returns (string memory);
    function getTraitBytes(uint256 tokenId) external view returns (bytes memory);
}
