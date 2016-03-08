//
//  WildApricotManager.swift
//  SVSC
//
//  Created by Nathan Taylor on 3/5/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Foundation

class WildApricotManager : NSObject, NSURLSessionDelegate {
    private let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()

    private let queue = dispatch_queue_create("com.scottsvalleysportsmen.wildappricot", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0))

    private let apiKey = "ngysloewr4l2xuxoihqnxk2ar2nbyq"
    private let clientKey = "emp5qkwm4x"
    private let clientSecret = "ei5yhdtd67pk8zqc4fqybxne0awci7"
    
    func authenticate(username: String, password: String) -> Void  {
        dispatch_async(queue) { () -> Void in
            if let url = NSURL(string: "https://oauth.wildapricot.org/auth/token") {
                let auth = "\(self.clientKey):\(self.clientSecret)"
                let request = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.addValue("Basic \(auth.base64())", forHTTPHeaderField: "Authorization")
                request.HTTPBody = "grant_type=password&username=\(username)&password=\(password)&scope=auto".dataUsingEncoding(NSUTF8StringEncoding)
                
                let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
                let group = Group()
                group.enter({ (done) -> Void in
                    let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                        guard let _ = data else {
                            done()
                            return
                        }
                        
                        if let dict = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                            guard let tokenType = dict!["token_type"] as? String else {
                                return
                            }
                            guard let accessToken = dict!["access_token"] as? String else {
                                return
                            }
                            self.configuration.HTTPAdditionalHeaders = [ "Authorization" : "\(tokenType) \(accessToken)",
                                "Accept" : "application/JSON",
                                "Accept-Encoding" : "gzip, deflate"];
                        }
                        done()
                    })
                    task.resume()
                })
                group.wait()
                
            }
        }
    }

    func downloadMembers(completion: ((json: [String: AnyObject]?) -> Void)) -> Void {
        dispatch_async(self.queue) { () -> Void in
            let group = Group()
            let session = NSURLSession(configuration: self.configuration, delegate: self, delegateQueue: nil)
            
            guard let url = NSURL(string: "https://api.wildapricot.org/v2/accounts/187035/contacts") else {
                return
            }
            let request = NSMutableURLRequest(URL: url)
            var resultURL: NSURL? = nil
            
            group.enter({ (done) -> Void in
                let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                    guard let _ = data else {
                        done()
                        return
                    }
                    
                    if let dict = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                        print("\(dict)")
                        if let r = dict!["ResultUrl"] as? String {
                            resultURL = NSURL(string: r)
                        }
                    }
                    done()
                })
                task.resume()
            })
            group.wait()
            
            guard let newURL = resultURL else {
                return
            }
            
            func checkForResult(url: NSURL, session: NSURLSession, completion: ((json: [String : AnyObject]) -> Void)!) -> Void {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(5)*NSEC_PER_SEC)), self.queue, { () -> Void in
                    let request = NSMutableURLRequest(URL: url)
                    let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                        guard let _ = data else {
                            return
                        }
                        
                        guard let dict = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as! [String: AnyObject] else {
                            return
                        }
                        
                        guard let _ = dict["Contacts"] else {
                            checkForResult(url, session: session, completion: completion)
                            return
                        }
                        
                        completion(json: dict)
                    })
                    task.resume()
                })
            }
            
            var result: [String : AnyObject]? = nil
            group.enter({ (done) -> Void in
                checkForResult(newURL, session: session, completion: { (json) -> Void in
                    result = json
                    done()
                })
            })
            group.notify({ () -> Void in
                completion(json: result)
            })
        }
    }

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        let json = String(data: data, encoding: NSUTF8StringEncoding)
        print("\(json)")
    }

}