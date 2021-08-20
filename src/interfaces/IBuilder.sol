pragma ton-solidity >=0.44;

interface IBuilder {

    function init() external view;

    function updateCode(TvmCell c) external;

}