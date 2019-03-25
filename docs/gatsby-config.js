module.exports = {
  __experimentalThemes: [
    {
      resolve: 'gatsby-theme-apollo-docs',
      options: {
        root: __dirname,
        subtitle: 'Apollo iOS Guide',
        description: 'A guide to using Apollo with iOS',
        contentDir: 'docs/source',
        basePath: '/docs/ios',
        githubRepo: 'apollographql/apollo-ios',
        sidebarCategories: {
          null: [
            'index',
            'installation',
            'api-reference'
          ],
          Usage:[
            'downloading-schema',
            'initialization',
            'fetching-queries',
            'fragments',
            'watching-queries',
            'mutations',
          ]
        }
      }
    }
  ]
};
