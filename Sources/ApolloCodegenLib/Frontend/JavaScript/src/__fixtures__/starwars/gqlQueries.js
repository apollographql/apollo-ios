import React from "react";
import { gql, graphql } from "react-apollo";

const Query = gql`
  query HeroAndFriends($episode: Episode) {
    hero(episode: $episode) {
      ...heroDetails
    }
  }

  fragment heroDetails on Character {
    name
    ... on Droid {
      primaryFunction
    }
    ... on Human {
      height
    }
  }

  ${"this should be ignored"}
`;

const AnotherQuery = gql`
  query HeroName {
    hero {
      name
    }
  }
`;

function Component() {
  return <div />;
}

export default graphql(Query)(Component);
