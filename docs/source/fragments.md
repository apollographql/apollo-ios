---
title: Using fragments
---

In GraphQL, [fragments](http://graphql.org/learn/queries/#fragments) define pieces of data you may want to reuse in multiple places:

```graphql
query HeroAndFriends($episode: Episode) {
  hero(episode: $episode) {
    name
    ...HeroDetails
    friends {
      ...HeroDetails
    }
  }
}

fragment HeroDetails on Character {
  name
  appearsIn
}
```

Apollo iOS generates separate result types for fragments, which means they are a great way of keeping UI components or utility functions independent of specific queries.

One common pattern is to define a fragment for a child view (like a `UITableViewCell`), and include the fragment in a query defined at a parent level (like a `UITableViewController`). This way, the child view can easily be reused and only depends on the specific data it needs:

```swift
func configure(with heroDetails: HeroDetails?) {
  textLabel?.text = heroDetails?.name
}
```

This also works the other way around. The parent view controller only has to know the fragment name, but doesn't need to know anything about the fields it specifies. You can make changes to the fragment definition without affecting the parent.

In fact, this is the main reason fields included through fragments are not exposed directly, but require you to access the data through the fragment explicitly:

```swift
apollo.fetch(query: HeroAndFriendsQuery(episode: .empire)) { (result, error) in
  guard let data = result?.data else { return }
  print(data.hero?.name) // Luke Skywalker
  print(data.hero?.appearsIn) // WON'T WORK
  print(data.hero?.fragments.heroDetails.appearsIn) // [.newhope, .empire, .jedi]
  print(data.hero?.friends?.flatMap { $0?.fragments.heroDetails.name }.joined(separator: ", ")) // Han Solo, Leia Organa, C-3PO, R2-D2
}
```

In most cases, you'll simply pass the whole fragment to a child view without needing to know anything about the data it specifies:

```swift
cell.configure(with: hero?.fragments.heroDetails)
```

<h2 id="type-conditions">Type conditions</h2>

The GraphQL type system includes interfaces and unions as abstract types that object types can conform to. In the Star Wars example schema for example, both `Human`s and `Droid`s implement the `Character` interface. If we query for a hero, the result can be either a human or a droid, and if we want to access any type-specific properties we will have to use a fragment with a type condition:

```graphql
query HeroAndFriends($episode: Episode) {
  hero(episode: $episode) {
    name
    ...DroidDetails
  }
}

fragment DroidDetails on Droid {
  name
  primaryFunction
}
```

You can access named fragments with type conditions the same way you access other fragments, but their type will be optional to reflect the fact that their fields will only be available if the object type matches:

```swift
apollo.fetch(query: HeroAndFriendsQuery(episode: .empire)) { (result, error) in
  data.hero?.fragments.droidDetails?.primaryFunction
}
```

Alternatively, you can use [inline fragments](http://graphql.org/learn/queries/#inline-fragments) with type conditions to query for type-specific fields:

```graphql
query HeroAndFriends($episode: Episode) {
  hero(episode: $episode) {
    name
    ... on Droid {
      primaryFunction
    }
  }
}
```

And results from inline fragments with type conditions will be made available through specially generated `as<Type>` properties:

```swift
apollo.fetch(query: HeroAndFriendsQuery(episode: .empire)) { (result, error) in
  guard let data = result?.data else { return }
  data.hero?.asDroid?.primaryFunction
}
```

You can also use inline fragments inside named fragments:

```graphql
query HeroAndFriends($episode: Episode) {
  hero(episode: $episode) {
    name
    ...HeroDetails
    friends {
      ...HeroDetails
    }
  }
}

fragment HeroDetails on Character {
  name
  ... on Droid {
    primaryFunction
  }
}
```

```swift
apollo.fetch(query: HeroAndFriendsQuery(episode: .empire)) { (result, error) in
  guard let data = result?.data else { return }
  data.hero?.fragments.heroDetails.asDroid?.primaryFunction
}
```

Apollo iOS automatically augments your queries to add a `__typename` field to selection sets. This is used primarily to support conditional fragments, but it means a `__typename` property is always defined and can be used to differentiate between object types manually if needed.
