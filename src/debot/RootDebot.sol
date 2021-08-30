pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
// import required DeBot interfaces and basic DeBot contract.
import "lib/Debot.sol";
import "lib/Terminal.sol";
import "lib/AddressInput.sol";
import "lib/AmountInput.sol";
import "lib/ConfirmInput.sol";
import "../Constants.sol";
import "../interfaces/IRecurringPaymentsRoot.sol";

contract RootDebot is Debot, Constants {
    string constant debot_name = "Root Subscription Manager Debot" ;
    string constant debot_publisher = "OCamlPro" ;
    string constant debot_caption = "Root Subscription Manager Debot" ;
    string constant debot_author = "OCamlPro" ;
    string constant debot_language = "en" ;
    // your address with 0x instead of 0:
    address constant debot_support = address(0) ; //TODO

    string constant debot_hello =
        "Hi, I will help you work with the Root Subscription Manager contract";

    bytes m_icon;

    address g_subscription_manager_debot;
    address g_subscription_debot;

    address g_contract;

    address g_wallet;
    address g_root_token; // For TIP3
    uint64 g_duration;
    uint128 g_amount;

    function setIcon(bytes icon) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_icon = icon;
    }

    function setSubManagerDebot(address debot) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        g_subscription_manager_debot = debot;
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

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID ];
    }

    function setUserInput(string value) public {
        // TODO: continue DeBot logic here...
        Terminal.print(0, format("You have entered \"{}\"", value));
    }

    /// @notice Entry point function for DeBot.
    function start() public override {
        g_wallet = address(0);
        g_root_token = address(0);
        g_duration = 0;
        g_amount = 0;
        Terminal.print(0, "Hello and welcome to the Service Deployer.");
        Terminal.print(0, "You can here deploy new services.");
        Terminal.print(0, "1. Service payable with TON crystals");
        Terminal.print(0, "2. Service payable with a TIP3 token (NOT RELEASED YET)");
        Terminal.print(0, "3. Service payable with a generic service (NOT RELEASED YET)");
        Terminal.input(tvm.functionId(setUserMainAction), "Action: ", false);
    }

    function setUserMainAction(string value) public {
        if (value == "1"){
            _selectWallet();
        } else if (value == "2") {
            _selectRootContract();
        } else {
            Terminal.print(0, format("You have entered \"{}\", which is an invalid action.", value));
            start();
        }
    }

    function _selectRootContract() internal {
        AddressInput.get(tvm.functionId(setRootContract),
            "Enter the TIP3 root contract address"
        );
    }

    function setRootContract(address root) public {
        g_root_token = root;
        _selectWallet();
    }

    function _selectWallet() internal {
        AddressInput.get(tvm.functionId(setWallet),
            "Enter your wallet address"
        );
    }
    function setWallet(address value) public {
        g_wallet = value;
        AmountInput.get(tvm.functionId(setDuration),
            "What is the subscription duration of your service?",
            0,
            1,
            MAX_INT64
        );
    }

    function setDuration(uint value) public {
        g_duration = uint64(value);
        AmountInput.get(tvm.functionId(setDuration),
            "What is the subscription amount?",
            0,
            1,
            MAX_INT128
        );
    }

    function setAmount(uint value) public {
        g_amount = uint128(value);
        check();
    }

    function check() public {
        if (g_root_token == address(0)) {
            Terminal.print(0, "You are about to deploy a new service with parameters:");
            Terminal.print(0, format("Wallet: \"{}\"", g_wallet));
            Terminal.print(0, format("Duration of subscription: \"{}\"", g_duration));
            Terminal.print(0, format("Amount: \"{}\"", g_amount));
            ConfirmInput.get(tvm.functionId(onCheck),"Are you sure?");
        }
    }

    function onCheck(bool value) public {
        if (value) {
                IRecurringPaymentsRoot(g_contract).deployService{
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
                    g_duration,
                    g_root_token
                )
            );
        } else {
            Terminal.print(0, "Going back to main menu.");
            start();
        }
    }


}