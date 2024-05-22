// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// ZarosToken dependencies
import { Base } from "test/Base.t.sol";
import { ZarosToken } from "@zaros/ZarosToken.sol";

contract Mint_Integration_Test is Base {
    function setUp() public override {
        Base.setUp();
    }

    function test_RevertGiven_UserIsNotAllowedToMint() external {
        vm.startPrank(users.naruto);

        // it should revert
        vm.expectRevert({ revertData: abi.encodeWithSelector(ZarosToken.NotMinter.selector) });

        zarosToken.mint(users.naruto, 1e18);
    }

    function testFuzz_GivenUserIsAllowedToMint(uint256 amountToMint) external {
        amountToMint = bound(amountToMint, 1, 100_000_000_000e18);

        vm.startPrank(users.owner);

        zarosToken.setIsMinter(users.naruto, true);

        vm.startPrank(users.naruto);

        // it should emit {LogMint} event
        vm.expectEmit({ emitter: address(zarosToken) });
        emit ZarosToken.LogMint(users.naruto, amountToMint);

        // it should mint
        assertEq(zarosToken.balanceOf(users.naruto), 0);
        zarosToken.mint(users.naruto, amountToMint);
        assertEq(zarosToken.balanceOf(users.naruto), amountToMint);
    }
}
