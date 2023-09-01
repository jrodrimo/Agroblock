// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CoffeeSupplyChain {

    enum State {
        Farmed,       // 0
        Processed,    // 1
        Distributed,  // 2
        Sold          // 3
    }

    struct Coffee {
        address owner;     // Owner of this coffee batch
        State state;       // Current state in supply chain
        string description; // Additional details about the coffee, e.g., origin, roast type
    }

    mapping(uint256 => Coffee) public coffeeMapping;  // Mapping from coffee batch ID to its details
    uint256 public coffeeCounter = 0;                 // To create unique IDs for coffee batches

    // Events to notify clients
    event Farmed(uint256 coffeeId);
    event Processed(uint256 coffeeId);
    event Distributed(uint256 coffeeId);
    event Sold(uint256 coffeeId);

    // Farm a new batch
    function farmCoffee(string memory _description) public {
        coffeeCounter++;
        coffeeMapping[coffeeCounter] = Coffee({
            owner: msg.sender,
            state: State.Farmed,
            description: _description
        });

        emit Farmed(coffeeCounter);
    }

    // Process a batch
    function processCoffee(uint256 _coffeeId) public {
        Coffee storage coffee = coffeeMapping[_coffeeId];
        require(msg.sender == coffee.owner, "Not the owner of this coffee batch");
        require(coffee.state == State.Farmed, "Coffee is not in Farmed state");

        coffee.state = State.Processed;

        emit Processed(_coffeeId);
    }

    // Distribute a batch to a retailer
    function distributeCoffee(uint256 _coffeeId, address _retailer) public {
        Coffee storage coffee = coffeeMapping[_coffeeId];
        require(msg.sender == coffee.owner, "Not the owner of this coffee batch");
        require(coffee.state == State.Processed, "Coffee is not in Processed state");

        coffee.state = State.Distributed;
        coffee.owner = _retailer;

        emit Distributed(_coffeeId);
    }

    // Retailer sells the coffee
    function sellCoffee(uint256 _coffeeId) public {
        Coffee storage coffee = coffeeMapping[_coffeeId];
        require(msg.sender == coffee.owner, "Not the owner of this coffee batch");
        require(coffee.state == State.Distributed, "Coffee is not in Distributed state");

        coffee.state = State.Sold;

        emit Sold(_coffeeId);
    }

    // Fetch the current state of a batch
    function getCoffeeState(uint256 _coffeeId) public view returns (State) {
        return coffeeMapping[_coffeeId].state;
    }
}
