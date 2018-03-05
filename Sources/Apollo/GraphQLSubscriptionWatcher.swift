import Dispatch

public final class GraphQLSubscriptionWatcher<Subscription: GraphQLSubscription>: Cancellable
{
    weak var client: ApolloClient?
    let subscription: Subscription
    let handlerQueue: DispatchQueue
    let resultHandler: OperationResultHandler<Subscription>
    
    private weak var subscriber: Cancellable?
    
    init(client: ApolloClient, subscribe: Subscription, handlerQueue: DispatchQueue, resultHandler: @escaping OperationResultHandler<Subscription>) {
        self.client = client
        self.subscription = subscribe
        self.handlerQueue = handlerQueue
        self.resultHandler = resultHandler
    }
    
    func subscribe() {
        subscriber = client?._subscribe(subscribe: subscription, queue: handlerQueue) { (result, error) in
            self.resultHandler(result, error)
        }
    }
    
    public func unsubscribe() {
        cancel()
    }
    
    /// Cancel any in progress subscription operations
    public func cancel() {
        subscriber?.cancel()
    }
    
}
