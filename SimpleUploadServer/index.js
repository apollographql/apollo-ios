const { ApolloServer, gql, GraphQLUpload } = require("apollo-server");
const promisesAll = require("promises-all");
const { db, processUpload } = require("./file-utils");

const typeDefs = gql`
  type File {
    id: ID!
    path: String!
    filename: String!
    mimetype: String!
  }
  type Query {
    uploads: [File]
  }
  type Mutation {
    singleUpload(file: Upload!): File!
    multipleUpload(files: [Upload!]!): [File!]!
    multipleParameterUpload(singleFile: Upload!, multipleFiles: [Upload!]!): [File!]!
  }
`;

const resolvers = {
  Upload: GraphQLUpload,
  Query: {
    uploads: () => db.get("uploads").value()
  },
  Mutation: {
    singleUpload: (obj, { file }) => processUpload(file),
    async multipleUpload(obj, { files }) {
      const { resolve, reject } = await promisesAll.all(
        files.map(processUpload)
      );

      if (reject.length)
        reject.forEach(({ name, message }) =>
          // eslint-disable-next-line no-console
          console.error(`${name}: ${message}`)
        );

      return resolve;
    },
    async multipleParameterUpload(obj, { singleFile, multipleFiles }) {
      const { resolve, reject } = await promisesAll.all(
        [singleFile, ...multipleFiles].map(processUpload)
      );

      if (reject.length)
        reject.forEach(({ name, message }) =>
          // eslint-disable-next-line no-console
          console.error(`${name}: ${message}`)
        );

      return resolve;
    }
  }
};

const server = new ApolloServer({
  typeDefs,
  resolvers,
  uploads: {
    maxFileSize: 10000000, // 10 MB
    maxFiles: 20
  }
});

server.listen({
  port: 4001
}).then(({ url }) => {
  console.info(`Upload server started at ${url}`);
});
