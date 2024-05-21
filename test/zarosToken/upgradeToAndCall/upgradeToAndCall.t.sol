// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// ZarosToken dependencies
import { Base } from "test/Base.t.sol";
import { ZarosToken } from "@zaros/ZarosToken.sol";

// Open Zeppelin dependencies
import { UUPSUpgradeable } from "@openzeppelin/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin-upgradeable/access/OwnableUpgradeable.sol";

contract UpgradeToAndCall_Integration_Test is Base {
    function setUp() public override {
        Base.setUp();
    }

    function test_RevertGiven_UserIsNotTheOwner() external {
        vm.startPrank(users.naruto);

        address newZarosTokenImplementation = address(new ZarosToken());

        // it should revert
        vm.expectRevert({
            revertData: abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, users.naruto)
        });

        UUPSUpgradeable(address(zarosToken)).upgradeToAndCall(newZarosTokenImplementation, bytes(""));
    }

    function test_GivenUserIsTheOwner() external {
        vm.startPrank(users.owner);

        address newZarosTokenImplementation = address(new ZarosToken());

        // it should upgrade the contract
        UUPSUpgradeable(address(zarosToken)).upgradeToAndCall(newZarosTokenImplementation, bytes(""));
    }
}
