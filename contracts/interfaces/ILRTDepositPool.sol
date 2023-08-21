// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.12;

interface ILRTDepositPool {
    //errors
    error AssetNotSupported();
    error TokenTransferFailed();
    error NotEnoughAssetToDeposit();
    error NotEnoughAssetToTransfer();
    error MaximumDepositLimitReached();
    error MaximumCountOfNodeDelegatorReached();

    //events
    event UpdatedLRTConfig(address lrtConfig);
    event MaxNodeDelegatorCountUpdated(uint16 maxNodeDelegatorCount);
    event AddedNodeDelegator(address nodeDelegatorContract);
    event DepositedAsset(
        address asset,
        uint256 amountOfAsset,
        uint256 amountToSend
    );

    function addNodeDelegatorContract(
        address[] calldata _nodeDelegatorContract
    ) external;

    function depositAsset(address _asset, uint256 _amount) external;

    function transferAssetToNodeDelegator(
        uint16 _ndcIndex,
        address _asset,
        uint256 _amount
    ) external;

    function updateMaxNodeDelegatorCount(
        uint16 _maxNodeDelegatorCount
    ) external;

    function updateLRTConfig(address _lrtConfig) external;

    function getNodeDelegatorQueue() external view returns (address[] memory);

    function getTotalAssetsWithEigenLayer(
        address _asset
    ) external view returns (uint256);
}
