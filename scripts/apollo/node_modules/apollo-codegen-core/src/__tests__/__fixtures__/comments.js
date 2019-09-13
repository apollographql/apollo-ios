const query = gql`
  query UserProfileView {
    me {
      id
      # TODO: https://www.fast.com/sdf/sdf
      uuid
      # Some other comment
      role
    }
  }
`;
