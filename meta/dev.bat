start "Coffee App" /min coffee -w -c ../js
start "Coffee Tools" /min coffee -w -c ../node_modules/kaiec-tools
start "Coffee Fotobook" /min coffee -w -c ../node_modules/kaiec-fotobook
start "Coffee Exif" /min coffee -w -c ../node_modules/kaiec-exif
start "Coffee CLI" coffee
start "Node CLI" node
start "nodewebkit app" for /L %%i in (0) do nodewebkit ..

