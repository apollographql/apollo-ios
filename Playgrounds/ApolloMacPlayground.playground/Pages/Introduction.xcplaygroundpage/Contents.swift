/*:
# Apollo Mac Playground

NOTE: For this playground to build, you need to open it in the `Apollo.xcodeproj`, and make sure your active scheme is `Apollo Playground`. Otherwise it won't find the appropriate related frameworks, and you'll get all sorts of build errors.

This playground will run queries against the Star Wars API. You can use the `install_or_update_starwars_server` script in the `scripts` folder to grab and set up the code to run that server locally.

Alternately, you can check out [the repo](https://github.com/apollographql/starwars-server) directly, `cd` into the checked out directory using Terminal and run `npm install`.

Next, if you're not already, `cd` into the checked out directory and run:
 
  `> npm start`

to start the server locally. Once it starts, you should see:

  `> 🚀 Server ready at http://localhost:8080/graphql`

  `> 🚀 Subscriptions ready at ws://localhost:8080/websocket`

Once that's up and running, you can start running queries against it from this playground!
 
*/

//: [Queries](@next)
