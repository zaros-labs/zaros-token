// ZarosToken dependencies
import { Base } from "test/Base.t.sol";
import { ZarosToken } from "@zaros/ZarosToken.sol";

// Open zeppelin upgradeable dependencies
import { OwnableUpgradeable } from "@openzeppelin-upgradeable/access/OwnableUpgradeable.sol";

contract SetIsMinter_Integration_Test is Base {
    function setUp() public override {
        Base.setUp();
    }

    function testFuzz_RevertGiven_UserIsNotTheOwner(bool isAllowed) external {
        vm.startPrank(users.naruto);

        // it should revert
        vm.expectRevert({
            revertData: abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, users.naruto)
        });

        zarosToken.setIsMinter(users.sakura, isAllowed);
    }

    function testFuzz_GivenUserIsTheOwner(bool isAllowed) external {
        vm.startPrank(users.owner);

        // it should emit {LogSetIsMinter} event
        vm.expectEmit({ emitter: address(zarosToken) });
        emit ZarosToken.LogSetIsMinter(users.sakura, isAllowed);

        // it should update if user is minter
        zarosToken.setIsMinter(users.sakura, isAllowed);
    }
}
