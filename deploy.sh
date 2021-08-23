PARAMS=""

if [ -n "$2" ]
then PARAMS=$2
else PARAMS="{}"
fi

echo "PARAMS = $PARAMS"

ft contract build src/$1.sol -f &&
ft contract deploy $1 -f --params $PARAMS
