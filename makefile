default: unpack-cli

unpack-cli:
	(cd CLI && tar -xvf apollo-ios-cli.tar.gz -C ../)
	chmod +x apollo-ios-cli

xcframeworks:
	./make_xcframework.sh Apollo
	./make_xcframework.sh ApolloAPI
	./make_xcframework.sh ApolloSQLite
