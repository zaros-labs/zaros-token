// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Zaros dependecies
import { BaseScript } from "script/Base.s.sol";
import { ZarosToken } from "@zaros/ZarosToken.sol";

// Open Zeppelin dependencies
import { ERC1967Proxy } from "@openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";

// Forge dependencies
import { console } from "forge-std/console.sol";

contract DeployZarosToken is BaseScript {
    function run() public broadcaster {
        address zarosTokenImplementation = address(new ZarosToken());

        bytes memory zarosTokenInitializeData =
            abi.encodeWithSelector(ZarosToken.initialize.selector, deployer, "Zaros Finance", "ZRS");

        address zarosToken = address(new ERC1967Proxy(zarosTokenImplementation, zarosTokenInitializeData));

        console.log("Zaros Token Implementation: ", zarosTokenImplementation);
        console.log("Zaros Token Proxy: ", zarosToken);
    }
}
