**CLASS**

# `URLSessionClient`

```swift
open class URLSessionClient: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate
```

> A class to handle URL Session calls that will support background execution,
> but still (mostly) use callbacks for its primary method of communication.
>
> **NOTE:** Delegate methods implemented here are not documented inline because
> Apple has their own documentation for them. Please consult Apple's
> documentation for how the delegate methods work and what needs to be overridden
> and handled within your app, particularly in regards to what needs to be called
> when for background sessions.

## Properties
### `session`

```swift
open private(set) var session: URLSession!
```

> The raw URLSession being used for this client

## Methods
### `init(sessionConfiguration:callbackQueue:)`

```swift
public init(sessionConfiguration: URLSessionConfiguration = .default,
            callbackQueue: OperationQueue? = .main)
```

> Designated initializer.
>
> - Parameters:
>   - sessionConfiguration: The `URLSessionConfiguration` to use to set up the URL session.
>   - callbackQueue: [optional] The `OperationQueue` to tell the URL session to call back to this class on, which will in turn call back to your class. Defaults to `.main`.

#### Parameters

| Name | Description |
| ---- | ----------- |
| sessionConfiguration | The `URLSessionConfiguration` to use to set up the URL session. |
| callbackQueue | [optional] The `OperationQueue` to tell the URL session to call back to this class on, which will in turn call back to your class. Defaults to `.main`. |

### `deinit`

```swift
deinit
```

### `clear(task:)`

```swift
open func clear(task identifier: Int)
```

> Clears underlying dictionaries of any data related to a particular task identifier.
>
> - Parameter identifier: The identifier of the task to clear.

#### Parameters

| Name | Description |
| ---- | ----------- |
| identifier | The identifier of the task to clear. |

### `clearAllTasks()`

```swift
open func clearAllTasks()
```

> Clears underlying dictionaries of any data related to all tasks.
>
> Mostly useful for cleanup and/or after invalidation of the `URLSession`.

### `sendRequest(_:rawTaskCompletionHandler:completion:)`

```swift
open func sendRequest(_ request: URLRequest,
                      rawTaskCompletionHandler: RawCompletion? = nil,
                      completion: @escaping Completion) -> URLSessionTask
```

> The main method to perform a request.
>
> - Parameters:
>   - request: The request to perform.
>   - rawTaskCompletionHandler: [optional] A completion handler to call once the raw task is done, so if an Error requires access to the headers, the user can still access these.
>   - completion: A completion handler to call when the task has either completed successfully or failed.
>
> - Returns: The created URLSesssion task, already resumed, because nobody ever remembers to call `resume()`.

#### Parameters

| Name | Description |
| ---- | ----------- |
| request | The request to perform. |
| rawTaskCompletionHandler | [optional] A completion handler to call once the raw task is done, so if an Error requires access to the headers, the user can still access these. |
| completion | A completion handler to call when the task has either completed successfully or failed. |

### `cancel(task:)`

```swift
open func cancel(task: URLSessionTask)
```

> Cancels a given task and clears out its underlying data.
>
> NOTE: You will not receive any kind of "This was cancelled" error when this is called.
>
> - Parameter task: The task you wish to cancel.

#### Parameters

| Name | Description |
| ---- | ----------- |
| task | The task you wish to cancel. |

### `urlSession(_:didBecomeInvalidWithError:)`

```swift
open func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?)
```

### `urlSession(_:task:didFinishCollecting:)`

```swift
open func urlSession(_ session: URLSession,
                     task: URLSessionTask,
                     didFinishCollecting metrics: URLSessionTaskMetrics)
```

### `urlSession(_:didReceive:completionHandler:)`

```swift
open func urlSession(_ session: URLSession,
                     didReceive challenge: URLAuthenticationChallenge,
                     completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
```

### `urlSessionDidFinishEvents(forBackgroundURLSession:)`

### `urlSession(_:task:didReceive:completionHandler:)`

```swift
open func urlSession(_ session: URLSession,
                     task: URLSessionTask,
                     didReceive challenge: URLAuthenticationChallenge,
                     completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
```

### `urlSession(_:taskIsWaitingForConnectivity:)`

```swift
open func urlSession(_ session: URLSession,
                     taskIsWaitingForConnectivity task: URLSessionTask)
```

### `urlSession(_:task:didCompleteWithError:)`

```swift
open func urlSession(_ session: URLSession,
                     task: URLSessionTask,
                     didCompleteWithError error: Error?)
```

### `urlSession(_:task:needNewBodyStream:)`

```swift
open func urlSession(_ session: URLSession,
                     task: URLSessionTask,
                     needNewBodyStream completionHandler: @escaping (InputStream?) -> Void)
```

### `urlSession(_:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:)`

```swift
open func urlSession(_ session: URLSession,
                     task: URLSessionTask,
                     didSendBodyData bytesSent: Int64,
                     totalBytesSent: Int64,
                     totalBytesExpectedToSend: Int64)
```

### `urlSession(_:task:willBeginDelayedRequest:completionHandler:)`

```swift
open func urlSession(_ session: URLSession,
                     task: URLSessionTask,
                     willBeginDelayedRequest request: URLRequest,
                     completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void)
```

### `urlSession(_:task:willPerformHTTPRedirection:newRequest:completionHandler:)`

```swift
open func urlSession(_ session: URLSession,
                     task: URLSessionTask,
                     willPerformHTTPRedirection response: HTTPURLResponse,
                     newRequest request: URLRequest,
                     completionHandler: @escaping (URLRequest?) -> Void)
```

### `urlSession(_:dataTask:didReceive:)`

```swift
open func urlSession(_ session: URLSession,
                     dataTask: URLSessionDataTask,
                     didReceive data: Data)
```

### `urlSession(_:dataTask:didBecome:)`

```swift
open func urlSession(_ session: URLSession,
                     dataTask: URLSessionDataTask,
                     didBecome streamTask: URLSessionStreamTask)
```

### `urlSession(_:dataTask:didBecome:)`

```swift
open func urlSession(_ session: URLSession,
                     dataTask: URLSessionDataTask,
                     didBecome downloadTask: URLSessionDownloadTask)
```

### `urlSession(_:dataTask:willCacheResponse:completionHandler:)`

```swift
open func urlSession(_ session: URLSession,
                     dataTask: URLSessionDataTask,
                     willCacheResponse proposedResponse: CachedURLResponse,
                     completionHandler: @escaping (CachedURLResponse?) -> Void)
```

### `urlSession(_:dataTask:didReceive:completionHandler:)`

```swift
open func urlSession(_ session: URLSession,
                     dataTask: URLSessionDataTask,
                     didReceive response: URLResponse,
                     completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
```
