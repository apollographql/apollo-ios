default: unpack-cli

unpack-cli:
	(cd CLI && tar -xvf apollo-ios-cli.tar.gz -C ../)
	chmod +x apollo-ios-cli
