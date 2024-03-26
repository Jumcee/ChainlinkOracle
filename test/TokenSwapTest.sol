// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";
import { TokenSwap } from "../src/TokenSwap.sol";
//import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";

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
    using SafeMath for uint256;

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
        assertEq(finalEthBalance, initialEthBalance.sub(amountEth));

        // Verify that Link balance increased by amountOut (assuming a fixed rate in the swap function)
        assertEq(finalLinkBalance, initialLinkBalance.add(amountEth.mul(2))); // Replace with actual amountOut calculation
    }

    // Test swapping from Eth to Dai
    function testSwapEthToDai() public {
        uint256 amountEth = 1 ether;
        address recipient = address(this);

        // Get initial balances
        uint256 initialEthBalance = MockToken(ethToken).balanceOf(address(this));
        uint256 initialDaiBalance = MockToken(daiToken).balanceOf(recipient);

        // Perform the swap
        tokenSwap.swap{value: amountEth}(ethToken, daiToken, amountEth);

        // Get final balances after the swap
        uint256 finalEthBalance = MockToken(ethToken).balanceOf(address(this));
        uint256 finalDaiBalance = MockToken(daiToken).balanceOf(recipient);

        // Verify that Eth balance decreased by amountEth
        assertEq(finalEthBalance, initialEthBalance.sub(amountEth));

        // Verify that Dai balance increased by amountOut (assuming a fixed rate in the swap function)
        assertEq(finalDaiBalance, initialDaiBalance.add(amountEth.mul(2))); // Replace with actual amountOut calculation
    }

    // Test swapping from Link to Dai
    function testSwapLinkToDai() public {
        uint256 amountLink = 1 ether;
        address recipient = address(this);

        // Get initial balances
        uint256 initialLinkBalance = MockToken(linkToken).balanceOf(address(this));
        uint256 initialDaiBalance = MockToken(daiToken).balanceOf(recipient);

        // Perform the swap
        tokenSwap.swap(linkToken, daiToken, amountLink);

        // Get final balances after the swap
        uint256 finalLinkBalance = MockToken(linkToken).balanceOf(address(this));
        uint256 finalDaiBalance = MockToken(daiToken).balanceOf(recipient);

        // Verify that Link balance decreased by amountLink
        assertEq(finalLinkBalance, initialLinkBalance.sub(amountLink));

        // Verify that Dai balance increased by amountOut (assuming a fixed rate in the swap function)
        assertEq(finalDaiBalance, initialDaiBalance.add(amountLink.mul(2))); // Replace with actual amountOut calculation
    }

    // Test swapping from Dai to Eth
    function testSwapDaiToEth() public {
        uint256 amountDai = 1 ether;

        // Get initial balances
        uint256 initialDaiBalance = MockToken(daiToken).balanceOf(address(this));
        uint256 initialEthBalance = address(this).balance;

        // Transfer Dai tokens to the contract
        MockToken(daiToken).transfer(address(tokenSwap), amountDai);

        // Perform the swap
        tokenSwap.swap(daiToken, ethToken, amountDai);

        // Get final balances after the swap
        uint256 finalDaiBalance = MockToken(daiToken).balanceOf(address(this));
        uint256 finalEthBalance = address(this).balance;

        // Verify that Dai balance decreased by amountDai
        assertEq(finalDaiBalance, initialDaiBalance.sub(amountDai));

        // Verify that Eth balance increased by amountOut (assuming a fixed rate in the swap function)
        assertEq(finalEthBalance, initialEthBalance.add(amountDai.mul(2))); // Replace with actual amountOut calculation
    }
}

