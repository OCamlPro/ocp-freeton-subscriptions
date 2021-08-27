pragma ton-solidity >=0.35.0;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "lib/Debot.sol";
import "lib/Terminal.sol";
import "lib/AddressInput.sol";
import "lib/AmountInput.sol";
import "lib/ConfirmInput.sol";
import "lib/Sdk.sol";
import "lib/Menu.sol";
import "lib/Upgradable.sol";
import "lib/Transferable.sol";

import "../interfaces/ISubscriptionManager.sol";

// Interface of the contract with which to interact

interface IContract {
    function setter ( uint256 x ) external ;
    function getter () external returns ( uint256 y ) ;
}

abstract contract Utility {

    function tonsToStr(uint128 nanotons) internal pure returns (string) {
        (uint64 dec, uint64 float) = _tokens(nanotons);
        string floatStr = format("{}", float);
        while (floatStr.byteLength() < 9) {
        floatStr = "0" + floatStr;
        }
        return format("{}.{}", dec, floatStr);
    }

    function _tokens(uint128 nanotokens) internal pure
        returns (uint64, uint64) {
        uint64 decimal = uint64(nanotokens / 1e9);
        uint64 float = uint64(nanotokens - (decimal * 1e9));
        return (decimal, float);
    }
    }

    contract RootDebot is Debot, Upgradable, Transferable, Utility {

    string constant debot_name = "Subscription Manager Debot" ;
    string constant debot_publisher = "OCamlPro" ;
    string constant debot_caption = "Root Subscription Manager Debot" ;
    string constant debot_author = "Steven de Oliveira" ;
    string constant debot_language = "en" ;
    // your address with 0x instead of 0:
    uint8 constant debot_version_major = 1 ;
    uint8 constant debot_version_minor = 0 ;
    uint8 constant debot_version_fix = 0 ;
    uint256 constant debot_support =
        0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f ;

    string constant debot_hello =
        "Hi, I will help you work with the Root Subscription Manager contract";

    bytes debot_icon;

    address g_contract;

    address g_wallet;
    address g_root_token; // For TIP3
    uint128 g_duration;
    uint128 g_amount;

    function getRequiredInterfaces() public view override
        returns (uint256[] interfaces) {
        return [
                Terminal.ID,
                AmountInput.ID,
                ConfirmInput.ID,
                AddressInput.ID,
                Menu.ID ];
    }

    function setIcon(bytes icon) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        debot_icon = icon;
    }

    function onCodeUpgrade() internal override{}

    function setContract(address root){
        require(tvm.pubkey() == msg.pubkey, 101);
        tvm.accept();
        g_contract = root;
    }

    function getDebotInfo() public functionID(0xDEB) view override returns(
            string name, string version, string publisher, string caption, string author,
            address support, string hello, string language, string dabi, bytes icon){
            return (debot_name, "0", debot_publisher, debot_caption,
            debot_author, address(debot_support), debot_hello, 
            debot_language, "?",bytes(""));
    }

    function start () public {
        g_wallet = address(0);
        g_root_token = address(0);
        g_duration = 0;
        g_amount = 0;
        Terminal.print(0, "Hello and welcome to the Service Deployer.");
        Terminal.print(0, "You can here deploy new services.");
        Terminal.print(0, "1. Service payable with TON crystals");
        Terminal.print(0, "2. Service payable with a TIP3 token (NOT RELEASED YET)");
        Terminal.input(tvm.functionId(setUserMainAction), "Action: ", false);
    }

    function setUserMainAction(string value) public {
        if (value == "1"){
            _selectWallet();
        } else if (value == "2") {
            _selectRootContract();
        } else {
            Terminal.print(0, format("You have entered \"{}\", which is an invalid action.", value));
            mainMenu();
        }
    }

    function _selectRootContract() internal {
        AddressInput.get(tvm.functionId(setRootContract),
            "Enter the TIP3 root contract address"
        );
    }

    function setRootContract(address root) external {
        g_root_token = root;
        _selectWallet();
    }

    function _selectWallet() external {
        AddressInput.get(tvm.functionId(setWallet),
            "Enter your wallet address"
        );
    }

    function setWallet(address wallet) external {
        g_wallet = wallet;
        AmountInput(tvm.functionId(setDuration),
            "What is the subscription duration of your service?"
        );
    }

    function setDuration(uint128 duration) external {
        g_duration = duration;
        AmountInput(tvm.functionId(setDuration),
            "What is the subscription amount?"
        );
    }

    function setAmount(uint amount) external {
        g_amount = amount;
        check();
    }

    function check(){
        if (g_root_token == 0) {
            Terminal.print(0, "You are about to deploy a new service with parameters:");
            Terminal.print(0, format("Wallet: \"{}\"", g_wallet));
            Terminal.print(0, format("Duration of subscription: \"{}\"", g_duration));
            Terminal.print(0, format("Amount: \"{}\"", g_amount));
            ConfirmInput.get(tvm.functionId(onCheck()),"Are you sure?");
    }

    function onCheck(bool ok){
        if (ok) {
                RecurringPaymentsRoot(g_contract).deployService{
                extMsg:true,
                time:uint64(now),
                expire:0,
                sign:false,
                callbackId:0, // TODO: Get Deployed Service address!
                onErrorId:0,
                abiVer:2
            }(
                g_wallet,
                PaymentPlan(
                    g_amount,
                    g_period,
                    g_root_token
                )
            );
        } else {
            start();
        }
    }


}