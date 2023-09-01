// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WaterCategorization {

    enum Category {
        Polluted,          // 0
        SlightlyPolluted,  // 1
        ModeratelyClean,   // 2
        Clean              // 3
    }

    struct WaterBatch {
        address owner;
        uint256 totalVolume;   // Total volume in liters
        uint256 cleanVolume;   // Clean volume in liters
        Category category;
    }

    mapping(uint256 => WaterBatch) public waterMapping;  // Mapping from water batch ID to its details
    uint256 public waterCounter = 0;                     // To create unique IDs for water batches

    event WaterCategorized(uint256 waterId, Category category);

    function addWaterBatch(uint256 _totalVolume, uint256 _cleanVolume) public {
        require(_cleanVolume <= _totalVolume, "Clean volume cannot exceed total volume");

        Category category = classifyWater(_cleanVolume, _totalVolume);
        
        waterCounter++;
        waterMapping[waterCounter] = WaterBatch({
            owner: msg.sender,
            totalVolume: _totalVolume,
            cleanVolume: _cleanVolume,
            category: category
        });

        emit WaterCategorized(waterCounter, category);
    }

    function classifyWater(uint256 _cleanVolume, uint256 _totalVolume) internal pure returns (Category) {
        uint256 percentage = (_cleanVolume * 100) / _totalVolume;

        if (percentage < 20) {
            return Category.Polluted;
        } else if (percentage < 50) {
            return Category.SlightlyPolluted;
        } else if (percentage < 80) {
            return Category.ModeratelyClean;
        } else {
            return Category.Clean;
        }
    }

    function getWaterBatchDetails(uint256 _waterId) public view returns (WaterBatch memory) {
        return waterMapping[_waterId];
    }
}
