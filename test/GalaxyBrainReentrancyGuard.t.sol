// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {GalaxyBrainReentrancyGuard, MessageCall} from "src/GalaxyBrainReentrancyGuard.sol";

contract GoodTarget {
    uint256 public number;

    function setNumber(uint256 x) public {
        number = x;
    }
}

contract BadTarget {
    uint256 public number;

    function setNumber(uint256 x) public {
        number = x;
        MessageCall memory msgCall = MessageCall(address(this), 0, abi.encodeWithSelector(this.setNumber.selector, 69));
        GalaxyBrainReentrancyGuard(msg.sender).nonReentrant(msgCall);
    }
}

contract GalaxyBrainReentrancyGuardTest is Test {
    GalaxyBrainReentrancyGuard public guard;
    GoodTarget public goodTarget;
    BadTarget public badTarget;

    function setUp() public {
        guard = new GalaxyBrainReentrancyGuard();
        goodTarget = new GoodTarget();
        badTarget = new BadTarget();
    }

    function testGood() public {
        MessageCall memory call = MessageCall(address(goodTarget), 0, abi.encodeWithSignature("setNumber(uint256)", 42));
        guard.nonReentrant(call);
        assertEq(goodTarget.number(), 42);
    }

    function testBad() public {
        MessageCall memory call = MessageCall(address(badTarget), 0, abi.encodeWithSignature("setNumber(uint256)", 42));
        guard.nonReentrant(call);
        assertEq(badTarget.number(), 0);
    }
}
