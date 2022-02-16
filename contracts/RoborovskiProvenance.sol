// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract RoborovskiProvenance is Ownable {
    string public PROVENANCE;

    function setProvenance(string memory provenance_) external onlyOwner {
        require(bytes(PROVENANCE).length == 0, "ROBOROVSKI: provenance is already set");
        PROVENANCE = provenance_;
    }
}
