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

import "../interfaces/ISubscription.sol";
import "../interfaces/IMultisig.sol";

contract SubscriptionDebot is Debot {
    
    string constant debot_name = "Subscription Debot" ;
    string constant debot_publisher = "OCamlPro" ;
    string constant debot_caption = "Subscription Debot" ;
    string constant debot_author = "OCamlPro" ;
    string constant debot_language = "en" ;
    address constant debot_support = address(0); // TODO

    string constant debot_hello =
        "Hi, I will help you work with Subscription contracts";

    bytes m_icon;

    address g_contract;
    address g_user;
    uint256 g_user_pubkey;

    function setIcon(bytes icon) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_icon = icon;
    }

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string caption, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = debot_name;
        version = "0.0.1";
        publisher = debot_publisher;
        caption = debot_caption;
        author = debot_author;
        support = debot_support;
        hello = debot_hello;
        language = debot_language;
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function getRequiredInterfaces() public view override
      returns (uint256[] interfaces) {
      return [
            Terminal.ID,
            AmountInput.ID,
            ConfirmInput.ID,
            AddressInput.ID,
            Menu.ID ];
    }

    function setUserInput(string value) public {
        // TODO: continue DeBot logic here...
        Terminal.print(0, format("You have entered \"{}\"", value));
    }


    
    function start() public override {
        AddressInput.get(tvm.functionId(setWallet),
            "Enter your wallet address"
        );
    }

    function _getCustodians(uint32 callback, address multisig) internal pure {
        optional(uint256) nopubkey;
        IMultisig(multisig).getCustodians {
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey:nopubkey,
            time: uint64(now),
            expire: 0,
            callbackId: callback,
            onErrorId: tvm.functionId(onErrorRestart)
        }();
    }

    function setWallet(address value) public {
        g_user = value;
        _getCustodians(tvm.functionId(loadPubkey), value);
    }

    function loadPubkey(CustodianInfo[] custodians) public {
        if (custodians.length != 1) {
            Terminal.print(0, "Can manage services only if 1 custodian on multisig");
            start();
        } else {
            g_user_pubkey = custodians[0].pubkey;
            _selectManager();
        }
    }
 
    function _selectManager() internal {
        AddressInput.get(tvm.functionId(setManager),
            "Enter the address of the subscription you want to manage"
        );
    }

    function setManager(address value) public {
        g_contract = value;
        mainMenu();
    }

    function onDebotStart(address subscription, address user, uint256 pubkey) public {
        g_contract = subscription;
        g_user = user;
        g_user_pubkey = pubkey;
        mainMenu();
    }

    function mainMenu() public {
        Terminal.print(0, "Hello and welcome to your Subscription.");
        Terminal.print(0, "Please select an action.");
        Terminal.print(0, "1. When does my subscription ends?");
        Terminal.print(0, "2. How much funds left on my account?");
        Terminal.print(0, "3. How much funds locked on my account?");
        Terminal.print(0, "4. I want to refill my account.");
        Terminal.print(0, "5. I want to cancel my subscription.");
        Terminal.input(tvm.functionId(setUserMainAction), "Action: ", false);
    }

    function setUserMainAction(string value) public {
        if (value == "1"){
            _handleSubscriptionEnd();
        } else if (value == "2") {
            _handleBalance();
        } else if (value == "3") {
            _handleLockedBalance();
        } else if (value == "4") {
            _handleRefillAccount();
        } else if (value == "5") {
            _handleCancel();
        } else {
            Terminal.print(0, format("You have entered \"{}\", which is an invalid action.", value));
            mainMenu();
        }
    }

    function _handleSubscriptionEnd() view internal{
        ISubscription(g_contract).subscribedUntil{
            extMsg:true,
            time:uint64(now),
            expire:0,
            sign:false,
            callbackId:tvm.functionId(onSuccessSubscriptionEnd),
            onErrorId:tvm.functionId(onErrorRestart),
            abiVer:2
        }();
    }

    function onSuccessSubscriptionEnd(uint128 end) public{
        Terminal.print(0, format("Your subscription ends at \"{}\"",end));
        mainMenu();
    }

    function _handleBalance() view internal {
        ISubscription(g_contract).availableFunds{
            extMsg:true,
            time:uint64(now),
            expire:0,
            sign:false,
            callbackId:tvm.functionId(onSuccessSubscriptionEnd),
            onErrorId:tvm.functionId(onErrorRestart),
            abiVer:2
        }();
    }

    function onSuccessGetBalance(uint128 available) public {
        Terminal.print(0, format("There are {} nanotons left on your account", available));
        mainMenu();
    }


    function _handleLockedBalance() view internal {
        ISubscription(g_contract).lockedFunds{
            extMsg:true,
            time:uint64(now),
            expire:0,
            sign:false,
            callbackId:tvm.functionId(onSuccessGetLockedBalance),
            onErrorId:tvm.functionId(onErrorRestart),
            abiVer:2
        }();
    }

    function onSuccessGetLockedBalance(uint128 locked) public {
        Terminal.print(0, format("There are {} nanotons locked on your account", locked));
        mainMenu();
    }

    function _handleRefillAccount() internal {
        Terminal.print(0, "Please enter the auction address. TODO");
        //Terminal.input(tvm.functionId(setUserManage), "Action: ", false);
    }

    function _handleCancel() internal view {
        ISubscription(g_contract).cancelSubscription{
            extMsg:true,
            time:uint64(now),
            expire:0,
            sign:true,
            callbackId:tvm.functionId(this.onSuccessCancel),
            onErrorId:0,
            abiVer:2
        }();
    }

    function onSuccessCancel() external {
        Terminal.print(0, format("Your unused funds have been refunded."));
        mainMenu();
    }

    function onErrorRestart(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Error: sdkError:{} exitCode:{}", sdkError, exitCode));
        mainMenu();
    }

    fallback() external {
        Terminal.print(0, "Error! Going back to main menu");
        mainMenu();
    }

}
