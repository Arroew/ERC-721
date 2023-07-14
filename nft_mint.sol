// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
error sales__Paused();
error onlyten__per__transaction();
error only__mint__ten__per__transaction();
error exceeds__limit();
error insufficient__funds();

 contract NFT is ERC721,Ownable{
    using Strings for uint256;
    uint public constant MAX_TOKENS=10000;
    uint256 private TOKENS_RESERVED=5;
    uint256 public price=8000000000;
    uint256 public constant MAX_MINT_PER_TX=10;
    bool public isSalesActive;
    uint256 public totalSupply;
    mapping(address=>uint256)private mintedPerWallet;
    string public baseUri;
    string public baseExtension=".json";

    constructor()ERC721("Mythical Tree","TREE"){
        for(uint256 i=1;i<=TOKENS_RESERVED;i++){
            _safeMint(msg.sender,i);
        }
        totalSupply=TOKENS_RESERVED;
    }
    
    function mint(uint256 _numTokens) external payable onlyOwner{
       if(!isSalesActive){
           revert sales__Paused(); 
       }
       if(_numTokens > MAX_MINT_PER_TX){
           revert onlyten__per__transaction();
       }
       if(mintedPerWallet[msg.sender]+_numTokens >10){
           revert only__mint__ten__per__transaction();
       }
        uint256 curTotalSupply=totalSupply;
        if(curTotalSupply+_numTokens > MAX_TOKENS){
            revert  exceeds__limit();
        }
        if(_numTokens*price > msg.value){
            revert insufficient__funds();
        }
        for(uint256 i=1;i<=_numTokens;i++){
            _safeMint(msg.sender,curTotalSupply+i);
        }
        mintedPerWallet[msg.sender]+=_numTokens;
        totalSupply +=_numTokens;

    }
    // OWNER ONLY FUNCTIONS
    function flipState()external onlyOwner{
        isSalesActive=!isSalesActive;
    }
    function setBaseUri(string memory _baseUri)external onlyOwner{
        baseUri=_baseUri;
    }
    function setPrice(uint256 _price)external onlyOwner{
        price=_price;
    }
    function withdrawAll()external payable onlyOwner{
        uint256 balance= address(this).balance;
        address payable to=payable(msg.sender);
        to.transfer(balance);
        
    }

     function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
 
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }
 
    function _baseURI() internal view virtual override returns (string memory) {
        return baseUri;
    }
}