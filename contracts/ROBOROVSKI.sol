// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./RecoverableErc20ByOwner.sol";
import "./RoborovskiErc721.sol";
import "./RoborovskiName.sol";
import "./RoborovskiProvenance.sol";
import "./RoborovskiRandom.sol";
import "./RoborovskiSignature.sol";
import "./RoborovskiTeam.sol";

contract ROBOROVSKI is
    Ownable,
    ReentrancyGuard,
    RecoverableErc20ByOwner,
    RoborovskiErc721,
    RoborovskiName,
    RoborovskiProvenance,
    RoborovskiRandom,
    RoborovskiSignature,
    RoborovskiTeam
{
    // Time
    uint256 private constant TIMESTAMP_PRESALE = 1645279170;
    uint256 private constant TIMESTAMP_RAFFLE = 1645322400;
    uint256 private constant TIMESTAMP_SALE = 1645344000;

    // Price
    uint256 private constant PRICE = 0.165 ether;

    // Mint
    uint256 private constant LIMIT = 1;
    uint256 private constant LIMIT_SALE = 2;
    mapping(uint256 => mapping(address => uint256)) public mintedOf;
    bool private _paused = false;

    // Bonus
    bool[MAX_SUPPLY + 1] public isMintedBeforeSale;

    constructor(address rnct_, address proxyRegistry_)
        RoborovskiErc721(proxyRegistry_)
        RoborovskiName(rnct_)
    {
        // For offline auction
        _indices[0] = MAX_SUPPLY - 1;
        _mint(0x5AF3F92c0725D54565014b5EA0d5f15A685d1a2a, 1);
        isMintedBeforeSale[1] = true;
        _indices[1] = MAX_SUPPLY - 2;
        _mint(0x5AF3F92c0725D54565014b5EA0d5f15A685d1a2a, 2);
        isMintedBeforeSale[2] = true;
    }

    function mintAirdrop(address[] memory accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            isMintedBeforeSale[_internalMint(accounts[i])] = true;
        }
    }

    function mintPresale(uint256 count, uint256 signId, bytes memory signature) external payable nonReentrant {
        require(block.timestamp >= TIMESTAMP_PRESALE && block.timestamp < TIMESTAMP_RAFFLE, "ROBOROVSKI: presale not open");
        _checkSignature(_msgSender(), count, signId, signature);
        _checkCount(0, _msgSender(), count, LIMIT, count * PRICE);
        for (uint256 i = 0; i < count; i++) {
            isMintedBeforeSale[_internalMint(_msgSender())] = true;
        }
    }

    function mintRaffle(uint256 count, uint256 signId, bytes memory signature) external payable nonReentrant {
        require(block.timestamp >= TIMESTAMP_RAFFLE && block.timestamp < TIMESTAMP_SALE, "ROBOROVSKI: raffle not open");
        _checkSignature(_msgSender(), count, signId, signature);
        _checkCount(1, _msgSender(), count, LIMIT, count * PRICE);
        for (uint256 i = 0; i < count; i++) {
            isMintedBeforeSale[_internalMint(_msgSender())] = true;
        }
    }

    function mint(uint256 count, uint256 signId, bytes memory signature) external payable nonReentrant {
        require(block.timestamp >= TIMESTAMP_SALE, "ROBOROVSKI: sale not open");
        _checkSignature(_msgSender(), count, signId, signature);
        _checkCount(2, _msgSender(), count, LIMIT_SALE, count * PRICE);
        for (uint256 i = 0; i < count; i++) {
            _internalMint(_msgSender());
        }
    }

    function _checkCount(uint256 stage, address wallet, uint256 count, uint256 limit, uint256 purchaseAmount) private {
        require(mintedOf[stage][wallet] + count <= limit, "ROBOROVSKI: address limit");
        require(msg.value >= purchaseAmount, "ROBOROVSKI: value below purchase amount");
        mintedOf[stage][wallet] += count;
    }

    function setPause(bool paused_) external onlyOwner {
        _paused = paused_;
    }
}
