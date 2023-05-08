// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

struct MessageCall {
    address target;
    uint256 value;
    bytes data;
}

contract GalaxyBrainReentrancyGuard {
    function test_hop() public view {
        GalaxyBrainReentrancyGuard(address(this)).hop_target();
    }

    function hop_target() public pure {}

    function nonReentrant(MessageCall memory call) public returns (bool success, bytes memory returndata) {
        require(msg.sender != address(this), "WRONG_SENDER");

        (success, returndata) = GalaxyBrainReentrancyGuard(address(this))._nonReentrant(call);
    }

    function _nonReentrant(MessageCall memory call) public returns (bool success, bytes memory returndata) {
        require(msg.sender == address(this), "WRONG_SENDER");

        try GalaxyBrainReentrancyGuard(address(this)).test_hop() {
            // test_hop succeeded, need to go deeper
            (success, returndata) = GalaxyBrainReentrancyGuard(address(this))._nonReentrant(call);
        } catch {
            // test_hop failed, we reached the max call height 👌
            (success, returndata) = call.target.call{value: call.value}(call.data);
        }
    }
}
