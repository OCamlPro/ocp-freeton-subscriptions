ft multisig transfer 10 --from user1 --to RecurringPaymentsRoot deployService '{"wallet":"%{account:address:user1}", "pplan":{"amount":"1000","period":"1000000"}}'

service_list=($(ft inspect --past RecurringPaymentsRoot 2>&1 | grep 'Event ServiceDeployed' | sed 's/.*\"value0\":\"//g' | sed 's/\".*//g'))
service=${service_list[-1]}

echo "Service address = $service"

ft account create SubManagerInstance --contract SubscriptionManager --address $service -f &&
ft multisig transfer 10 --from user1 --to SubManagerInstance subscribe &&

subscription_list=($(ft inspect --past SubManagerInstance 2>&1 | grep 'Event SubscriptionComplete' | sed 's/.*\"subscription\":\"//g' | sed 's/\".*//g'))
subscription=${subscription_list[-1]}
wallet_list=($(ft inspect --past SubManagerInstance 2>&1 | grep 'Event SubscriptionComplete' | sed 's/.*\"wallet\":\"//g' | sed 's/\".*//g'))
wallet=${wallet_list[-1]}


echo "Subscription address = $subscription"
echo "Wallet address = $wallet"
ft account create SubscriptionInstance --contract Subscription --address $subscription -f
ft account create WalletInstance --contract Wallet --address $wallet -f
