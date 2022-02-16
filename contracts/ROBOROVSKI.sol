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
    uint256 public TIMESTAMP_PRESALE = 1644978570; // TODO
    uint256 public TIMESTAMP_PRESALE_END = 1644982170; // TODO
    uint256 public TIMESTAMP_SALE = 1644984000; // TODO

    // Price
    uint256 public constant PRICE_PRESALE = 0.00001 ether; // TODO
    uint256 public constant PRICE_SALE = 0.00002 ether; // TODO

    // Mint
    uint256 public constant LIMIT_PRESALE = 1; // TODO
    uint256 public constant LIMIT_SALE = 4; // TODO
    mapping(uint256 => mapping(address => uint256)) public mintedOf;

    // Bonus
    //mapping(uint256 => bool) public isMintedBeforeSale;
    bool[MAX_SUPPLY + 1] public isMintedBeforeSale;

    constructor(address rnct_, address proxyRegistry_)
        RoborovskiErc721(proxyRegistry_)
        RoborovskiName(rnct_)
    {
        _indices[0] = MAX_SUPPLY - 1;
        _mint(0x8cb7Da476cef0882e75d7e335BCB9a7B7a1E94B9, 1); // TODO
        isMintedBeforeSale[1] = true;
    }

    // TODO // TESTNET ONLY START
    function setTimestampPresale(uint256 timestamp) external onlyOwner {
        TIMESTAMP_PRESALE = timestamp;
    }

    function setTimestampPresaleEnd(uint256 timestamp) external onlyOwner {
        TIMESTAMP_PRESALE_END = timestamp;
    }

    function setTimestampSale(uint256 timestamp) external onlyOwner {
        TIMESTAMP_SALE = timestamp;
    }
    // TESTNET ONLY END

    function mintAirdrop(address[] memory accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            isMintedBeforeSale[_internalMint(accounts[i])] = true;
        }
    }

    function mintPresale(uint256 count, uint256 signId, bytes memory signature) external payable nonReentrant {
        require(block.timestamp >= TIMESTAMP_PRESALE && block.timestamp < TIMESTAMP_PRESALE_END, "ROBOROVSKI: presale not open");
        _checkSignature(_msgSender(), count, signId, signature);
        _checkCount(0, _msgSender(), count, LIMIT_PRESALE, count * PRICE_PRESALE);
        for (uint256 i = 0; i < count; i++) {
            isMintedBeforeSale[_internalMint(_msgSender())] = true;
        }
    }

    function mint(uint256 count, uint256 signId, bytes memory signature) external payable nonReentrant {
        require(block.timestamp >= TIMESTAMP_SALE, "ROBOROVSKI: sale not open");
        _checkSignature(_msgSender(), count, signId, signature);
        _checkCount(1, _msgSender(), count, LIMIT_SALE, count * PRICE_SALE);
        for (uint256 i = 0; i < count; i++) {
            _internalMint(_msgSender());
        }
    }

    function _checkCount(uint256 stage, address wallet, uint256 count, uint256 limit, uint256 purchaseAmount) private {
        require(mintedOf[stage][wallet] + count <= limit, "ROBOROVSKI: address limit");
        require(msg.value >= purchaseAmount, "ROBOROVSKI: value below purchase amount");
        mintedOf[stage][wallet] += count;
    }
}
