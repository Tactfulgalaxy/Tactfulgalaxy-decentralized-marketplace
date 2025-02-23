// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "/src/DecentralizedMarketPlace.sol"; 

contract DecentralizedMarketPlaceTest is Test {
    DecentralizedMarketPlace marketplace;

    address buyer = address(uint160(uint256(keccak256("buyer"))));
    address seller = address(uint160(uint256(keccak256("seller"))));
    address anotherBuyer = address(uint160(uint256(keccak256("anotherBuyer"))));

    function setUp() public {
        marketplace = new DecentralizedMarketPlace();
        vm.deal(buyer, 10 ether); // Assign 10 ether to buyer
        vm.deal(seller, 10 ether); // Assign 10 ether to seller
        vm.deal(anotherBuyer, 10 ether); // Assign 10 ether to another buyer
    }

    /// @dev ✅ Test 1: Should allow adding a product successfully
    function test_AddProduct() public {
        vm.prank(seller);
        marketplace.addProduct("Laptop", 2 ether, "A gaming laptop", "image-url");

        (uint productId, string memory name, uint price, , , address payable _seller, address _buyer) = marketplace.products(0);

        assertEq(productId, 0);
        assertEq(name, "Laptop");
        assertEq(price, 2 ether);
        assertEq(_seller, seller);
        assertEq(_buyer, address(0));
    }

    /// @dev ✅ Test 2: Should emit ProductListed event when adding a product
    function test_AddProduct_EmitsEvent() public {
        vm.prank(seller);
        vm.expectEmit(true, true, false, true);
        emit DecentralizedMarketPlace.ProductListed(0, "Laptop", seller, 2 ether);

        marketplace.addProduct("Laptop", 2 ether, "A gaming laptop", "image-url");
    }

    /// @dev ✅ Test 3: Should allow a buyer to purchase a product
    function test_BuyProduct() public {
        vm.prank(seller);
        marketplace.addProduct("Laptop", 2 ether, "A gaming laptop", "image-url");

        vm.prank(buyer);
        marketplace.buyProduct{value: 2 ether}(0);

        (, , , , , , address _buyer) = marketplace.products(0);
        assertEq(_buyer, buyer);
    }

    /// @dev ✅ Test 4: Should emit ProductPurchased event after a product is bought
    function test_BuyProduct_EmitsEvent() public {
        vm.prank(seller);
        marketplace.addProduct("Laptop", 2 ether, "A gaming laptop", "image-url");

        vm.prank(buyer);
        vm.expectEmit(true, true, false, true);
        emit DecentralizedMarketPlace.ProductPurchased(0, "Laptop", buyer, 2 ether, block.timestamp);

        marketplace.buyProduct{value: 2 ether}(0);
    }

    /// @dev ✅ Test 5: Should prevent buying a non-existent product
    function test_BuyNonExistentProduct() public {
        vm.prank(buyer);
        vm.expectRevert("Invalid product ID");
        marketplace.buyProduct{value: 2 ether}(1); // No product exists yet
    }

    /// @dev ✅ Test 6: Should prevent double purchase of a product
    function test_CannotBuyTwice() public {
        vm.prank(seller);
        marketplace.addProduct("Laptop", 2 ether, "A gaming laptop", "image-url");

        vm.prank(buyer);
        marketplace.buyProduct{value: 2 ether}(0);

        vm.prank(anotherBuyer); // Another buyer tries to purchase the same product
        vm.expectRevert("Product already sold");
        marketplace.buyProduct{value: 2 ether}(0);
    }

    /// @dev ✅ Test 7: Ensure correct Ether transfer to seller
    function test_EtherTransfer() public {
        vm.prank(seller);
        marketplace.addProduct("Laptop", 2 ether, "A gaming laptop", "image-url");

        uint sellerBalanceBefore = seller.balance;

        vm.prank(buyer);
        marketplace.buyProduct{value: 2 ether}(0);

        uint sellerBalanceAfter = seller.balance;

        assertEq(sellerBalanceAfter, sellerBalanceBefore + 2 ether); // Seller should receive funds
    }
}

