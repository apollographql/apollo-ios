const themeOptions = require('gatsby-theme-apollo-docs/theme-options');

module.exports = {
  plugins: [
    {
      resolve: 'gatsby-theme-apollo-docs',
      options: {
        ...themeOptions,
        root: __dirname,
        pathPrefix: '/docs/ios',
        algoliaIndexName: 'ios',
        subtitle: 'Client (iOS)',
        description: 'A guide to using Apollo with iOS',
        githubRepo: 'apollographql/apollo-ios',
        checkLinksOptions: {
          ignore: [
            '/api/Apollo/README/',
            '/api/ApolloWebSocket/README/',
            '/api/ApolloSQLite/README/'
          ]
        },
        sidebarCategories: {
          null: [
            'index',
            'installation',
            'api-reference'
          ],
          Tutorial: [
            'tutorial/tutorial-introduction',
            'tutorial/tutorial-create-project',
            'tutorial/tutorial-obtain-schema',
            'tutorial/tutorial-execute-query',
            'tutorial/tutorial-query-ui',
            'tutorial/tutorial-pagination',
            'tutorial/tutorial-detail-view',
            'tutorial/tutorial-authentication',
            'tutorial/tutorial-mutations'
          ],
          Usage:[
            'downloading-schema',
            'initialization',
            'fetching-queries',
            'mutations',
            'fragments',
            'caching',
            'subscriptions',
            'swift-scripting'
          ]
        }
      }
    },
    {
      resolve: "gatsby-plugin-react-svg",
      options: {
        rule: {
          include: /\.svg$/,
        }
      }
    }
  ]
};
