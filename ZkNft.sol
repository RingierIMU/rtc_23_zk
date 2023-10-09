// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTPrize is
ERC721
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    iVerifier private Verifier;
    
    constructor() ERC721("ZK NFT", "ZK_NFT") {}    

    mapping(uint => bool) tokenUniqueness;

    function setVerifier(address _addr) public { 
        Verifier = iVerifier(_addr);
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
        uint[1] calldata input
    ) public returns(bool) { 
        require(tokenUniqueness[a[0]] == false, "this answer was already previously submitted");

        bool result = Verifier.verifyTx(a, a_p, b, b_p, c, c_p, h, k, input);
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
