ft contract build src/debot/$1.sol -f &&
ft contract deploy $1 --create $1  -f &&
ft call $1 setABI '{"dabi":"%{hex:read:contract:abi:'$1'}"}' &&
ft call $1 setIcon  '{ "icon": "%{hex:string:data:image/png;base64,%{base64:file:icon.png}}"}'
