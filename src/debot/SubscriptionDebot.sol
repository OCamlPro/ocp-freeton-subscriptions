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

contract SubscriptionDebot is Debot, Upgradable, Transferable, Utility {

  string constant debot_name = "Subscription Debot" ;
  string constant debot_publisher = "OCamlPro" ;
  string constant debot_caption = "Subscription Debot" ;
  string constant debot_author = "Steven de Oliveira" ;
  string constant debot_language = "en" ;
  // your address with 0x instead of 0:
  uint8 constant debot_version_major = 1 ;
  uint8 constant debot_version_minor = 0 ;
  uint8 constant debot_version_fix = 0 ;
  uint256 constant debot_support =
    0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f ;

  string constant debot_hello =
    "Hi, I will help you work with Subscription contracts";

  bytes debot_icon;

  address g_contract ;

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

  function getDebotInfo() public functionID(0xDEB) view override returns(
        string name, string version, string publisher, string caption, string author,
        address support, string hello, string language, string dabi, bytes icon){
          return (debot_name, "0", debot_publisher, debot_caption,
          debot_author, address(debot_support), debot_hello, 
          debot_language, "?",bytes(""));
  }

  /// @notice Entry point function for DeBot.
  function start() public override {
    AddressInput.get(tvm.functionId(onStart),
      "Which subscription do you want to work with?");
  }

  function onStart(address subs) public {
    g_contract = subs;
    Terminal.print(0, "Hello and welcome to your Subscription.");
    Terminal.print(0, "Please select an action.");
    Terminal.print(0, "1. When does my subscription ends?");
    Terminal.print(0, "2. I want to refill my account.");
    Terminal.print(0, "3. I want to cancel my subscription.");
    Terminal.input(tvm.functionId(setUserMainAction), "Action: ", false);
  }

  function setUserMainAction(string value) public {
    if (value == "1"){
      _handleSubscriptionEnd();
    } else if (value == "2") {
      _handleRefillAccount();
    } else if (value == "3") {
      _handleCancel();
    } else {
      Terminal.print(0, format("You have entered \"{}\", which is an invalid action.", value));
    }
  }

  function _handleSubscriptionEnd() view internal{
    ISubscription(g_contract).subscribedUntil{
        extMsg:true,
        time:uint64(now),
        expire:0,
        sign:false,
        callbackId:tvm.functionId(this.onSuccessSubscriptionEnd),
        onErrorId:0,
        abiVer:2
      }();
  }

  function onSuccessSubscriptionEnd(uint128 end) external{
    Terminal.print(0, format("Your subscription ends at \"{}\"",end));
  }

  function _handleRefillAccount() internal {
    Terminal.print(0, "Please enter the auction address. TODO");
    //Terminal.input(tvm.functionId(setUserManage), "Action: ", false);
  }

  function _handleCancel() internal {
    Terminal.print(0, "Please enter the auction address. TODO");
    // Terminal.input(tvm.functionId(setUserParticipate), "Action: ", false);
  }

}