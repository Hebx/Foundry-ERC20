//SPDX-LICENSE-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {AutoERC20} from "../src/AutoERC20.sol";
import {DeployAutoERC20} from "../script/DeployAutoERC20.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract AutoERC20Test is Test {
    AutoERC20 public autoERC20;
    DeployAutoERC20 public deployerAutoERC20;
    address public deployerAddress;
    uint256 public constant BOB_STARTING_AMOUNT = 100 ether;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    function setUp() public {
        deployerAutoERC20 = new DeployAutoERC20();
        autoERC20 = deployerAutoERC20.run();
        deployerAddress = vm.addr(deployerAutoERC20.deployerKey());
        vm.prank(deployerAddress);
        autoERC20.transfer(bob, BOB_STARTING_AMOUNT);
    }

    function testInitialSupply() public {
        assertEq(autoERC20.totalSupply(), deployerAutoERC20.INITIAL_SUPPLY());
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;
        // Alice approves bob to spend tokens on her behalf
        vm.prank(bob);
        autoERC20.approve(alice, initialAllowance);
        uint256 transferAmount = 500;
        vm.prank(alice);
        autoERC20.transferFrom(bob, alice, transferAmount);
        assertEq(autoERC20.balanceOf(alice), transferAmount);
        assertEq(
            autoERC20.balanceOf(bob),
            BOB_STARTING_AMOUNT - transferAmount
        );
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(autoERC20)).mint(address(this), 10);
    }
}
