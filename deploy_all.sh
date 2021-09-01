bash deploy.sh Wallet &&
bash deploy.sh WalletBuilder '{"buildable":"%{account:address:Wallet}"}' &&
bash deploy.sh Subscription '{"p":{"amount":"0","period":"0","root_token":"0:0000000000000000000000000000000000000000000000000000000000000000"},"wallet":"%{account:address:Wallet}"}' &&
bash deploy.sh SubscriptionBuilder '{"buildable":"%{account:address:Subscription}"}' &&
bash deploy.sh SubscriptionManager '{"sub_builder_address":"%{account:address:SubscriptionBuilder}","wal_builder_address":"%{account:address:WalletBuilder}","pplan":{"amount":"0","period":"0","root_token":"0:0000000000000000000000000000000000000000000000000000000000000000"}}' &&
bash deploy.sh SubManagerBuilder '{"buildable":"%{account:address:SubscriptionManager}","sub_builder":"%{account:address:SubscriptionBuilder}","wal_builder":"%{account:address:WalletBuilder}"}' &&
bash deploy.sh ServiceList '{"value0":"0"}' &&
bash deploy.sh ServiceListBuilder '{"buildable":"%{account:address:ServiceList}"}' &&
bash deploy.sh RecurringPaymentsRoot '{"wal_builder":"%{account:address:WalletBuilder}","sub_builder":"%{account:address:SubscriptionBuilder}","sm_builder":"%{account:address:SubManagerBuilder}","sl_builder":"%{account:address:ServiceListBuilder}"}' '{"s_owner":"%{account:address:Wallet}"}'
