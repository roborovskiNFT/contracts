// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

abstract contract RoborovskiSignature is Ownable {
    address private _signer;
    mapping(uint256 => bool) private _signatureUsed;

    constructor() {
        _signer = _msgSender();
    }

    function setSigner(address newSigner) external onlyOwner {
        _signer = newSigner;
    }

    function _checkSignature(address wallet, uint256 count, uint256 signId, bytes memory signature) internal {
        require(!_signatureUsed[signId] && _signatureWallet(wallet, count, signId, signature) == _signer, "ROBOROVSKI: not authorized to mint");
        _signatureUsed[signId] = true;
    }

    function _signatureWallet(address wallet, uint256 count, uint256 signId, bytes memory signature) private pure returns (address) {
        return ECDSA.recover( keccak256(abi.encode(wallet, count, signId)), signature);
    }
}
