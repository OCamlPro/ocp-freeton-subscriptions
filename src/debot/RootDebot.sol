pragma ton-solidity ^0.44.0;
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
import "../interfaces/IMultisig.sol";
import "../interfaces/IServiceList.sol";
import "../interfaces/IServiceListBuilder.sol";
import "SubscriptionManagerDebot.sol";

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

    address g_service_list_manager;

    bytes m_icon;

    address g_subscription_manager_debot;
    address g_subscription_debot;

    address g_contract; // Recursive Payments Root contract

    address g_wallet; // User
    uint256 g_wallet_pubkey; // if loaded

    address g_root_token; // For TIP3

    uint64 g_duration;
    uint128 g_amount;

    bool g_valid;

    address[] g_service_list;

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

    function setPaymentRootContract(address addr) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        g_contract = addr;
    }

    function setServiceListManager(address addr) public{
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        g_service_list_manager = addr;
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

    /// @notice Entry point function for DeBot.
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
        g_wallet = value;
        _getCustodians(tvm.functionId(loadPubkey), value);
    }

    function loadPubkey(CustodianInfo[] custodians) public {
        if (custodians.length != 1) {
            Terminal.print(0, "Can register services only if 1 custodian on multisig");
            start();
        } else {
            g_wallet_pubkey = custodians[0].pubkey;
            _onStart();
        }

    }

    function _onStart() internal {
        g_root_token = address(0);
        g_duration = 0;
        g_amount = 0;
        Terminal.print(0, "Hello and welcome to the Service Manager.");
        Terminal.print(0, "You can here deploy new services.");
        Terminal.print(0, "1. Service payable with TON crystals");
        Terminal.print(0, "2. Service payable with a TIP3 token (NOT RELEASED YET)");
        Terminal.print(0, "3. Service payable with a generic service (NOT RELEASED YET)");
        if (!g_service_list.empty()) {Terminal.print(0, "7. Manage services");}
        if (!g_service_list.empty()) {Terminal.print(0, "8. List your deployed services");}
        Terminal.print(0, "9. Load your deployed services");
        Terminal.print(0, "0. Change wallet");
        Terminal.input(tvm.functionId(setUserMainAction), "Action: ", false);

    }

    function setUserMainAction(string value) public {
        if (value == "1"){
            _selectDuration();
        } else if (value == "2") {
            _selectRootContract();
        } else if (value == "3") {
            Terminal.print(0, "Generic services not supported yet");
            _onStart();
        } else if (value == "7") {
            Terminal.print(0, "Which service do you want to manage?");
            printServicesSelection();
        } else if (value == "8") {
            Terminal.print(0, "Listing loaded services");
            printServices();
        } else if (value == "9") {
            Terminal.print(0, "Listing services");
            _listServices();
        } else if (value == "0") {
            start();
        } else {
            Terminal.print(0, format("You have entered \"{}\", which is an invalid action.", value));
            _onStart();
        }
    }

    function _selectRootContract() internal {
        AddressInput.get(tvm.functionId(setRootContract),
            "Enter the TIP3 root contract address"
        );
    }

    function setRootContract(address value) public {
        g_root_token = value;
        _selectDuration();
    }

    function _selectDuration() public {
        AmountInput.get(tvm.functionId(setDuration),
            "What is the subscription duration of your service?",
            0,
            1,
            MAX_INT64
        );
    }

    function setDuration(uint value) public {
        g_duration = uint64(value);
        _selectAmount();
    }

    function _selectAmount() public {
        AmountInput.get(tvm.functionId(setAmount),
            "What is the subscription amount?",
            0,
            1,
            MAX_INT128
        );
    }

    function setAmount(uint value) public {
        g_amount = uint128(value);
        _check();
    }

    function _check() internal {
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
            okCheck();
        } else {
            Terminal.print(0, "Going back to main menu.");
            _onStart();
        }
    }

    function okCheck() public view {
        TvmCell payload = 
            tvm.encodeBody(
                IRecurringPaymentsRoot.deployService,
                g_wallet,
                PaymentPlan(
                    g_amount,
                    g_duration,
                    g_root_token
                )
            );
        IMultisig(g_wallet).sendTransaction {
            extMsg:true,
            time:uint64(now),
            expire:0,
            sign:true,
            pubkey:(g_wallet_pubkey),
            callbackId:(tvm.functionId(onRestart)),
            onErrorId:tvm.functionId(onErrorRestart),
            abiVer:2
        }(g_contract, 1 ton, true, 0, payload);   
    }

    function _listServices() internal {
        Terminal.print(0, "_listServices");

        optional(uint256) nopubkey;
        IServiceListBuilder(g_service_list_manager).getServicesList {
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: nopubkey,
            time: uint64(now),
            expire: 0,
            callbackId:(tvm.functionId(onGetServicesList)),
            onErrorId:tvm.functionId(onErrorRestart)
        }(g_wallet);
        
    }

    function onGetServicesList(address list) public {
        Terminal.print(0, "onGetServicesList");
        optional(uint256) nopubkey;
        IServiceList(list).getServices {
            extMsg:true,
            time:uint64(now),
            expire:0,
            sign:false,
            pubkey:nopubkey,
            callbackId:(tvm.functionId(saveServices)),
            onErrorId:tvm.functionId(onErrorRestart),
            abiVer:2
        }();
    }

    function saveServices(address[] services) public {
        g_service_list = services;
        printServices();
    }

    function printServices() public {
        for(address service : g_service_list){
            Terminal.print(0, format("Service: {}", service));            
        }
        _onStart();
    }

    function printServicesSelection() public {
        uint32 i = 0;
        for(address service : g_service_list){
            Terminal.print(0, format("{}. {}", i, service));
            ++i;          
        }
        AmountInput.get(tvm.functionId(selectService),
            "Which service do you want to manage?",
            0,
            0,
            uint128(g_service_list.length) - 1);
    }

    function selectService(uint value) public view {
        SubscriptionManagerDebot(g_subscription_manager_debot).onStart(
            g_service_list[value]
        );
    }

    function onRestart() public {
        Terminal.print(0, "Success!");
        _onStart();
    }

    function onErrorRestart(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Error: sdkError:{} exitCode:{}", sdkError, exitCode));
        _onStart();
    }

}