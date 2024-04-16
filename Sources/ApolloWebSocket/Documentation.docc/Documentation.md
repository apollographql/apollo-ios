# ``ApolloWebSocket``

A web socket network transport implementation that provides support for [`GraphQLSubscription`](/documentation/apolloapi/graphqlsubscription) operations over a web socket connection.

## Overview

To support subscriptions over web sockets, initialize your [`ApolloClient`](/documentation/apollo/apolloclient) with a  ``SplitNetworkTransport``.
