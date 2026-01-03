complete -c it.b64 -f -a "encode decode" -d "Mode"

complete -c it.rnd-string -f -d "Generate random string"
complete -c it.rnd-number -f -d "Generate random number"
complete -c it.rnd-port -f -d "Find available random port"

complete -c it.hash -f -a "sha256 sha512 sha1 sha3 md5 blake2b blake2s rmd160 sha224 sha384" -d "Hash type"
complete -c it.hmac -f -a "sha256 sha512 sha1 sha3 md5 blake2b blake2s rmd160 sha224 sha384" -d "Hash type"

complete -c it.uuid -f -a "1 3 4 5" -d "UUID version"

complete -c it.qr -f -d "Generate QR code"
complete -c it.barcode -f -d "Generate barcode"

complete -c it.timestamp -f -d "Convert timestamps and dates"
complete -c it.timezone -f -d "Display time in timezone"

complete -c it.ipinfo -f -d "Get IP address information"
complete -c it.useragent -f -d "Parse user agent string"

complete -c it.urlencode -f -a "encode decode" -d "Mode"
complete -c it.htmlencode -f -a "encode decode" -d "Mode"

complete -c it.regex-test -f -d "Test regex pattern"
complete -c it.regex-extract -f -d "Extract with regex pattern"
