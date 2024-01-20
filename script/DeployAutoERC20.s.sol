//SPDX-LICENSE-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {AutoERC20} from "../src/AutoERC20.sol";

contract DeployAutoERC20 is Script {
    uint256 public constant INITIAL_SUPPLY = 1000000 ether; // 1M with 18 decimals
    uint256 public DEFAULT_ANVIL_PRIVATE_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 public deployerKey;

    function run() external returns (AutoERC20) {
        if (block.chainid == 31337) {
            deployerKey = DEFAULT_ANVIL_PRIVATE_KEY;
        } else {
            deployerKey = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployerKey);
        AutoERC20 autoERC20 = new AutoERC20(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return autoERC20;
    }
}
