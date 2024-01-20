//SPDX-LICENSE-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {AutoERC20} from "../src/AutoERC20.sol";
import {DeployAutoERC20} from "../script/DeployAutoERC20.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract AutoERC20Test is Test {
    AutoERC20 public autoERC20;
    DeployAutoERC20 public deployer;
    address public deployerAddress;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    function setUp() public {
        deployer = new DeployAutoERC20();
        autoERC20 = deployer.run();
        deployerAddress = vm.addr(deployer.deployerKey());
        vm.prank(deployerAddress);
    }
}
