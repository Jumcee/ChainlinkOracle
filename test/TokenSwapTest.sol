// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";
import { TokenSwap } from "../src/TokenSwap.sol";

// MockToken contract for testing purposes
contract MockToken {
    string public name;
    string public symbol;
    mapping(address => uint256) balances;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function transfer(address recipient, uint256 amount) external {
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}

contract TokenSwapTest is Test {
    // Define token addresses
    address ethToken;
    address linkToken;
    address daiToken;

    // TokenSwap contract instance
    TokenSwap tokenSwap;

    // Deploy the TokenSwap contract and set token addresses
    function setUp() public {
        // Deploy mock tokens for testing
        ethToken = address(new MockToken("ETH Token", "ETH"));
        linkToken = address(new MockToken("LINK Token", "LINK"));
        daiToken = address(new MockToken("DAI Token", "DAI"));
        
        tokenSwap = new TokenSwap(ethToken, linkToken, daiToken);
    }

    // Test swapping from Eth to Link
    function testSwapEthToLink() public {
        uint256 amountEth = 1 ether;
        address recipient = address(this);

        // Get initial balances
        uint256 initialEthBalance = MockToken(ethToken).balanceOf(address(this));
        uint256 initialLinkBalance = MockToken(linkToken).balanceOf(recipient);

        // Perform the swap
        tokenSwap.swap{value: amountEth}(ethToken, linkToken, amountEth);

        // Get final balances after the swap
        uint256 finalEthBalance = MockToken(ethToken).balanceOf(address(this));
        uint256 finalLinkBalance = MockToken(linkToken).balanceOf(recipient);

        // Verify that Eth balance decreased by amountEth
        assertEq(finalEthBalance, initialEthBalance - amountEth);

        // Verify that Link balance increased by amountOut (assuming a fixed rate in the swap function)
        assertEq(finalLinkBalance, initialLinkBalance + (amountEth * 2)); // Replace with actual amountOut calculation
    }

    // Similarly, add test functions for other swap pairs (Eth to Dai, Link to Eth, etc.)
    // function testSwapEthToDai() {...}
    // function testSwapLinkToEth() {...}
    // function testSwapLinkToDai() {...}
    // function testSwapDaiToEth() {...}
    // function testSwapDaiToLink() {...}
}
