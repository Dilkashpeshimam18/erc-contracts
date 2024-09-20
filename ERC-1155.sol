// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

contract Nft115 is ERC1155, Ownable, ERC1155Pausable, ERC1155Supply, PaymentSplitter {
    constructor(address[] memory _payees,
    uint256[] memory _shares
    )
        ERC1155("ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/")
        Ownable(msg.sender)
        PaymentSplitter(_payees,_shares)
    {}
    uint256 public maxSupply=10;
    mapping (address=>bool)  allowListPeople;
    bool public publicMintOpen=false;
    bool public allowListMintOpen=false;
    uint256 public maxMintPerWallet=10;

    mapping (address=>uint256)  purchasePerWallet;

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setAllowList(address[] calldata addresses) external onlyOwner{
      for(uint256 i=0;i < addresses.length;i++){
        allowListPeople[addresses[i]]=true;
      }
    }

   function editMintWindow(bool _publicMintOpen,bool _allowListMintOpen) external onlyOwner {
        publicMintOpen=_publicMintOpen;
        allowListMintOpen=_allowListMintOpen;
    }
    function allowListMint(uint256 id, uint256 amount) public payable {
                require(purchasePerWallet[msg.sender] + amount < maxMintPerWallet, "Wallet limit reached");

        require(allowListMintOpen,"Allow List Mint Closed");
        require(allowListPeople[msg.sender], "You are not on the allow list");
        require(msg.value== 0.001 ether * amount, "Not enough funds");
        require(totalSupply(id) + amount < maxSupply,"Sorry, We have minted out!");
        require(id < 3, "Sorry you're trying mint the wrong NFT");

        _mint(msg.sender, id, amount, "");
    }
    function mint( uint256 id, uint256 amount)
        public
        payable 
    {
        require(purchasePerWallet[msg.sender] + amount < maxMintPerWallet, "Wallet limit reached");
        require(publicMintOpen,"Allow List Mint Closed");
        require(id < 3, "Sorry you're trying mint the wrong NFT");
        require(msg.value==0.01 ether * amount,"Not enough funds to mint NFT");
        require(totalSupply(id) + amount < maxSupply,"Sorry, We have minted out!");

        _mint(msg.sender, id, amount, "");
        purchasePerWallet[msg.sender] +=amount;
        
    }

    //withdraw function allows you to withdraw amount from the smart contract
   function withdraw(address _addr) external onlyOwner {
    uint256 balance=address(this).balance;
    payable (_addr).transfer(balance);
   }
    function uri(uint256 id) public view virtual override returns (string memory){
        require(exists(id),"URI non-existed token");
        return string(abi.encodePacked(super.uri(id), Strings.toString(id),".json"));
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Pausable, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }
}
