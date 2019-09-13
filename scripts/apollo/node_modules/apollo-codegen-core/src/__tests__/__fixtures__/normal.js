const query = gql`
  query UserProfileView {
    me {
      id
      uuid
      role
    }
  }
`;
