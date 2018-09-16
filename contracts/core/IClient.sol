pragma solidity ^0.4.24;

interface IClient {
    function onVerdict(uint id, uint8 verdict, uint8 majorityPercent, uint totalWeight, uint verdictWeight) external;
}