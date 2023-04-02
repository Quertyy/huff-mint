//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { ERC721 } from "solmate/tokens/ERC721.sol";
import { LibString } from "solmate/utils/LibString.sol";

contract SimpleMint is ERC721 {

    address public owner;
    string public baseURI;

    uint256 public constant MAX_SUPPLY = 100;
    uint256 public constant MAX_MINT = 10;
    uint256 public constant PRICE = 0.01 ether;
    uint256 private counter;

    mapping(address => uint256) public minter;

    error NotOwner();
    error NullQuantity();
    error ExceedsMaxMint();
    error ExceedsMaxSupply();
    error InsufficientFunds();

    event Minted(address indexed to, uint256 qty);

    modifier onlyOwner {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(string memory uri) ERC721("SimpleMint", "SIM") {
        owner = msg.sender;
        baseURI = uri;
    }

    function setBaseURI(string memory uri) external onlyOwner {
        baseURI = uri;
    }

    function mint(uint256 qty) external payable {
        uint256 currentCounter = counter;
        if (qty == 0) revert NullQuantity();
        if (currentCounter + qty > MAX_SUPPLY) revert ExceedsMaxSupply();
        if (minter[msg.sender] + qty > MAX_MINT) revert ExceedsMaxMint();
        if (msg.value < PRICE * qty) revert InsufficientFunds();

        minter[msg.sender] += qty;

        for (uint i = 0; i < qty; i++) {
            _mint(msg.sender, currentCounter + 1);
        } 

        counter = currentCounter;
        emit Minted(msg.sender, qty);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory _tokenURI = string(abi.encodePacked(baseURI, LibString.toString(tokenId),".json"));
        return _tokenURI;
    }
}