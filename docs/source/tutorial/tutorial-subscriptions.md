---
title: "11. Write your first subscription"
---

In this section, you will use subscriptions to get notified whenever someone books a flight 🚀! [Subscriptions](https://graphql.org/blog/subscriptions-in-graphql-and-relay/) allow to be notified in real time whenever an event happens on your server. The [fullstack backend](https://apollo-fullstack-tutorial.herokuapp.com) supports subscriptions based on [WebSockets](https://en.wikipedia.org/wiki/WebSocket).


## Write your subscription

Open your [Sandbox](https://studio.apollographql.com/sandbox/explorer?endpoint=https%3A%2F%2Fapollo-fullstack-tutorial.herokuapp.com) back up, click on the Schema tab at the far left. In addition to `queries` and `mutations`, you will see a third type of operations, `subscriptions`. Click on subscriptions to see the `tripsBooked` subscription:

<img alt="The definition of tripsBooked in the schema" class="screenshot" src="images/schema_tripsBooked_definition.png"/>

This subscription doesn't take any argument and returns a single scalar named `tripsBooked`. Since you can book multiple trips at once, `tripsBooked` is an `Int`. It will contain the number of trips booked at once or -1 if a trip has been cancelled.

Click the play button to the left of `tripsBooked` to open the subscription in Explorer. Open a new tab, then check the `tripsBooked` button to have the subscription added:

<img alt="The initial definition of the TripsBooked subscription" class="screenshot" src="images/explorer_tripsbooked_initial.png"/>

Again, rename your subscription so it's easier to find:

<img alt="The subscription after rename" class="screenshot" src="images/explorer_tripsbooked_renamed.png"/>

Click the Submit Operation button, and your subscription will start listening to events. You can tell it's up and running because a panel will pop up at the lower left where subscription data will come in:

<img alt="The UI showing that it's listening for subscription updates" class="screenshot" src="images/explorer_subscriptions_listening.png"/>

## Test your subscription

Open a new tab in Explorer. In this new tab, add code to book a trip like on [step 9](09-write-your-first-mutation), but with a hard-coded ID:

```graphql
mutation BookTrip {
  bookTrips(launchIds: ["93"]){
    message
  }
}
```

Do not forget to include the authentication header. At the bottom of the Sandbox Explorer pane where you add operations, there's a `Headers` section:

<img alt="Adding a login token to explorer" class="screenshot" src="images/explorer_authentication_header.png"/>

Click the Submit Operation button. If everything went well, you just booked a trip! At the top of the right panel, you'll see the success JSON for your your `BookTrip` mutation, and below it, updated JSON for the `TripsBooked` subscription:

<img alt="Subscription success in Explorer" class="screenshot" src="images/explorer_subscription_success.png"/>

Continue booking and/or canceling trips, you will see events coming in the subscription panel in real time. After some time, the server might close the connection and you'll have to restart your subscription to keep receiving events.

## Add the subscription to the project

Now that your subscription is working, add it to your project. Create a file named `TripsBooked.graphql` next to `schema.graphqls` and your other GraphQL files and paste the contents of the subscription. The process is similar to what you did for queries and mutations:

```graphql:title=app/src/main/graphql/com/example/rocketreserver/TripsBooked.graphql
subscription TripsBooked {
  tripsBooked
}
```

## Configure your ApolloClient to use subscriptions

In `Apollo.kt`, configure a `webSocketServerUrl` for your `ApolloClient`:

```kotlin:title=Apollo.kt
    instance = ApolloClient.Builder()
        .httpServerUrl("https://apollo-fullstack-tutorial.herokuapp.com/graphql")
        .webSocketServerUrl("wss://apollo-fullstack-tutorial.herokuapp.com/graphql")
        .okHttpClient(okHttpClient)
        .build()
```

`wss://` is the protocol for WebSocket.

## Display a SnackBar when a trip is booked/cancelled

In `MainActivity`, register your subscription and start listening to events using coroutine Flows. Use a [Material SnackBar](https://material.io/develop/android/components/snackbar/) to display a small message coming from the bottom of the screen:

```kotlin:title=MainActivity.kt
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_main)

        lifecycleScope.launch {
            apolloClient(this@MainActivity).subscription(TripsBookedSubscription()).toFlow()
                .collect {
                    val text = when (val trips = it.data?.tripsBooked) {
                        null -> getString(R.string.subscriptionError)
                        -1 -> getString(R.string.tripCancelled)
                        else -> getString(R.string.tripBooked, trips)
                    }
                    Snackbar.make(
                        findViewById(R.id.main_frame_layout),
                        text,
                        Snackbar.LENGTH_LONG
                    ).show()
                }
        }
    }
```

> NOTE: You may need to `import kotlinx.coroutines.flow.collect` if you see an error about internal use for `collect`.

## Handle errors

Like for queries and mutations, the subscription will throw an error if the connection is lost or any other protocol error happens. To handle these situations, you can use [Flow.retry](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines.flow/retry.html):

```kotlin:title=MainActivity.kt
    apolloClient(this@MainActivity).subscription(TripsBookedSubscription()).toFlow()
        .retryWhen { _, attempt ->
            delay(attempt * 1000)
            true
        }
        .collect {
            // ...
```

## Test your code

Build and run your app and go back to Sandbox Explorer, and select the tab where you set up the `BookTrip` mutation. Book a new trip while your app is open, you should see a SnackBar 🚀:

<img alt="A trip has been booked" class="screenshot" src="images/snackbar.png"/>

This concludes the tutorial.

## More resources

Use the rest of this documentation for more advanced topics like [Caching](/essentials/caching/)  or [Gradle configuration](/essentials/plugin-configuration/).

Feel free to ask questions by either [opening an issue on our GitHub repo](https://github.com/apollographql/apollo-android/issues), [joining the community](http://community.apollographql.com/new-topic?category=Help&tags=mobile,client) or [stopping by our channel in the KotlinLang Slack](https://app.slack.com/client/T09229ZC6/C01A6KM1SBZ)(get your invite [here](https://slack.kotl.in/)).

And if you want dig more and see GraphQL in real-world apps, you can take a look at these open source projects using Apollo Kotlin:

* https://github.com/BoD/apollo-graphql-android-sample
* https://github.com/ZacSweers/CatchUp
