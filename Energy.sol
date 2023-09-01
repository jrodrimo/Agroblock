// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EnergyCategorization {

    enum Category {
        NonRenewable,   // 0
        LowRenewable,   // 1
        MediumRenewable,// 2
        HighRenewable   // 3
    }

    struct Energy {
        address owner;
        uint256 totalUnits;   // Total energy units in MWh
        uint256 renewableUnits; // Renewable energy units in MWh
        Category category;
    }

    mapping(uint256 => Energy) public energyMapping;  // Mapping from energy ID to its details
    uint256 public energyCounter = 0;                 // To create unique IDs for energy batches

    event EnergyCategorized(uint256 energyId, Category category);

    function addEnergy(uint256 _totalUnits, uint256 _renewableUnits) public {
        require(_renewableUnits <= _totalUnits, "Renewable units cannot exceed total units");

        Category category = classifyEnergy(_renewableUnits, _totalUnits);
        
        energyCounter++;
        energyMapping[energyCounter] = Energy({
            owner: msg.sender,
            totalUnits: _totalUnits,
            renewableUnits: _renewableUnits,
            category: category
        });

        emit EnergyCategorized(energyCounter, category);
    }

    function classifyEnergy(uint256 _renewable, uint256 _total) internal pure returns (Category) {
        uint256 percentage = (_renewable * 100) / _total;

        if (percentage < 20) {
            return Category.NonRenewable;
        } else if (percentage < 50) {
            return Category.LowRenewable;
        } else if (percentage < 80) {
            return Category.MediumRenewable;
        } else {
            return Category.HighRenewable;
        }
    }

    function getEnergyDetails(uint256 _energyId) public view returns (Energy memory) {
        return energyMapping[_energyId];
    }
}
