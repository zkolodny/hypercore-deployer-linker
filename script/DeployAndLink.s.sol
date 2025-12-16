// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { HyperCoreDeployerLinker } from "../src/HyperCoreDeployerLinker.sol";
import { Script, console } from "forge-std/Script.sol";
import { UUPSUpgradeable } from "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract DeployAndLink is Script {

    function run(address admin, address deployer, address target, address linkerImpl) public {
        address currentImplementation = address(
            uint160(
                uint256(
                    vm.load(
                        target, 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
                    )
                )
            )
        );
        console.log("admin", admin);
        console.log("deployer", deployer);
        console.log("target", target);
        console.log("currentImplementation", currentImplementation);
        vm.startBroadcast(admin);
        // HyperCoreDeployerLinker impl = HyperCoreDeployerLinker(0x8354D80EeA9978Faa04c3b36771c1e8b9c3e9058);
        console.log("linkerImpl", linkerImpl);

        bytes memory upgradeCalldata = abi.encodeWithSelector(
            UUPSUpgradeable.upgradeToAndCall.selector,
            linkerImpl,
            abi.encodeCall(
                HyperCoreDeployerLinker.setDeployerAndUpgradeToAndCall, (deployer, address(currentImplementation), "")
            )
        );

        (bool success,) = target.call(upgradeCalldata);

        require(success, "failed to upgrade");

        address newImplementation = address(
            uint160(
                uint256(
                    vm.load(
                        target, 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
                    )
                )
            )
        );

        console.log("newImplementation", newImplementation);
        
        console.log();
        console.logBytes(upgradeCalldata);
        console.log();

        vm.stopBroadcast();
    }

}
