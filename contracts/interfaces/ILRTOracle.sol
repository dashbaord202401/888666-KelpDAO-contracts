// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.21;

interface ILRTOracle {
    // events
    event UpdatedLRTConfig(address indexed _lrtConfig);

    // methods
    function assetER(address asset) external view returns (uint256);
}
