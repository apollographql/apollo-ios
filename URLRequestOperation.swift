//
//  URLRequestOperation.swift
//  Apollo
//
//  Created by Venkatesh Jujjavarapu on 6/26/19.
//

import Foundation

/// Wrapper operation around a URLSessionTask.
final class URLRequestOperation: AsynchronousOperation, Cancellable {
    
    let session: URLSession
    var request: URLRequest
    let resultHandler: ((Data?, URLResponse?, Error?) -> Void)?
    
    private var sessionTask: URLSessionTask?
    
    init(session: URLSession, request: URLRequest, resultHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
        self.session = session
        self.request = request
        self.resultHandler = resultHandler
    }
    
    override func start() {
        guard !isCancelled else {
            state = .finished
            return
        }
        
        state = .executing
        
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            self.notifyResultHandler(data: data, response: response, error: error)
            self.state = .finished
        }
        
        task.resume()
        self.sessionTask = task
    }
    
    override func cancel() {
        super.cancel()
        sessionTask?.cancel()
    }
    
    private func notifyResultHandler(data: Data?, response: URLResponse?, error: Error?) {
        guard let resultHandler = resultHandler else { return }
        resultHandler(data, response, error)
    }
}
