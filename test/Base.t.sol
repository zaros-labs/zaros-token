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

contract Base is Test {
    /*//////////////////////////////////////////////////////////////////////////
                                     STRUCTS
    //////////////////////////////////////////////////////////////////////////*/

    struct Users {
        address owner;
        address naruto;
        address sakura;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    Users users = users = Users({ owner: msg.sender, naruto: address(0x123), sakura: address(0x456) });
    ZarosToken zarosToken;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        address zarosTokenImplementation = address(new ZarosToken());
        bytes memory zarosTokenInitializeData =
            abi.encodeWithSelector(ZarosToken.initialize.selector, users.owner, "ZarosToken", "ZRS");
        zarosToken = ZarosToken(address(new ERC1967Proxy(zarosTokenImplementation, zarosTokenInitializeData)));
    }
}
