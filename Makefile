build: all

contract:
	bash deploy_all.sh

debot:
	bash deploy_all_debot.sh

exec:
	ft client -- debot fetch %{account:address:RootDebot}

all: contract debot

