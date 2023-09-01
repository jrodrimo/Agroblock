// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MineralSupplyChain {

    enum State {
        Extracted,      // 0
        Processed,      // 1
        Distributed,    // 2
        Sold            // 3
    }

    struct MineralBatch {
        address owner;              // Owner of this mineral batch
        State state;                // Current state in the supply chain
        uint256 totalWorkerSalaries;  // Total salaries paid to workers for this batch
    }

    struct WorkerSalary {
        uint256 batchId;             // Associated mineral batch ID
        uint256 amount;              // Amount paid
        // Note: For privacy, we aren't storing worker identity here
    }

    mapping(uint256 => MineralBatch) public batchMapping;  // Mapping from batch ID to its details
    uint256 public batchCounter = 0;                       // To create unique IDs for mineral batches

    WorkerSalary[] public salaries;  // All salaries paid in the system

    // Events to notify clients
    event Extracted(uint256 batchId);
    event Processed(uint256 batchId);
    event Distributed(uint256 batchId);
    event Sold(uint256 batchId);
    event SalaryPaid(uint256 batchId, uint256 amount);

    // Extract a new batch
    function extractMineral(uint256 _totalWorkerSalaries) public {
        batchCounter++;
        batchMapping[batchCounter] = MineralBatch({
            owner: msg.sender,
            state: State.Extracted,
            totalWorkerSalaries: _totalWorkerSalaries
        });

        emit Extracted(batchCounter);
    }

    function paySalary(uint256 _batchId, uint256 _amount) public {
        MineralBatch storage batch = batchMapping[_batchId];
        require(msg.sender == batch.owner, "Not the owner of this mineral batch");
        require(batch.state == State.Extracted, "Can only pay during the Extraction phase");
        
        salaries.push(WorkerSalary({
            batchId: _batchId,
            amount: _amount
        }));
        
        batch.totalWorkerSalaries += _amount;
        emit SalaryPaid(_batchId, _amount);
    }

    // Process a batch
    function processMineral(uint256 _batchId) public {
        MineralBatch storage batch = batchMapping[_batchId];
        require(msg.sender == batch.owner, "Not the owner of this mineral batch");
        require(batch.state == State.Extracted, "Mineral is not in Extracted state");

        batch.state = State.Processed;

        emit Processed(_batchId);
    }

    // Distribute a batch to a vendor or next entity in chain
    function distributeMineral(uint256 _batchId, address _to) public {
        MineralBatch storage batch = batchMapping[_batchId];
        require(msg.sender == batch.owner, "Not the owner of this mineral batch");
        require(batch.state == State.Processed, "Mineral is not in Processed state");

        batch.state = State.Distributed;
        batch.owner = _to;

        emit Distributed(_batchId);
    }

    // Vendor sells the mineral batch
    function sellMineral(uint256 _batchId) public {
        MineralBatch storage batch = batchMapping[_batchId];
        require(msg.sender == batch.owner, "Not the owner of this mineral batch");
        require(batch.state == State.Distributed, "Mineral is not in Distributed state");

        batch.state = State.Sold;

        emit Sold(_batchId);
    }

    // Get total salaries for a specific batch
    function getTotalSalariesForBatch(uint256 _batchId) public view returns (uint256) {
        return batchMapping[_batchId].totalWorkerSalaries;
    }
}
