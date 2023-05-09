# 🧠 Galaxy Brain Reentrancy Guard

Billions have been lost to reentrancy attacks. It's time to put a stop to this madness.

Galaxy Brain Reentrancy Guard *guarantees* that the targeted external call can not make any additional calls, for the low price of 3.7M gas:

```
Running 2 tests for test/GalaxyBrainReentrancyGuard.t.sol:GalaxyBrainReentrancyGuardTest
[PASS] testBad() (gas: 3692142)
[PASS] testGood() (gas: 3689278)
```

## How does this work?

The EVM supports a maximum call stack depth of 1024. Therefore, when you're the frame at the top of a stack of 1024 calls, you can't create any additional calls. Now, that's security!

There is no native way to know the current call stack depth in the EVM, so [GalaxyBrainReentrancyGuard](https://github.com/karmacoma-eth/galaxy-brain-reentrancy-guard/blob/main/src/GalaxyBrainReentrancyGuard.sol) uses recursion to create a stack with the maximum depth. It keeps calling itself until it starts failing, then it calls the final destination.

```solidity
function _nonReentrant(MessageCall memory call) public returns (bool success, bytes memory returndata) {
    require(msg.sender == address(this), "WRONG_SENDER");

    try GalaxyBrainReentrancyGuard(address(this)).test_hop() {
        // ⛏️ test_hop succeeded, need to go deeper
        (success, returndata) = GalaxyBrainReentrancyGuard(address(this))._nonReentrant(call);
    } catch {
        // 👌 test_hop failed, we reached the max call height
        (success, returndata) = call.target.call{value: call.value}(call.data);
    }
}
```

## Is this a joke?

What is reality? Why are we here? This line of questioning is really getting us nowhere.


## Disclaimer

These smart contracts are being provided as is. No guarantee, representation or warranty is being made, express or implied, as to the safety or correctness of the user interface or the smart contracts. They have not been audited and as such there can be no assurance they will work as intended, and users may experience delays, failures, errors, omissions or loss of transmitted information. THE SMART CONTRACTS CONTAINED HEREIN ARE FURNISHED AS IS, WHERE IS, WITH ALL FAULTS AND WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTY OF MERCHANTABILITY, NON- INFRINGEMENT OR FITNESS FOR ANY PARTICULAR PURPOSE. Further, use of any of these smart contracts may be restricted or prohibited under applicable law, including securities laws, and it is therefore strongly advised for you to contact a reputable attorney in any jurisdiction where these smart contracts may be accessible for any questions or concerns with respect thereto. Further, no information provided in this repo should be construed as investment advice or legal advice for any particular facts or circumstances, and is not meant to replace competent counsel. a16z is not liable for any use of the foregoing, and users should proceed with caution and use at their own risk. See a16z.com/disclosures for more info.
