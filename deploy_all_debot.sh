bash deploy_debot.sh SubscriptionDebot &&
bash deploy_debot.sh SubscriptionManagerDebot &&
bash deploy_debot.sh RootDebot  &&

ft call RootDebot setSubManagerDebot '{"debot":"%{account:address:SubscriptionManagerDebot}"}'  &&
ft call RootDebot setPaymentRootContract '{"addr":"%{account:address:RecurringPaymentsRoot}"}' &&
ft call RootDebot setServiceListManager '{"addr":"%{account:address:ServiceListBuilder}"}' &&
ft call SubscriptionManagerDebot setSubscriptionDebot '{"debot":"%{account:address:SubscriptionDebot}"}' &&
ft call SubscriptionManagerDebot setRootDebot '{"debot":"%{account:address:RootDebot}"}' &&
ft call SubscriptionDebot setManagerDebot '{"debot":"%{account:address:SubscriptionManagerDebot}"}'
