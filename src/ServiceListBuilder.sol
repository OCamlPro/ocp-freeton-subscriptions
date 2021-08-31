pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "Builder.sol";
import "ServiceList.sol";
import "interfaces/IRecurringPaymentsRoot.sol";

// Service List Builder
contract ServiceListBuilder is Builder {

    constructor(address buildable) public {
        tvm.accept();
        ref = IBuildable(buildable);
        optional(TvmCell) o;
        code = o;
    }

    struct DeploymentMessage{
        address root;
        address provider;
        address service;
    }

    mapping(uint64 => DeploymentMessage) m_deploy_msgs; // Deployed messages, used when bounce


    event Bounce();
    event OnBounce(uint32);
    event Decoding();
    event Decode(uint64);
    event Error();


    // Deploys a list of services (must be called by root)
    function deploy(address service_provider, address service) external {
        require (code.hasValue(), E_UNINITIALIZED);
        
        m_deploy_msgs.add(now, DeploymentMessage(msg.sender, service_provider, service));

        ServiceList list = new ServiceList {
            value:msg.value/3,
            code: code.get(),
            bounce:true,
            varInit:{
                s_root: msg.sender,
                s_service_provider: service_provider,
                s_deployer: address(this)
            }
        }(now);

        list.addService{value:0, flag:128}(service);
    
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
                        s_root: m.root,
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
