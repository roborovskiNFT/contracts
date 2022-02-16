// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract RoborovskiRoyaltyDistributor is Ownable {
    address public immutable ROBO;
    uint256 public constant TOTAL_SHARES = 10000;
    mapping(address => uint256) public totalReleased;
    mapping(uint256 => mapping(address => uint256)) public totalClaimedOf;

    constructor(address robo_) {
        ROBO = robo_;
    }

    function totalReceived(address token) public view returns (uint256) {
        uint256 balance;
        if (token == address(0))
            balance = address(this).balance;
        else
            balance = IERC20(token).balanceOf(address(this));

        return balance + totalReleased[token];
    }

    function accumulated(address token, uint256 tokenId) public view returns (uint256) {
        return (totalReceived(token) / TOTAL_SHARES) - totalClaimedOf[tokenId][token];
    }

    function claim(address token, uint256[] memory tokenIds) external  returns (uint256) {
        uint256 totalClaimQty = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            for (uint256 j = i + 1; j < tokenIds.length; j++) {
                require(tokenIds[i] != tokenIds[j], "RRD: duplicate tokenId");
            }

            uint256 tokenId = tokenIds[i];
            require(IERC721(ROBO).ownerOf(tokenId) == _msgSender(), "RRD: sender is not the owner");

            uint256 claimQty = accumulated(token, tokenId);
            if (claimQty != 0) {
                totalClaimQty += claimQty;
                totalClaimedOf[tokenId][token] += claimQty;
            }
        }

        require(totalClaimQty != 0, "RRD: no accumulated rewards");
        totalReleased[token] += totalClaimQty;

        if (token == address(0))
            _sendEth(_msgSender(), totalClaimQty);
        else
            _sendErc20(token, _msgSender(), totalClaimQty);
        return totalClaimQty;
    }

    function _sendEth(address recipient, uint256 amount) private {
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "RRD: ETH_TRANSFER_FAILED");
    }

    function _sendErc20(address tokenAddress, address recipient, uint256 amount) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = tokenAddress.call(abi.encodeWithSelector(0xa9059cbb, recipient, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "RRD: ERC20_TRANSFER_FAILED");
    }

    receive() external payable {}
}
