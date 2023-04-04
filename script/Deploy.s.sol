// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Script.sol";

interface SimpleMintHuff {
    function owner() external view returns (address);
    function withdraw() external;
    
    function publicMint(uint256) external payable;

    function price() external view returns (uint256);
    function maxMint() external view returns (uint256);
    function maxSupply() external view returns (uint256);
    function counter() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract Deploy is Script {
  function run() public returns (SimpleMintHuff mintHuff) {
      address impl = HuffDeployer.deploy("SimpleMintHuff");
      mintHuff = SimpleMintHuff(impl);
  }
}
