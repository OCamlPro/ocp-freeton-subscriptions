PARAMS=""

if [ -n "$2" ]
then PARAMS=$2
else PARAMS="{}"
fi

if [ -n "$3" ]
then STATIC=$3
fi

echo "PARAMS = $PARAMS"
echo "STATIC = $STATIC"


ft contract build src/$1.sol -f &&

if [ -z ${STATIC+x} ]
then ft contract deploy $1 -f --params $PARAMS --credit 1
else ft contract deploy $1 -f --params $PARAMS --credit 1 --static-vars $STATIC
fi
