// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RoborovskiMetadataStore is Ownable {
    bytes2 public constant IPFS_PREFIX = 0x1220;
    bytes internal constant _ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

    mapping(uint256 => bytes32) private ipfsHashBytes;
    mapping(uint256 => bytes13) private traitBytes;

    function storeMetadata(uint256[] memory tokenIds, bytes32[] memory ipfsHex, bytes13[] memory traitsHex) public onlyOwner {
        require(tokenIds.length == ipfsHex.length && tokenIds.length == traitsHex.length, "Not equal length");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            ipfsHashBytes[tokenId] = ipfsHex[i];
            traitBytes[tokenId] = traitsHex[i];
        }
    }

    function getIpfsHashHex(uint256 tokenId) public view returns (bytes memory) {
        return abi.encodePacked(IPFS_PREFIX, ipfsHashBytes[tokenId]);
    }

    function getIpfsHash(uint256 tokenId) public view returns (string memory) {
        return _toBase58(getIpfsHashHex(tokenId));
    }

    function getTraitBytes(uint256 tokenId) public view returns (bytes memory) {
        return abi.encodePacked(traitBytes[tokenId]);
    }

    // Source: verifyIPFS (https://github.com/MrChico/verifyIPFS/blob/master/contracts/verifyIPFS.sol)
    // @author Martin Lundfall (martin.lundfall@consensys.net)
    // @dev Converts hex string to base 58
    function _toBase58(bytes memory source) internal pure returns (string memory) {
        if (source.length == 0) return new string(0);
        uint8[] memory digits = new uint8[](46);
        digits[0] = 0;
        uint8 digitlength = 1;
        for (uint256 i = 0; i < source.length; ++i) {
            uint256 carry = uint8(source[i]);
            for (uint256 j = 0; j < digitlength; ++j) {
                carry += uint256(digits[j]) * 256;
                digits[j] = uint8(carry % 58);
                carry = carry / 58;
            }

            while (carry > 0) {
                digits[digitlength] = uint8(carry % 58);
                digitlength++;
                carry = carry / 58;
            }
        }
        return string(_toAlphabet(_reverse(_truncate(digits, digitlength))));
    }

    function _truncate(uint8[] memory array, uint8 length) internal pure returns (uint8[] memory) {
        uint8[] memory output = new uint8[](length);
        for (uint256 i = 0; i < length; i++) {
            output[i] = array[i];
        }
        return output;
    }

    function _reverse(uint8[] memory input) internal pure returns (uint8[] memory) {
        uint8[] memory output = new uint8[](input.length);
        for (uint256 i = 0; i < input.length; i++) {
            output[i] = input[input.length - 1 - i];
        }
        return output;
    }

    function _toAlphabet(uint8[] memory indices) internal pure returns (bytes memory) {
        bytes memory output = new bytes(indices.length);
        for (uint256 i = 0; i < indices.length; i++) {
            output[i] = _ALPHABET[indices[i]];
        }
        return output;
    }
}
