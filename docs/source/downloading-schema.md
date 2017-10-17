---
title: Downloading a schema
---

Apollo iOS requires a GraphQL schema file as input to the code generation process. A schema file is a JSON file that contains the results of an an introspection query. Conventionally this file is called `schema.json`, and you store it next to the `.graphql` files in your target.

You can use `apollo-codegen` to download a GraphQL schema by sending an introspection query to the server:

```sh
apollo-codegen download-schema http://localhost:8080/graphql --output schema.json
```

If needed, you can use the `header` option to add additional HTTP headers to the request. For example, to include an authentication token, use `--header "Authorization: Bearer <token>"`:

```sh
apollo-codegen download-schema https://api.github.com/graphql --output schema.json --header "Authorization: Bearer <token>"
```
