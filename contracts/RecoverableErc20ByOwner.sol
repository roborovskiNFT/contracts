// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract RecoverableErc20ByOwner is Ownable {
    function recoverErc20(address tokenAddress, uint256 amount, address to) external onlyOwner {
        uint256 recoverableAmount = _getRecoverableAmount(tokenAddress);
        require(amount <= recoverableAmount, "RecoverableByOwner: RECOVERABLE_AMOUNT_NOT_ENOUGH");
        _sendErc20(tokenAddress, amount, to);
    }

    function _getRecoverableAmount(address tokenAddress) private view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function _sendErc20(address tokenAddress, uint256 amount, address to) private {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = tokenAddress.call(abi.encodeWithSelector(0xa9059cbb, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "RecoverableByOwner: ERC20_TRANSFER_FAILED");
    }
}
