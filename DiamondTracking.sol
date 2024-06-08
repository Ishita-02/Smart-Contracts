// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract DiamondLedger {

    uint[] private diamondWeights;

    function importDiamonds(uint[] memory weights) public {
        for (uint i = 0; i < weights.length; i++) {
            require(weights[i] >= 0 && weights[i] <= 1000, "Weight out of range");
        }
        for (uint i = 0; i < weights.length; i++) {
            diamondWeights.push(weights[i]);
        }
    }

    function availableDiamonds(uint weight, uint allowance) public view returns (uint) {
        uint count = 0;
        for (uint i = 0; i < diamondWeights.length; i++) {
            if (diamondWeights[i] >= weight - allowance && diamondWeights[i] <= weight + allowance) {
                count++;
            }
        }
        return count;
    }

}
