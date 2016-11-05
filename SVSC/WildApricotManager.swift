//
//  WildApricotManager.swift
//  SVSC
//
//  Created by Nathan Taylor on 3/5/16.
//  Copyright © 2016 Nathan Taylor. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class WildApricotManager : NSObject, URLSessionDelegate {
    static var sharedManager = WildApricotManager()
    
    var accountNumber = 187035
    let baseURL: URL
    
    fileprivate let configuration = URLSessionConfiguration.default

    fileprivate let queue = DispatchQueue(label: "com.scottsvalleysportsmen.wildappricot", attributes: DispatchQueue.Attributes(rawValue: UInt64(0)))

    fileprivate let apiKey = "ngysloewr4l2xuxoihqnxk2ar2nbyq"
    fileprivate let clientKey = "emp5qkwm4x"
    fileprivate let clientSecret = "ei5yhdtd67pk8zqc4fqybxne0awci7"
    
    override init() {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.wildapricot.org"
        urlComponents.path = "/" + "v2" + "/" + "Accounts" + "/" + String(accountNumber) + "/"
        
        baseURL = urlComponents.url!
        super.init()
    }
    
    func authenticate(_ username: String, password: String) -> Void  {
        queue.async { () -> Void in
            if let url = URL(string: "https://oauth.wildapricot.org/auth/token") {
                let auth = "\(self.clientKey):\(self.clientSecret)"
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.addValue("Basic \(auth.base64())", forHTTPHeaderField: "Authorization")
                request.httpBody = "grant_type=password&username=\(username)&password=\(password)&scope=auto".data(using: String.Encoding.utf8)
                
                let session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
                let group = Group()
                group.enter({ (done) -> Void in
                    let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                        guard let _ = data else {
                            done()
                            return
                        }
                        
                        if let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                            guard let tokenType = dict!["token_type"] as? String else {
                                return
                            }
                            guard let accessToken = dict!["access_token"] as? String else {
                                return
                            }
                            self.configuration.httpAdditionalHeaders = [ "Authorization" : "\(tokenType) \(accessToken)",
                                "Accept" : "application/JSON",
                                "Accept-Encoding" : "gzip, deflate"];
                            self.configuration.timeoutIntervalForRequest = 300.0
                            self.configuration.timeoutIntervalForResource = 300.0
                        }
                        done()
                    })
                    task.resume()
                })
                group.wait()
                
            }
        }
    }

    func downloadMembers(_ completion: @escaping ((_ json: [String: AnyObject]?) -> Void)) -> Void {
        self.queue.async { () -> Void in
            let group = Group()
            let session = Foundation.URLSession(configuration: self.configuration, delegate: self, delegateQueue: nil)
            
            var urlComponents = URLComponents(url: self.baseURL, resolvingAgainstBaseURL: false)
            if let path = urlComponents?.path {
                urlComponents?.path = path + "Contacts"
            }
//            urlComponents?.queryItems = [URLQueryItem(name: "$async", value: "false")]
            
            guard let url = urlComponents?.url else {
                return
            }
            var result: [String : AnyObject]? = nil
            
            group.enter({ (done) -> Void in
                let task = session.dataTask(with: URLRequest(url: url), completionHandler: { (data, response, error) -> Void in
                    guard let _ = data else {
                        print("DATA NIL")
                        done()
                        return
                    }
                    
                    guard let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! [String: AnyObject] else {
                        print("COULD NOT READ JSON")
                        done()
                        return
                    }
                    
                    if let resultURLString = dict["ResultUrl"] as? String, let resultURL = URL(string: resultURLString) {
                        group.enter({ (leave) in
                            
                            let task = session.dataTask(with: URLRequest(url: resultURL), completionHandler: { (data, response, error) in
                                
                                guard let _ = data else {
                                    print("DATA NIL")
                                    done()
                                    return
                                }
                                
                                guard let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! [String: AnyObject] else {
                                    print("COULD NOT READ JSON")
                                    done()
                                    return
                                }
                                
                                result = dict
                                
                                leave()
                            })

                            self.queue.asyncAfter(deadline: DispatchTime.now() + 240.0, execute: {
                                task.resume()
                            })
                        })
                    }
                    done()
                })
                task.resume()
            })
            group.notify({ () -> Void in
                completion(result)
            })
        }
    }
    
    func downloadEvents(_ completion: @escaping ((_ events: [ClubEvent]) -> Void)) -> Void {
        self.queue.async { () -> Void in
            let group = Group()
            let session = Foundation.URLSession(configuration: self.configuration, delegate: self, delegateQueue: nil)
            
            var urlComponents = URLComponents(url: self.baseURL, resolvingAgainstBaseURL: false)
            if let path = urlComponents?.path {
                urlComponents?.path = path + "events"
            }

            guard let url = urlComponents?.url else {
                return
            }
            
            var results = [ClubEvent]()
            
            group.enter({ (done) -> Void in
                let task = session.dataTask(with: URLRequest(url: url), completionHandler: { (data, response, error) -> Void in
                    guard let d = data else {
                        done()
                        return
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                    
                    if let dict = try? JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                        if let events = dict!["Events"] as? [[String: AnyObject]] {
                            for event in events {
                                guard let event_id = event["Id"] as? Int else {
                                    continue
                                }
                                guard let start = dateFormatter.date(from: event["StartDate"] as! String), let end = dateFormatter.date(from: event["EndDate"] as! String) else {
                                    continue
                                }
                                
                                
                                var clubEvent = ClubEvent(
                                    id: event_id,
                                    name: event["Name"]! as! String,
                                    location: event["Location"]! as! String,
                                    start_date: start,
                                    end_date: end,
                                    registration_enabled: event["RegistrationEnabled"] as! Bool,
                                    registration_limit: event["RegistrationsLimit"] as? Int,
                                    registrations: nil,
                                    registration_count: event["ConfirmedRegistrationsCount"] as? Int,
                                    checked_in_attendees_count: event["CheckedInAttendeesNumber"] as! Int,
                                    url: event["Url"] as! String
                                )
                                results.append(clubEvent)
                                
                                if clubEvent.registration_enabled && clubEvent.registration_count > 0 {
                                    let registrations = [ClubEventRegistration]()
                                    clubEvent.registrations = registrations
                                    
                                    var urlComponents = URLComponents(url: self.baseURL, resolvingAgainstBaseURL: false)
                                    if let path = urlComponents?.path {
                                        urlComponents?.path = path + "EventRegistrations"
                                    }
                                    urlComponents?.queryItems = [URLQueryItem(name: "eventID", value: String(clubEvent.id))]
                                    
                                    guard let url = urlComponents?.url else {
                                        continue
                                    }
                                    
                                    group.enter { (done) -> Void in
                                        let task = session.dataTask(with: URLRequest(url: url), completionHandler: { (data, response, error) -> Void in
                                            
                                            guard let d = data, let _ = try? JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [[String: AnyObject]] else {
                                                done()
                                                return
                                            }
                                            
//                                            for reg in json {
//                                                let registration = ClubEventRegistration(
//                                                    event_id: clubEvent.id,
//                                                    registration_type_id: (reg["RegistrationType"] as! [String: AnyObject])["Id"] as! Int,
//                                                    contact_id:
//                                                    date: dateFormatter.dateFromString(reg["RegistrationDate"])!
//                                                )
//                                            }
                                            print("\(dict)")
                                            
                                            done()
                                        })
                                        task.resume()
                                    }
                                }
                            }
                        }

                    }
                    done()
                })
                task.resume()
            })
            group.notify({ () -> Void in
                completion(results)
            })
        }
    }

    func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceiveResponse response: URLResponse, completionHandler: (Foundation.URLSession.ResponseDisposition) -> Void) {
    }
    
    func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceiveData data: Data) {
    }

}
