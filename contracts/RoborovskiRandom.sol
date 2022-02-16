// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "./RoborovskiErc721.sol";

abstract contract RoborovskiRandom is Context, RoborovskiErc721 {
    uint256[MAX_SUPPLY] internal _indices;
    uint256 private _randomNonce;

    function _internalMint(address account) internal returns (uint256 tokenId) {
        tokenId = _randomIndex();
        _mint(account, tokenId);
    }

    function _randomIndex() private returns (uint256) {
        uint256 totalSize = MAX_SUPPLY - totalSupply();
        uint256 index = uint256(
            keccak256(abi.encodePacked(_randomNonce++, _msgSender(), block.difficulty, block.timestamp))
        ) % totalSize;

        uint256 value = 0;
        if (_indices[index] != 0)
            value = _indices[index];
        else
            value = index;

        // Move last value to selected position
        if (_indices[totalSize - 1] == 0)
            // Array position not initialized, so use position
            _indices[index] = totalSize - 1;
        else
            // Array position holds a value so use that
            _indices[index] = _indices[totalSize - 1];

        return value + 1;
    }
}
