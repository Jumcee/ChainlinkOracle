// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Standard ERC20 Interface
interface IERC20 {
  function transfer(address recipient, uint256 amount) external;
  function transferFrom(address sender, address recipient, uint256 amount) external;
}

contract TokenSwap {
  // Mapping for token addresses
  mapping(address => address) public tokenPairs;

  // Event for successful swaps
    event Swap(address fromToken, address toToken, uint256 amountIn, uint256 amountOut, address recipient);

  constructor(address _ethToken, address _linkToken, address _daiToken) {
    tokenPairs[_ethToken] = _linkToken;
    tokenPairs[_linkToken] = _ethToken;

    tokenPairs[_ethToken] = _daiToken;
    tokenPairs[_daiToken] = _ethToken;

    tokenPairs[_linkToken] = _daiToken;
    tokenPairs[_daiToken] = _linkToken;
  }

  // Swap function
  function swap(address fromToken, address toToken, uint256 amountIn) public payable {
    require(tokenPairs[fromToken] == toToken, "Invalid token pair");
    require(fromToken != address(0) && toToken != address(0), "Invalid token addresses");

    // Handle ETH transfers
    if (fromToken == address(0)) {
      require(msg.value == amountIn, "Insufficient ETH sent");
      IERC20(toToken).transfer(msg.sender, amountIn);
    } else {
      // User transfers tokens to the contract
      IERC20(fromToken).transferFrom(msg.sender, address(this), amountIn);

      // Calculate amount out based on (potentially) external price oracle
      // This example assumes a fixed rate for simplicity (replace with your logic)
      uint256 amountOut = amountIn * 2; // Replace with price oracle logic

      // Transfer tokens out to recipient
      IERC20(toToken).transfer(msg.sender, amountOut);
    }

      //emit Swap(fromToken, toToken, amountIn, amountOut, msg.sender);
  }

  // Function to receive ETH (optional)
  receive() external payable {}
}