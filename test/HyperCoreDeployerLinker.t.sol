// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { PermissionedSalt } from "deterministic-proxy-factory/PermissionedSalt.sol";
import {
    DeterministicProxyFactoryFixture,
    MINIMAL_UUPS_UPGRADEABLE_ADDRESS
} from "deterministic-proxy-factory/fixtures/DeterministicProxyFactoryFixture.sol";
import { Test, console } from "forge-std/Test.sol";
import { HyperCoreDeployerLinker } from "src/HyperCoreDeployerLinker.sol";

import { ERC20Upgradeable } from "openzeppelin-contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import { DeployAndLink } from "../script/DeployAndLink.s.sol";

contract HyperCoreDeployerLinkerTest is Test, DeployAndLink {

    address hyperCoreDeployer;
    ERC20Upgradeable cashProxy;
    address admin;
    address currentImpl;
    bytes32 deployerStorageSlot;

    event Upgraded(address indexed newImplementation);

    function setUp() public {
        hyperCoreDeployer = 0x95c3a4730fCE7efb6CAc820033B20925Bed93796;
        cashProxy = ERC20Upgradeable(0x061Af032cCf1CE35A39b556e0F442bF2DBe1Ed06);
        admin = 0x79C6631FA15CdA38777FB9DD7a6348bAEe794a4E;
        deployerStorageSlot = keccak256("HyperCore deployer");
    }

    function test_upgrade_and_set_variable() public {
        string memory nameBefore = cashProxy.name();
        string memory symbolBefore = cashProxy.symbol();
        uint256 totalSupplyBefore = cashProxy.totalSupply();
        uint256 decimalsBefore = cashProxy.decimals();
        
        run(admin, hyperCoreDeployer, address(cashProxy));

        string memory nameAfter = cashProxy.name();
        string memory symbolAfter = cashProxy.symbol();
        uint256 totalSupplyAfter = cashProxy.totalSupply();
        uint256 decimalsAfter = cashProxy.decimals();

        assertEq(nameBefore, nameAfter);
        assertEq(symbolBefore, symbolAfter);
        assertEq(totalSupplyBefore, totalSupplyAfter);
        assertEq(decimalsBefore, decimalsAfter);

        address deployerInStorageSlot = address(
            uint160(
                uint256(
                    vm.load(
                        address(cashProxy), deployerStorageSlot
                    )
                )
            )
        );

        assertNotEq(deployerInStorageSlot, address(0));
        assertEq(hyperCoreDeployer, deployerInStorageSlot);
        console.log("deployerInStorageSlot", deployerInStorageSlot);
    }
}
