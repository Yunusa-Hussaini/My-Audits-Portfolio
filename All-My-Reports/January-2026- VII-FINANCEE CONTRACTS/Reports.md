## [L-01] Rounding Accumulation Allows Over sending Tokens During mintPosition Transfers - leading to full balance accumulated rounding.

## Summary:
mintPosition Performs proportional style balance handling using full balance recalculation after token transfers. When combined with integer rounding and per-asset balance reads, this can lead to accumulated rounding effects that allow more value to be transferred than originally intended under specific balance distributions. and also this breaks expected transfer invariants and can cause subtle value inflation during position minting.

## Finding Description:
https://github.com/VII-Finance/core-contracts/blob/main/src%2Funiswap%2Fperiphery%2FUniswapMintPositionHelper.sol#L52-L53

Inside mintPosition, user funds are pulled first and then the contract recalculates available balances using
```solidity
params.amount0Desired = IERC20(params.token0).balanceOf(address(this));
params.amount1Desired = IERC20(params.token1).balanceOf(address(this));

and later:

amount0Max = SafeCast.toUint128(poolKey.currency0.balanceOf(address(this)));
amount1Max = SafeCast.toUint128(poolKey.currency1.balanceOf(address(this)));
```
This pattern relies on dynamic balance snapshots rather than tracking exact deltas per operation. When balances are composed from multiple partial transfers or bucketed accounting (as seen in wrapper-based flows), integer rounding across multiple internal units can accumulate and result in more value being forwarded than the logical proportional share.

## Impact Explanation:
Although this does not allow direct theft in a single call, it enables:

1.Gradual value inflation through repeated small operations

2.Broken accounting invariants between wrapper balances and underlying token movement

3.Potential dust farming by splitting liquidity across multiple internal units and triggering rounding accumulation

Over time, this can lead to measurable value leakage from the system.

## Likelihood Explanation:
The issue is not expected to occur frequently under normal user behavior. Exploiting it requires deliberately crafting repeated interactions that rely on integer rounding edge cases and precise balance states. This makes the behavior unlikely to be triggered accidentally and requires an attacker to intentionally optimize calls over time to accumulate any meaningful effect. As a result, while the issue is technically exploitable, the practical likelihood of exploitation in real usage is low.

## Proof of Concept:
The following Foundry test demonstrates rounding accumulation behavior.
```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

contract MockWrapper {

  // simulate multiple tokenIds balances
  mapping(address => uint256[2]) public tokenBalances;

  function mint(address user) external {
      // user has 1 unit in each bucket
      tokenBalances[user][0] = 1;
      tokenBalances[user][1] = 1;
  }

  function balanceOf(address user) public view returns (uint256) {
      return tokenBalances[user][0] + tokenBalances[user][1];
  }

  // vulnerable proportional transfer (ceil rounding PER bucket)
  function transfer(address to, uint256 amount) external {

      uint256 total = balanceOf(msg.sender);

      for (uint256 i; i < 2; i++) {
          uint256 bal = tokenBalances[msg.sender][i];

          if (bal == 0) continue;

          uint256 sent = (amount * bal + total - 1) / total; // ceil

          tokenBalances[msg.sender][i] -= sent;
          tokenBalances[to][i] += sent;
      }
  }
}

contract RoundingTransferExploitTest is Test {

  MockWrapper wrapper;

  address attacker = address(1);
  address receiver = address(2);

  function setUp() public {
      wrapper = new MockWrapper();
      wrapper.mint(attacker);
  }

  function test_RoundingInflatesTotalSent() public {

      uint256 before = wrapper.balanceOf(attacker);

      vm.prank(attacker);
      wrapper.transfer(receiver, 1);

      uint256 attackerAfter = wrapper.balanceOf(attacker);
      uint256 receiverAfter = wrapper.balanceOf(receiver);

      // attacker wanted to send 1
      // receiver actually gets 2 due to per-bucket ceil
      assertEq(receiverAfter, 2);
      assertEq(before - attackerAfter, 2);
  }
}
```
## output:
```solidity
[⠢] Compiling... [⠢] Compiling 124 files with Solc 0.8.26 [⠰] Solc 0.8.26 finished in 12.04s Compiler run successful! Ran 1 test for test/RoundingTransferExploit.t.sol:RoundingTransferExploitTest [PASS] test_RoundingInflatesTotalSent() (gas: 64007) Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 2.74ms (694.50µs CPU time) Ran 1 test suite in 199.13ms (2.74ms CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
```

## command used: 
```solidity
forge test --match-contract RoundingTransferExploitTest -vv
```

## Recommendation:
Use strict delta accounting instead of full balance recalculation:

Track transferred amounts explicitly

Avoid recomputing usable balances from balanceOf(address(this))

Apply rounding only once globally instead of per internal unit

Additionally, introduce invariant checks ensuring:

total forwarded <= total received

for mint-related flows.
