//
//  APIMgr.swift
//  DramaDemo
//
//  Created by Raymondting on 2020/7/1.
//  Copyright © 2020 Raymondting. All rights reserved.
//

import Foundation

class HttpMgr
{
    typealias CompleteHandler = ((Data?, URLResponse?, Error?) -> Void)
    let requestSerialQueue = DispatchQueue(label: "requestSerialQueue")
    
    private let requestTimout: TimeInterval = 10
    private let requestResourceTimout: TimeInterval = 30
    
    static let shared = HttpMgr()
    
    func doHttpRequest(withURL url : String, completeHandler : @escaping(CompleteHandler))
    {
        requestSerialQueue.sync {
            let sessionConfig = URLSessionConfiguration.default
                sessionConfig.timeoutIntervalForRequest = requestTimout
                sessionConfig.timeoutIntervalForResource = requestResourceTimout
                let session = URLSession(configuration: sessionConfig)
            
                session.dataTask(with: URL(string: url)!, completionHandler: {(data, response, error) in
                        if let error = error
                        {
                            NSLog("Failed to dowload \(url) : \(error)")
                            completeHandler(nil, response, error)
                            return
                        }
                        
                        guard let data = data else
                        {
                            NSLog("No Data Loaded")
                            completeHandler(nil, response, error)
                            return
                        }
                        
                        completeHandler(data, response, nil)
                    }
                ).resume()
            }
        }
}
