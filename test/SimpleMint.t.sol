// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

import { SimpleMint } from "src/SimpleMint.sol";
import { Utilities } from "test/utils/Utilities.sol";


contract SimpleMintHuffTest is Test {
    /// @dev Address of the SimpleStore contract.
    SimpleMintHuff public mintHuff;
    SimpleMint public simpleMint;
    Utilities public utils = new Utilities();

    address[] internal users;
    address internal owner;

    /// @dev Setup the testing environment.
    function setUp() public {
        users = utils.createUsers(11);
        owner = users[1];
        
        address impl = HuffDeployer.deploy("SimpleMintHuff");
        mintHuff = SimpleMintHuff(impl);

        simpleMint = new SimpleMint("https://simplemint.com/");
    }

    function testMint_ShouldSucceed() public {
        vm.prank(users[0]);
        simpleMint.mint{value: 0.02 ether}(2);
        assertEq(simpleMint.balanceOf(users[0]), 2);
    }

    function testMintHuff_ShouldSetRightValues_WhenDeployed() public {
        assertEq(mintHuff.price(), 0.01 ether);
        assertEq(mintHuff.maxMint(), 10);
        assertEq(mintHuff.maxSupply(), 100);
        assertEq(mintHuff.counter(), 0);
    }

    function testMintHuff_ShouldRevert_IfNullQuantity() public {
        vm.expectRevert(SimpleMint.NullQuantity.selector);
        mintHuff.publicMint{value: 0.00 ether}(0);
    }

    function testMintHuff_ShouldSucceed() public {
        vm.prank(users[0]);
        mintHuff.publicMint{value: 0.02 ether}(2);

        assertEq(mintHuff.balanceOf(users[0]), 2);
        assertEq(mintHuff.counter(), 2);
    }

    function testMintHuff_ShouldRevert_WhenQuantityExceedsMaxMint() public {
        vm.expectRevert(SimpleMint.ExceedsMaxMint.selector);
        mintHuff.publicMint{value: 0.11 ether}(11);
    }

    function testMintHuff_ShouldRevert_WhenNotEnoughEthValue() public {
        vm.expectRevert(SimpleMint.InsufficientFunds.selector);
        mintHuff.publicMint{value: 0.00 ether}(1);
    }

    function testMintHuff_ShouldSucceed_WhenUserMintsMaxMint() public {
        vm.prank(users[0]);
        mintHuff.publicMint{value: 0.10 ether}(10);

        assertEq(mintHuff.balanceOf(users[0]), 10);
    }

    function testMintHuff_ShouldRevert_WhenSupplyIsSoldOut() public {
        for(uint256 i = 0; i < 10; i++) {
            vm.prank(users[i]);
            mintHuff.publicMint{value: 0.10 ether}(10);
        }
        vm.prank(users[10]);
        vm.expectRevert(SimpleMint.ExceedsMaxSupply.selector);
        mintHuff.publicMint{value: 0.1 ether}(1);
    }

    function testMintHuff_ShouldRevert_WhenUserMintsMoreThanMaxMint() public {
        vm.startPrank(users[0]);
        mintHuff.publicMint{value: 0.10 ether}(10);

        vm.expectRevert(SimpleMint.ExceedsMaxMint.selector);
        mintHuff.publicMint{value: 0.1 ether}(1);
        vm.stopPrank();
    }

    function testMintHuff_ShouldRevert_IfMaxSupplyIsExceeded() public {
        vm.expectRevert(SimpleMint.ExceedsMaxSupply.selector);
        mintHuff.publicMint(101);
    }
}

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
