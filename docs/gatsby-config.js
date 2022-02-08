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
        algoliaFilters: ['docset:ios'],
        subtitle: 'Client (iOS)',
        description: 'A guide to using Apollo with iOS',
        githubRepo: 'apollographql/apollo-ios',
        defaultVersion: '0.X',
        versions: {
          '1.0 (Alpha)': 'release/1.0',
        },
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
            'tutorial/tutorial-add-sdk',
            'tutorial/tutorial-obtain-schema',
            'tutorial/tutorial-execute-query',
            'tutorial/tutorial-query-ui',
            'tutorial/tutorial-pagination',
            'tutorial/tutorial-detail-view',
            'tutorial/tutorial-authentication',
            'tutorial/tutorial-mutations',
            'tutorial/tutorial-subscriptions'
          ],
          Usage:[
            'downloading-schema',
            'initialization',
            'fetching-queries',
            'mutations',
            'fragments',
            'caching',
            'subscriptions',
            'swift-scripting',
            'request-pipeline',
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
