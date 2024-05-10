// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ZarosToken } from "@zaros/ZarosToken.sol";

contract ZarosToken_Integration_Test {
    function setUp() public{
        address zarosTokenImplementation = address(new ZarosToken());

        bytes memory zarosTokenInitializeData = abi.encodeWithSelector(ZarosToken.initialize.selector, msg.sender, "ZarosToken", "ZRS");

        // address zarosToken = address(new 1967);
    }

    function test_RevertWhen_UserIsNotInTheAllowListAndCallsMintFunction() external {
        // it should revert
    }

    function test_WhenUserIsNotInTheAllowListChecksIfHeHasAccess() external {
        // it should return false
    }

    function test_WhenUserIsInTheAllowListAndCallsMintFunction() external {
        // it should mint
        // it should emit {LogMint} event
    }

    function test_WhenUserIsInTheAllowListChecksIfHeHasAccess() external {
        // it should return true
    }
}