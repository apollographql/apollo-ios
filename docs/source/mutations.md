---
title: Performing mutations
---

In addition to fetching data using queries, Apollo iOS also handles GraphQL mutations. Mutations are identical to queries in syntax, the only difference being that you use the keyword `mutation` instead of `query` to indicate that the root fields on this query are going to be performing writes to the backend.

```graphql
mutation UpvotePost($postId: Int!) {
  upvotePost(postId: $postId) {
    votes
  }
}

```

GraphQL mutations represent two things in one query string:

1. The mutation field name with arguments, `upvotePost`, which represents the actual operation to be done on the server
2. The fields you want back from the result of the mutation to update the client: `{ votes }`

The above mutation will upvote a post on the server. The result might be:

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

Similar to queries, mutations are represented by instances of generated classes, conforming to the `GraphQLMutation` protocol. Constructor arguments are used to define mutation variables. You pass a mutation object to `ApolloClient#perform(mutation:)` to send the mutation to the server, execute it, and receive typed results:

```swift
apollo.perform(mutation: UpvotePostMutation(postId: postId)) { (result, error) in
  print(result?.data?.upvotePost?.votes)
}
```

<h2 id="fragments-in-mutation-results">Using fragments in mutation results</h2>

In many cases, you'll want to use mutation results to update your UI. Fragments can be a great way of sharing result handling between queries and mutations:

```graphql
mutation UpvotePost($postId: Int!) {
  upvotePost(postId: $postId) {
    ...PostDetails
  }
}
```

```swift
apollo.perform(mutation: UpvotePostMutation(postId: postId)) { (result, error) in
  self.configure(with: result?.data?.upvotePost?.fragments.postDetails)
}
```

<h2 id="input-objects">Passing input objects</h2>

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

<h2 id="designing-mutation-results">Designing mutation results</h2>

When people talk about GraphQL, they often focus on the data fetching side of things, because that's where GraphQL brings the most value. Mutations can be pretty nice if done well, but the principles of designing good mutations, and especially good mutation result types, are not yet well-understood in the open source community. So when you are working with mutations it might often feel like you need to make a lot of application-specific decisions.

In GraphQL, mutations can return any type, and that type can be queried just like a regular GraphQL query. So the question is - what type should a particular mutation return?

In most cases, the data available from a mutation result should be the server developer's best guess of the data a client would need to understand what happened on the server. For example, a mutation that creates a new comment on a blog post might return the comment itself. A mutation that reorders an array might need to return the whole array.
