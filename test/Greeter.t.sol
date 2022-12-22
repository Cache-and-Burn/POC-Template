// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

contract Exploit is Test {

    function setUp() external {
        vm.createSelectFork("mainnet");
    }

    function testSomething() public {
        
    }
}
