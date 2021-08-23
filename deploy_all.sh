bash deploy.sh Wallet &&
bash deploy.sh WalletBuilder '{"buildable":"%{account:address:Wallet}"}' &&
bash deploy.sh Subscription '{"p":{"amount":"0","period":"0"},"wallet":"%{account:address:user1}"}' &&
bash deploy.sh SubscriptionBuilder '{"buildable":"%{account:address:Subscription}"}' &&
bash deploy.sh SubscriptionManager '{"sub_builder_address":"%{account:address:SubscriptionBuilder}","wal_builder_address":"%{account:address:WalletBuilder}"}' &&
bash deploy.sh SubManagerBuilder '{"buildable":"%{account:address:SubscriptionManager}"}' &&
bash deploy.sh RecurringPaymentsRoot '{"wal_builder":"%{account:address:WalletBuilder}","sub_builder":"%{account:address:SubscriptionBuilder}","sm_builder":"%{account:address:SubManagerBuilder}"}' &&

ft multisig transfer 10 --from user1 --to RecurringPaymentsRoot init