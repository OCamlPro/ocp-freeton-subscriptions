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
import "../interfaces/ISubscription.sol";
import "../interfaces/IMultisig.sol";
import "SubscriptionDebot.sol";
import "../Constants.sol";

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

contract SubscriptionManagerDebot is Debot, Constants {

    string constant debot_name = "Subscription Manager Debot" ;
    string constant debot_publisher = "OCamlPro" ;
    string constant debot_caption = "Subscription Manager Debot" ;
    string constant debot_author = "OCamlPro" ;
    string constant debot_language = "en" ;
    address constant debot_support = address(0); // TODO

    string constant debot_hello =
        "Hi, I will help you work with Service Manager contracts";

    bytes m_icon;

    address g_contract;
    address g_user;
    uint256 g_user_pubkey;
    address g_subscription_debot;
    address g_root_debot;
    string g_descr;

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
        m_icon = icon;
    }

    function setSubscriptionDebot(address debot) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        g_subscription_debot = debot;
    }

    function setRootDebot(address debot) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        g_root_debot = debot;
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
            "Enter the address of the service"
        );
    }

    function setManager(address value) public {
        g_contract = value;
        ISubscriptionManager(value).getDescription{
            extMsg:true,
            time:uint64(now),
            expire:0,
            sign:false,
            callbackId:tvm.functionId(onGetDescription),
            onErrorId:0,
            abiVer:2
        }();
    }

    function onGetDescription(string description) public {
        g_descr = description;
        mainMenu();
    }

    function onDebotStart(address submanager, address user, uint256 pubkey, string descr) public {
        g_contract = submanager;
        g_user = user;
        g_user_pubkey = pubkey;
        g_descr = descr;
        mainMenu();
    }


    function mainMenu () public {
        Terminal.print(0, format("Hello and welcome to the \"{}\" Service!", g_descr));
        Terminal.print(0, "Please select an action.");
        Terminal.print(0, "1. Subscribe/Manage my subscription");
        Terminal.print(0, "2. Claim the subscription fees (owner only)");
        Terminal.print(0, "9. Change Service Manager");
        Terminal.print(0, "0. Back");
        Terminal.input(tvm.functionId(setUserMainAction), "Action: ", false);
    }

    function setUserMainAction(string value) public {
        if (value == "1"){
            _handleSubscription();
        } else if (value == "2") {
            _handleClaim();
        } else if (value == "9") {
            _selectManager();
        } else if (value == "0") {
            IMainMenu(g_root_debot).mainMenu();
        } else {
            Terminal.print(0, format("You have entered \"{}\", which is an invalid action.", value));
            mainMenu();
        }
    }

    function _handleSubscription() internal view {

        TvmCell payload = 
            tvm.encodeBody(
                ISubscriptionManager.subscribe,
                g_user
            );
        IMultisig(g_user).sendTransaction {
            extMsg:true,
            time:uint64(now),
            expire:0,
            sign:true,
            pubkey:(g_user_pubkey),
            callbackId:(tvm.functionId(onSubscription)),
            onErrorId:tvm.functionId(onErrorRestart),
            abiVer:2
        }(g_contract, 1 ton, true, 0, payload);
    }

    function _getSubscription() internal {
        ISubscriptionManager(g_contract).getSubscription {
            extMsg:true,
            time:uint64(now),
            expire:0,
            sign:false,
            callbackId:tvm.functionId(onSubscriptionSuccess),
            onErrorId:0,
            abiVer:2
        }(g_user);
    }

    function onSubscription() public {
        Terminal.print(0, "You have successfully been subscribed!");
        _getSubscription();
    }

    function onSubscriptionSuccess(address value) public {
        Terminal.print(0, format("Subscription address: {}", value));
        SubscriptionDebot(g_subscription_debot).onDebotStart(
            value, 
            g_user, 
            g_user_pubkey
        );
    }

    function _handleClaim() internal view {

        TvmCell payload = 
            tvm.encodeBody(
                ISubscriptionManager.claimSubscriptions
            );
        IMultisig(g_user).sendTransaction {
            extMsg:true,
            time:uint64(now),
            expire:0,
            sign:true,
            pubkey:(g_user_pubkey),
            callbackId:(tvm.functionId(onClaimSuccess)),
            onErrorId:tvm.functionId(onErrorRestart),
            abiVer:2
        }(g_contract, 1 ton, true, 0, payload);
    }

    function onClaimSuccess() public {
        Terminal.print(0, format("Claim success!"));
        mainMenu();
    }

    function onErrorRestart(uint32 sdkError, uint32 exitCode) public {
        if (exitCode == E_ALREADY_SUBSCRIBED) {
            Terminal.print(0, "You already have a subscription!");
            _getSubscription();
        } else {
            Terminal.print(0, format("Error: sdkError:{} exitCode:{}", sdkError, exitCode));
            mainMenu();
        }
    }

}