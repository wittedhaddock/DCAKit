//
//  NSURLSession+Synchronous.swift
//  DCAKit
//
//  Created by Drew Crawford on 8/8/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

import Foundation
extension NSURLSession {
    public struct SynchronousDataTask {
        public var task: NSURLSessionDataTask
        public var error: NSError?
        public var data: NSData?
        public var response: NSURLResponse?
    }
    public func synchronousDataRequestWithRequest(request: NSURLRequest) -> SynchronousDataTask {
        var sema = dispatch_semaphore_create(0)
        var data : NSData?
        var response : NSURLResponse?
        var error : NSError?
        let task = self.dataTaskWithRequest(request, completionHandler: { (ldata: NSData!, lresponse: NSURLResponse!, lerror: NSError!) -> Void in
            dispatch_semaphore_signal(sema);
            data = ldata
            response = lresponse
            error = lerror
            return;
        })
        task.resume()
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)
        return SynchronousDataTask(task: task, error: error, data: data, response: response)
    }
}