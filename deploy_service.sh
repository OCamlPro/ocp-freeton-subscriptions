ft multisig transfer 10 --from user1 --to RecurringPaymentsRoot deployService '{"wallet":"%{account:address:user1}", "pplan":{"amount":"1000000000","period":"1000000"}}'

service_list=($(ft inspect --past RecurringPaymentsRoot 2>&1 | grep 'Event ServiceDeployed' | sed 's/.*\"value0\":\"//g' | sed 's/\".*//g'))
service=${service_list[-1]}

echo "Service address = $service"

ft account create SubManagerInstance --contract SubscriptionManager --address $service -f &&
ft multisig transfer 10 --from user1 --to SubManagerInstance subscribe '{"subscriber":"%{account:address:user1}"}' &&

subscription_list=($(ft inspect --past SubManagerInstance 2>&1 | grep 'Event SubscriptionComplete' | sed 's/.*\"subscription\":\"//g' | sed 's/\".*//g'))
subscription=${subscription_list[-1]}
wallet_list=($(ft inspect --past SubManagerInstance 2>&1 | grep 'Event SubscriptionComplete' | sed 's/.*\"wallet\":\"//g' | sed 's/\".*//g'))
wallet=${wallet_list[-1]}


echo "Subscription address = $subscription"
echo "Wallet address = $wallet"
ft account create SubscriptionInstance --contract Subscription --address $subscription -f &&
ft account create WalletInstance --contract Wallet --address $wallet -f &&
ft multisig transfer 5 --from user1 --to SubscriptionInstance refillAccount '{"expected_gas":"100000000"}' &&
ft multisig transfer 1 --from user1 --to SubscriptionInstance cancelSubscription # &&
# ft multisig transfer 1 --from user1 --to SubscriptionInstance providerClaim
