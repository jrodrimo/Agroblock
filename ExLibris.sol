// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ExLibrisRegistry {

    struct Book {
        string title;
        address currentOwner;
        address[] ownershipHistory;
    }

    mapping(uint256 => Book) public books; // Map book ID to its details
    uint256 public bookCounter = 0;

    event BookRegistered(uint256 bookId, string title, address owner);
    event OwnershipTransferred(uint256 bookId, address previousOwner, address newOwner);

    // Register a new book
    function registerBook(string memory _title) public {
        bookCounter++;

        // Initialize the ownership history with the current owner
        address[] memory initialHistory = new address[](1);
        initialHistory[0] = msg.sender;

        books[bookCounter] = Book({
            title: _title,
            currentOwner: msg.sender,
            ownershipHistory: initialHistory
        });

        emit BookRegistered(bookCounter, _title, msg.sender);
    }

    // Transfer book ownership
    function transferOwnership(uint256 _bookId, address _newOwner) public {
        require(books[_bookId].currentOwner == msg.sender, "Only the current owner can transfer ownership");

        books[_bookId].ownershipHistory.push(_newOwner);
        books[_bookId].currentOwner = _newOwner;

        emit OwnershipTransferred(_bookId, msg.sender, _newOwner);
    }

    // View the ex libris (ownership history) of a book
    function getExLibris(uint256 _bookId) public view returns (address[] memory) {
        return books[_bookId].ownershipHistory;
    }

}
