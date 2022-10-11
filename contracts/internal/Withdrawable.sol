// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../oz/utils/Context.sol";

import "./Transferable.sol";

import "./interfaces/IWithdrawable.sol";

abstract contract WithdrawableUpgradeable is
    Context,
    Transferable,
    IWithdrawable
{
    receive() external payable virtual {
        emit Received(_msgSender(), msg.value);
    }

    function withdraw(
        IERC20 token_,
        address to_,
        uint256 amount_
    ) external virtual;
}