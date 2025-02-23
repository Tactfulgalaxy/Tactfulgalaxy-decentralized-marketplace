// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/console.sol";

contract DecentralizedMarketPlace {
    struct product {
        uint productId;
        string name;
        uint price;
        string Description;
        string ImageUrl;
        address payable seller;
        address buyer;
    }

    struct Transaction {
        uint productId;
        address buyer;
        uint price;
        uint timestamp;
    }
    
    product[] public products; // Array to store all products
    Transaction[] public allTransactions; // Array to store all transactions
     // Events
    event ProductPurchased(uint indexed productId, string name, address indexed buyer, uint price, uint timestamp);
    event ProductListed(uint indexed productId, string name, address indexed seller, uint price);

    function addProduct(string memory _name, uint _price, string memory _Description, string memory _imageurl) public{
        require(_price > 0, "price must be greater than zero");

            products.push(product({
            productId: products.length,
            name: _name,
            price: _price,
            Description: _Description,
            ImageUrl: _imageurl,
            seller: payable(msg.sender),
            buyer: address(0)
        }));

        console.log(products[products.length - 1].name);

        emit ProductListed(products.length - 1, _name, msg.sender , _price);
    }
    

    function buyProduct(uint _productId) public payable{
        require(_productId < products.length, "Invalid product ID");
        product storage specificProduct = products[_productId];
        require(specificProduct.buyer == address(0), "Product already sold");
        require(msg.value >= specificProduct.price, "Not enough Ether sent");

        specificProduct.seller.transfer(specificProduct.price);
        specificProduct.buyer = msg.sender;

        
        emit ProductPurchased(_productId, specificProduct.name, msg.sender, specificProduct.price, block.timestamp);
    }
    
    
    
       function sellProduct(string memory _name, uint _price, string memory _Description, string memory _imageurl) public {
        require(_price > 0, "Price must be greater than zero");

        products.push(product({
            productId: products.length,
            name: _name,
            price: _price,
            Description: _Description,
            ImageUrl: _imageurl,
            seller: payable(msg.sender),
            buyer: address(0)
        }));

        emit ProductListed(products.length - 1, _name, msg.sender, _price);
    }
}
    