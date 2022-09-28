---
title: Mutations
---

In addition to fetching data using queries, Apollo iOS also handles GraphQL mutations. Mutations are identical to queries in syntax, the only difference being that you use the keyword `mutation` instead of `query` to indicate that the root fields on this query are going to be performing writes to the backend.

For more information on GraphQL mutations, we recommend [reading this guide](https://graphql.org/learn/queries/#mutations).

GraphQL mutations represent two things in one operation:

1. The mutation field name with arguments, which represents the actual operation to be done on the server.
2. The fields you want back from the result of the mutation to update the client.

All business logic involved in mutating data is handled by the server. The client has no direct knowledge of how data will be mutated. Just like any other field, each mutation in a schema returns a type. If that type is an object type, you may query fields on that type, which can be used to fetch the new state of the mutated object.

In this example, we define a mutation called `UpvotePost`, which performs the schema's `upvotePost(postId:)` mutation.

```graphql
mutation UpvotePost($postId: Int!) {
  upvotePost(postId: $postId) {
    id
    votes
  }
}
```

The server implements the `upvotePost(postId:)` mutation to add an upvote to the post with the given `postId` and return that post. The above mutation selects the `id` and `votes` fields on the returned `Post` object.

The result might be:

```
{
  "data": {
    "upvotePost": {
      "id": "123",
      "votes": 5
    }
  }
}
```

## Performing mutations

Similar to queries, mutations are represented by instances of generated classes, conforming to the `GraphQLMutation` protocol. Operation arguments are generated used to define mutation variables. For more information on passing arguments to a mutation see ["Operation arguments"](./fetching-data#operation-arguments)

You pass a mutation object to `ApolloClient.perform(mutation:)` to send the mutation to the server, execute it, and receive typed results.

```swift
apollo.perform(mutation: UpvotePostMutation(postId: postId)) { result in
  guard let data = try? result.get().data else { return }
  print(data.upvotePost?.votes)
}
```

## Using fragments in mutation results

In many cases, you'll want to use mutation results to update your UI. Fragments can be a great way of sharing result handling between queries and mutations:

```graphql
mutation UpvotePost($postId: Int!) {
  upvotePost(postId: $postId) {
    ...PostDetails
  }
}
```

```swift
client.perform(mutation: UpvotePostMutation(postId: postId)) { result in
  guard let data = try? result.get().data else { return }
  self.configure(with: data.upvotePost?.fragments.postDetails)
}
```

## Passing input objects

The GraphQL type system includes [input objects](http://graphql.org/learn/schema/#input-types) as a way to pass complex values to fields. Input objects are often defined as mutation variables, because they give you a compact way to pass in objects to be created:

```graphql
mutation CreateReviewForEpisode($episode: Episode!, $review: ReviewInput!) {
  createReview(episode: $episode, review: $review) {
    stars
    commentary
  }
}
```

```swift
let review = ReviewInput(stars: 5, commentary: "This is a great movie!")
apollo.perform(mutation: CreateReviewForEpisodeMutation(episode: .jedi, review: review))
```

## Designing mutation results

When people talk about GraphQL, they often focus on the data fetching side of things, because that's where GraphQL brings the most value. Mutations can be pretty nice if done well, but the principles of designing good mutations, and especially good mutation result types, are not yet well-understood in the open source community. So when you are working with mutations it might often feel like you need to make a lot of application-specific decisions.

In GraphQL, mutations can return any type, and that type can be queried just like a regular GraphQL query. So the question is - what type should a particular mutation return?

In most cases, the data available from a mutation result should be the server developer's best guess of the data a client would need to understand what happened on the server. For example, a mutation that creates a new comment on a blog post might return the comment itself. A mutation that reorders an array might need to return the whole array.

## Uploading files

### An Important Caveat About File Uploads
Apollo recommends only using GraphQL file uploading for proof-of-concept applications. While there is a spec we presently support for making `multipart-form` requests with GraphQL, we've found that, in practice, it's much simpler to use more purpose-built tools for file upload.

Apollo recommends using more traditional methods to upload your files, such as REST `multipart-form` uploads or SDK's that support file uploads, such as AmazonS3. [This article covers how to do that with Typescript](https://www.apollographql.com/blog/graphql-file-uploads-with-react-hooks-typescript-amazon-s3-tutorial-ef39d21066a2), but the general theory for iOS works basically the same:

- Upload data **not** using GraphQL, getting back either an identifier or URL for the uploaded data.
- Send that received identifier or URL to your graph using GraphQL.

If you'd still prefer to upload directly with Apollo, instructions follow.

### Uploading Directly With Apollo

The iOS SDK supports the [GraphQL Multipart Request Specification](https://github.com/jaydenseric/graphql-multipart-request-spec#multipart-form-field-structure) for uploading files.

At the moment, we only support uploads for a single operation, not for batch operations. You can upload multiple files for a single operation if your server supports it, though.

To upload a file, you will need:

- A `NetworkTransport` which also supports the `UploadingNetworkTransport` protocol on your `ApolloClient` instance. If you're using `RequestChainNetworkTransport` (which is set up by default), this protocol is already supported.
- The correct `MIME` type for the data you're uploading. The default value is `application/octet-stream`.
- Either the data or the file URL of the data you want to upload.
- A mutation which takes an `Upload` as a parameter. Note that this must be supported by your server.

Here is an example of a GraphQL query for a mutation that accepts a single upload, and then returns the `id` for that upload:

```graphql
mutation UploadFile($file:Upload!) {
    singleUpload(file:$file) {
        id
    }
}
```

If you wanted to use this to upload a file called `a.txt`, it would look something like this:

```swift
// Create the file to upload
guard
  let fileURL = Bundle.main.url(forResource: "a",
                                withExtension: "txt"),
  let file = GraphQLFile(fieldName: "file", // Must be the name of the field the file is being uploaded to
                         originalName: "a.txt",
                         mimeType: "text/plain", // <-defaults to "application/octet-stream"
                         fileURL: fileURL) else {
    // Either the file URL couldn't be created or the file couldn't be created.
    return
}

// Actually upload the file
client.upload(operation: UploadFileMutation(file: "a"), // <-- `Upload` is a custom scalar that's a `String` under the hood.
              files: [file]) { result in
  switch result {
  case .success(let graphQLResult):
    print("ID: \(graphQLResult.data?.singleUpload.id)")
  case .failure(let error):
    print("error: \(error)")
  }
}
```

A few other notes:

- Due to some limitations around the spec, whatever the file is being added for should be at the root of your GraphQL query. So if you have something like:

    ```graphql
    mutation AvatarUpload($userID: GraphQLID!, $file: Upload!) {
      id
    }
    ```

    it will work, but if you have some kind of object encompassing both of those fields like this:

    ```graphql
    # Assumes AvatarObject(userID: GraphQLID, file: Upload) exists
    mutation AvatarUpload($avatarObject: AvatarObject!) {
      id
    }
    ```

    it will not. Generally you should be able to deconstruct upload objects to allow you to send the appropriate fields.

- If you are uploading an array of files, you need to use the same field name for each file. These will be updated at send time.
- If you are uploading an array of files, the array of `String`s passed into the query must be the same number as the array of files.
