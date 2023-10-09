// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTPrize is
ERC721
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    address public verifierContractAddToTen;
    address public verifierMagicNumber;

    constructor() ERC721("Secret NFT", "SHH") {}    

    struct Puzzle {
        uint index;
        address addr;
    }

    Puzzle[] public puzzles;

    mapping(uint => bool) tokenUniqueness;

    event PuzzleAdded(address addr, uint puzzleId);

    function addPuzzle(address _addr) public { 
        uint tokenId = puzzles.length;
        Puzzle memory puzzle = Puzzle(tokenId, _addr);
        puzzles.push(puzzle);
        emit PuzzleAdded(_addr,tokenId);
    }

    function mint(
        uint[2] calldata a,
        uint[2] calldata a_p,
        uint[2][2] calldata b,
        uint[2] calldata b_p,
        uint[2] calldata c,
        uint[2] calldata c_p,
        uint[2] calldata h,
        uint[2] calldata k,
        uint[1] calldata input, 
        uint puzzleIndex
    ) public returns(bool) { 
        require(tokenUniqueness[a[0]] == false, "this answer was already previously submitted");

        bool result = iVerifier(puzzles[puzzleIndex].addr).verifyTx(a, a_p, b, b_p, c, c_p, h, k, input);
        require(result, "incorrect proof");

        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();

        _safeMint(msg.sender, tokenId);
        tokenUniqueness[a[0]] = true;

        return true;
    }
}

interface  iVerifier { 
    function verifyTx(
            uint[2] calldata a,
            uint[2] calldata a_p,
            uint[2][2] calldata b,
            uint[2] calldata b_p,
            uint[2] calldata c,
            uint[2] calldata c_p,
            uint[2] calldata h,
            uint[2] calldata k,
            uint[1] calldata input
        ) external returns (bool r); 
}
