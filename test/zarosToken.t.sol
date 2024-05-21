// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Zaros dependecies
import { ZarosToken } from "@zaros/ZarosToken.sol";

// Open Zeppelin dependencies
import { ERC1967Proxy } from "@openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";

// Open zeppelin upgradeable dependencies
import { OwnableUpgradeable } from "@openzeppelin-upgradeable/access/OwnableUpgradeable.sol";

// Forge dependencies
import { Test } from "forge-std/Test.sol";

contract ZarosToken_Integration_Test is Test {
    struct Users {
        address owner;
        address naruto;
        address sakura;
    }

    Users users = users = Users({ owner: msg.sender, naruto: address(0x123), sakura: address(0x456) });

    address zarosToken;

    function setUp() public {
        address zarosTokenImplementation = address(new ZarosToken());
        bytes memory zarosTokenInitializeData =
            abi.encodeWithSelector(ZarosToken.initialize.selector, users.owner, "ZarosToken", "ZRS");
        zarosToken = address(new ERC1967Proxy(zarosTokenImplementation, zarosTokenInitializeData));
    }

    modifier givenUserIsNotTheOwner() {
        _;
    }

    function test_RevertGiven_UserIsNotTheOwnerAndTryToUpdateTheAddressList() external givenUserIsNotTheOwner {
        vm.startPrank(users.naruto);

        // it should revert
        vm.expectRevert({
            revertData: abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, users.naruto)
        });

        ZarosToken(zarosToken).updateAllowList(users.naruto, true);

        address[] memory addresses = new address[](2);
        addresses[0] = users.naruto;
        addresses[1] = users.sakura;

        bool[] memory isAllowed = new bool[](2);
        isAllowed[0] = true;
        isAllowed[1] = false;

        // it should revert
        vm.expectRevert({
            revertData: abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, users.naruto)
        });

        ZarosToken(zarosToken).updateArrayOfAddresses(addresses, isAllowed);
    }

    modifier givenUserIsTheOwner() {
        _;
    }

    function test_GivenUserIsTheOwnerAndTryToUpdateTheAddressList(uint256 quantityOfUsers) external givenUserIsTheOwner {
        vm.startPrank(users.owner);
        quantityOfUsers = bound(quantityOfUsers, 1, 1000);

        address[] memory addresses = new address[](quantityOfUsers);
        bool[] memory isAllowed = new bool[](quantityOfUsers);

        for (uint256 i = 0; i < quantityOfUsers; i++) {
            addresses[i] = address(uint160(i));
            isAllowed[i] = i % 2 == 0 ? true : false;

            // it should emit {LogUpdateAllowList} event
            vm.expectEmit({ emitter: zarosToken });
            emit ZarosToken.LogUpdateAllowList(addresses[i], isAllowed[i]);
        }

        ZarosToken(zarosToken).updateArrayOfAddresses(addresses, isAllowed);
    }

    function test_RevertGiven_TheArrayOfAddressesAndPermissionsHasADifferentLength() external givenUserIsTheOwner {
        vm.startPrank(users.owner);

        address[] memory addresses = new address[](2);
        addresses[0] = users.naruto;
        addresses[1] = users.sakura;

        bool[] memory isAllowed = new bool[](1);
        isAllowed[0] = true;

        // it should revert
        vm.expectRevert({
            revertData: abi.encodeWithSelector(ZarosToken.ArrayMustBeOfEqualLength.selector, addresses, isAllowed)
        });

        ZarosToken(zarosToken).updateArrayOfAddresses(addresses, isAllowed);
    }

    modifier givenUserIsNotInTheAllowList() {
        _;
    }

    function test_GivenUserIsNotInTheAllowListAndCallsMintFunction() external givenUserIsNotInTheAllowList {
        vm.startPrank(users.naruto);

        // it should revert
        vm.expectRevert({ revertData: abi.encodeWithSelector(ZarosToken.UserNotAllowed.selector, users.naruto) });

        ZarosToken(zarosToken).mint(users.naruto, 100);
    }

    function test_GivenUserIsNotInTheAllowListChecksIfHeHasAccess() external givenUserIsNotInTheAllowList {
        vm.startPrank(users.naruto);

        // it should return false
        (bool isAllowed) = ZarosToken(zarosToken).checkIfTheUserHasPermission(users.naruto);

        assertEq(isAllowed, false, "isAllowed should be false");
    }

    modifier givenUserIsInTheAllowList() {
        _;
    }

    function test_GivenUserIsInTheAllowListAndCallsMintFunction(uint256 amount) external givenUserIsInTheAllowList {
        vm.startPrank(users.owner);
        amount = bound(amount, 1, 100_000_000e18);

        ZarosToken(zarosToken).updateAllowList(users.naruto, true);

        // it should emit {LogMint} event
        vm.expectEmit({ emitter: zarosToken });
        emit ZarosToken.LogMint(users.naruto, amount);

        // it should mint
        ZarosToken(zarosToken).mint(users.naruto, amount);

        assertEq(ZarosToken(zarosToken).balanceOf(users.naruto), amount, "balance should be equal to amount");
    }

    function test_GivenUserIsInTheAllowListChecksIfHeHasAccess() external givenUserIsInTheAllowList {
        vm.startPrank(users.owner);

        ZarosToken(zarosToken).updateAllowList(users.naruto, true);

        // it should mint
        (bool isAllowed) = ZarosToken(zarosToken).checkIfTheUserHasPermission(users.naruto);

        assertEq(isAllowed, true, "isAllowed should be true");
    }
}
