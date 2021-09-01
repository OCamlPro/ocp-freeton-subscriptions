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
import "SubscriptionDebot.sol";

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

    contract SubscriptionManagerDebot is Debot, Upgradable, Transferable, Utility {

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
    address g_subscriber;
    address g_subscription_debot;

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

    function onCodeUpgrade() internal override{}

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

    /// @notice Entry point function for DeBot.
    function start() public override {
        AddressInput.get(tvm.functionId(onStart),
        "Which service do you want to work with?");
    }

    function onStart(address subman) public {
        g_contract = subman;
        mainMenu();
    } 

    function mainMenu () public {
        Terminal.print(0, "Hello and welcome to the Service Manager.");
        Terminal.print(0, "Please select an action.");
        Terminal.print(0, "1. Subscribe");
        Terminal.print(0, "2. Claim the subscription fees (owner only)");
        Terminal.input(tvm.functionId(setUserMainAction), "Action: ", false);
    }

    function setUserMainAction(string value) public {
        if (value == "1"){
            _handleSubscription();
        } else if (value == "2") {
            _handleClaim();
        } else {
            Terminal.print(0, format("You have entered \"{}\", which is an invalid action.", value));
            mainMenu();
        }
    }

    function _handleSubscription() internal {
        AddressInput.get(
            tvm.functionId(onSubscriptionAddress),
            "Enter your address, it will be your subscription identifier."
        );
    }

    function onSubscriptionAddress(address value) public {
        g_subscriber = value;
        ISubscriptionManager(g_contract).subscribe{
            extMsg:true,
            time:uint64(now),
            expire:0,
            sign:false,
            callbackId:tvm.functionId(this.onSubscription),
            onErrorId:0,
            abiVer:2
        }(value);
    }

    function onSubscription() public {
        Terminal.print(0, "You have successfully been subscribed!");
        ISubscriptionManager(g_contract).getSubscription{
            extMsg:true,
            time:uint64(now),
            expire:0,
            sign:false,
            callbackId:tvm.functionId(onSubscriptionSuccess),
            onErrorId:0,
            abiVer:2
        }(g_subscriber);
    }

    function onSubscriptionSuccess(address value) public view {
        SubscriptionDebot(g_subscription_debot).onStart(value);
    }

    function _handleClaim() internal view {
        ISubscriptionManager(g_contract).claimSubscriptions();
    }

}