pragma ton-solidity >=0.44.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
pragma AbiHeader time;

import "Builder.sol";
import "ServiceList.sol";
import "interfaces/IRecurringPaymentsRoot.sol";
import "interfaces/IServiceListBuilder.sol";

// Service List Builder
contract ServiceListBuilder is Builder, IServiceListBuilder {

    uint64 m_deploy_cpt;
    address g_root; 

    constructor(address buildable) public {
        tvm.accept();
        ref = IBuildable(buildable);
        optional(TvmCell) o;
        code = o;
        m_deploy_cpt = 0;
    }

    struct DeploymentMessage{
        address provider;
        address service;
    }


    mapping(uint64 => DeploymentMessage) m_deploy_msgs; 
    // Deployed messages, used when bounce
    // TODO: GC

    event Bounce();
    event OnBounce(uint32);
    event Decoding();
    event Decode(uint64);
    event Error();

    function init() override public {
        super.init();
        g_root = msg.sender;
    }

    // Deploys a list of services (must be called by root)
    function deploy(address service_provider, address service) external {
        require (code.hasValue(), E_UNINITIALIZED);
        
        m_deploy_msgs.add(now, DeploymentMessage(service_provider, service));

        ServiceList list = new ServiceList {
            value:msg.value/3,
            code: code.get(),
            bounce:true,
            varInit:{
                s_root: g_root,
                s_service_provider: service_provider,
                s_deployer: address(this)
            }
        }(m_deploy_cpt);

        ++m_deploy_cpt;

        list.addService{value:0, flag:128}(service);
    
    }

    function getServicesList(address provider) external view override returns(address list) {
        TvmCell stateInit =
            tvm.buildStateInit({
                code:code.get(),
                contr:ServiceList,
                varInit:{
                    s_root: g_root,
                    s_service_provider: provider,
                    s_deployer: address(this)
                }    
            });
        list = address(tvm.hash(stateInit));
        return list;
    }

    onBounce(TvmSlice slice) external {
        tvm.accept();
        uint32 funId = slice.decode(uint32);
        emit OnBounce(funId);

        if (funId == tvm.functionId(ServiceList)){
            emit Decoding();
            uint64 timestamp = slice.decodeFunctionParams(ServiceList);
            emit Decode(timestamp);
            
            DeploymentMessage m = m_deploy_msgs[timestamp];

            TvmCell stateInit =
                tvm.buildStateInit({
                    code:code.get(),
                    contr:ServiceList,
                    varInit:{
                        s_service_provider: m.provider,
                        s_root: g_root,
                        s_deployer: address(this)
                    }    
                });
            address list = address(tvm.hash(stateInit));
            ServiceList(list).addService{value:0, flag:128}(m.service);

            delete m_deploy_msgs[timestamp];
        } else if (funId == tvm.functionId(ServiceList)) {
            emit Error();
        }
    }
}
