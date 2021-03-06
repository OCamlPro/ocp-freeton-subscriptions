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
import "../Constants.sol";

import "IMainMenu.sol";

contract SubscriptionDebot is Debot, Constants {
    
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
    uint128 g_refill;

    address g_manager_debot;

    function setIcon(bytes icon) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_icon = icon;
    }

    function setManagerDebot(address debot) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        g_manager_debot = debot;
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
        Terminal.print(0, format("Hello and welcome to your Subscription.({})", g_contract));
        Terminal.print(0, "Please select an action.");
        Terminal.print(0, "1. When does my subscription end?");
        Terminal.print(0, "2. How much funds left on my account?");
        Terminal.print(0, "3. How much funds locked on my account?");
        Terminal.print(0, "4. I want to refill my account.");
        Terminal.print(0, "5. I want to cancel/pause my subscription.");
        Terminal.print(0, "0. Back to Manager");
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
        } else if (value == "0") {
            IMainMenu(g_manager_debot).mainMenu();
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
        int256 duration = int256(end) - int256(now);
        if (duration < 0){
            Terminal.print(0,format("Your subscription expired!"));
        } else {
            Terminal.print(0, format("Your subscription ends in {} seconds", duration));
        }
        mainMenu();
    }

    function _handleBalance() view internal {
        ISubscription(g_contract).availableFunds{
            extMsg:true,
            time:uint64(now),
            expire:0,
            sign:false,
            callbackId:tvm.functionId(onSuccessGetBalance),
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
        AmountInput.get(tvm.functionId(setRefill),
            "How much funds (in nanotons) do you want to deposit on your account?",
            0,
            0.015 ton,
            MAX_INT128
        );
    }

    function setRefill(uint value) public {
        TvmCell payload = 
            tvm.encodeBody(
                ISubscription.refillAccount,
                0.015 ton
            );
        IMultisig(g_user).sendTransaction {
            extMsg:true,
            time:uint64(now),
            expire:0,
            sign:true,
            pubkey:(g_user_pubkey),
            callbackId:(tvm.functionId(onRefill)),
            onErrorId:tvm.functionId(onErrorRestart),
            abiVer:2
        }(g_contract, uint128(value) + 0.01 ton, true, 0, payload);
    }

    function onRefill() public{
        Terminal.print(0,"Refill complete!");
        mainMenu();
    }

    function _handleCancel() internal view {
        TvmCell payload = 
            tvm.encodeBody(
                ISubscription.cancelSubscription
            );
        IMultisig(g_user).sendTransaction {
            extMsg:true,
            time:uint64(now),
            expire:0,
            sign:true,
            pubkey:(g_user_pubkey),
            callbackId:(tvm.functionId(onRefill)),
            onErrorId:tvm.functionId(onErrorRestart),
            abiVer:2
        }(g_contract, 0.3 ton, true, 0, payload);
    }

    function onSuccessCancel() external {
        Terminal.print(0, format("Your unused funds have been refunded."));
        mainMenu();
    }

    function onErrorRestart(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Error: sdkError:{} exitCode:{}", sdkError, exitCode));
        mainMenu();
    }

    function _handleBack() internal {
        
    }

    fallback() external {
        Terminal.print(0, "Error! Going back to main menu");
        mainMenu();
    }

}
