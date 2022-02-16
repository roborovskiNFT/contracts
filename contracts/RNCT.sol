// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./RecoverableErc20ByOwner.sol";
import "./interfaces/IRoboShort.sol";

contract RNCT is Ownable, RecoverableErc20ByOwner, ERC20, ERC20Burnable, ERC20Permit {
    address public ROBO;
    uint256 public constant BONUS = 1830 ether;
    uint256 public constant EMISSION_START = 1644978570; // TODO
    uint256 public constant EMISSION_END = 1960338570; // TODO // 1644978570+10*365*86400
    uint256 public constant EMISSION_RATE = 10 ether / uint256(86400);
    mapping(uint256 => uint256) private _lastClaim;

    constructor()
        ERC20("Roborovski NameChangeToken", "RNCT")
        ERC20Permit("Roborovski NameChangeToken")
    {
        _mint(_msgSender(), 1000000 ether); // TODO
    }

    function lastClaim(uint256 tokenId) public view returns (uint256) {
        require(IRoboShort(ROBO).rawOwnerOf(tokenId) != address(0), "RNCT: owner cannot be zero address");

        uint256 lastClaimed = uint256(_lastClaim[tokenId]) != 0
            ? uint256(_lastClaim[tokenId])
            : EMISSION_START;
        return lastClaimed;
    }

    function accumulated(uint256 tokenId) public view returns (uint256) {
        uint256 lastClaimed = lastClaim(tokenId);
        if (lastClaimed >= EMISSION_END)
            return 0;

        uint256 accumulationPeriod = block.timestamp < EMISSION_END
            ? block.timestamp
            : EMISSION_END;
        uint256 total = EMISSION_RATE * (accumulationPeriod - lastClaimed);

        if (lastClaimed == EMISSION_START) {
            uint256 bonus = IRoboShort(ROBO).isMintedBeforeSale(tokenId) == true
                ? BONUS
                : 0;
            total = total + bonus;
        }

        return total;
    }

    function claim(uint256[] memory tokenIds) public returns (uint256) {
        require(block.timestamp > EMISSION_START, "RNCT: emission has not started yet");
        uint256 totalClaimQty = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            for (uint256 j = i + 1; j < tokenIds.length; j++) {
                require(tokenIds[i] != tokenIds[j], "RNCT: duplicate tokenId");
            }

            uint256 tokenId = tokenIds[i];
            require(IRoboShort(ROBO).rawOwnerOf(tokenId) == _msgSender(), "RNCT: sender is not the owner");

            uint256 claimQty = accumulated(tokenId);
            if (claimQty != 0) {
                totalClaimQty = totalClaimQty + claimQty;
                _lastClaim[tokenId] = block.timestamp;
            }
        }

        require(totalClaimQty != 0, "RNCT: no accumulated RNCT");
        _mint(_msgSender(), totalClaimQty);
        return totalClaimQty;
    }

    function setRobo(address robo) public onlyOwner {
        require(ROBO == address(0), "RNCT: ROBO is already set");
        ROBO = robo;
    }

    // The following functions are overrides required by Solidity.
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if (_msgSender() == ROBO) {
            _transfer(sender, recipient, amount);
            return true;
        }
        return super.transferFrom(sender, recipient, amount);
    }
}
