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

    function testTokenTransfer() public {
        uint256 transferAmount = 100 ether;
        uint256 bobInitialBalance = autoERC20.balanceOf(bob);

        // Bob transfers tokens to Alice
        vm.prank(bob);
        autoERC20.transfer(alice, transferAmount);

        assertEq(autoERC20.balanceOf(bob), bobInitialBalance - transferAmount);
        assertEq(autoERC20.balanceOf(alice), transferAmount);
        // assertEmittedCorrectTransferEvent(bob, alice, transferAmount);
    }

    function testTransferFailInsufficientBalance() public {
        uint256 bobBalance = autoERC20.balanceOf(bob);
        uint256 transferAmount = bobBalance + 1 ether; // more than Bob has

        vm.expectRevert("ERC20: transfer amount exceeds balance");
        vm.prank(bob);
        autoERC20.transfer(alice, transferAmount);
    }

    function testCorrectOwnerBalance() public {
        assertEq(
            autoERC20.balanceOf(deployerAddress),
            deployerAutoERC20.INITIAL_SUPPLY() - BOB_STARTING_AMOUNT
        );
    }

    function testTransferFromExceedingAllowance() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 1500; // more than the allowance

        // Alice approves bob to spend tokens on her behalf
        vm.prank(alice);
        autoERC20.approve(bob, initialAllowance);

        vm.expectRevert("ERC20: insufficient allowance");
        vm.prank(bob);
        autoERC20.transferFrom(alice, bob, transferAmount);
    }

    // function assertEmittedCorrectTransferEvent(
    //     address from,
    //     address to,
    //     uint256 value
    // ) internal {
    //     vm.expectEmit(true, true, true, true);
    //     emit Transfer(from, to, value);
    // }

    function testApproveFromZeroAddress() public {
        vm.expectRevert("ERC20: approve from the zero address");
        vm.prank(address(0));
        autoERC20.approve(alice, 1000);
    }
}
