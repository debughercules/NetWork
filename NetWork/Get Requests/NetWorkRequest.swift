//
//  NetWorkRequest.swift
//  NetWork
//
//  Created by Bharat Byan on 21/08/17.
//  Copyright © 2017 Bharat Byan. All rights reserved.
//

import Foundation

public class NetWorkRequest {
    
    public typealias netWorkValues = [(value:String, field:String)]
    
    public static var showLogs = false
    
    public static func processRequest(withType reqType:String, reqUrl:String, reqHeaders:netWorkValues, reqTimeOut:Double, reqBody:netWorkValues, withHandler completion:@escaping (_ succes:Bool, _ data:Any?) -> Void){
        
        var request = URLRequest(url: URL(string: reqUrl)!)
        request.httpMethod = reqType
        
        for header in reqHeaders {
            request.addValue(header.value, forHTTPHeaderField: header.field)
        }
        
        request.timeoutInterval = reqTimeOut

        var postBody = ""
        
        for (i, body) in reqBody.enumerated() {
            if i > 0 {
                postBody += "&"
            }
            postBody += body.field + "=" + body.value
        }
        
        postBody = postBody.replacingOccurrences(of: " ", with: "")
        
        request.httpBody = postBody.data(using: .utf8)
//        request.httpBody = reqBody.data(using: .utf8)
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                
                if showLogs{
                    print("__NetWork__ error=\(String(describing: error))")
                }
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                if showLogs{
                    print("__NetWork__ statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("__NetWork__ response = \(String(describing: response))")
                }
                
                completion(false, response)
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            if showLogs{
                print("__NetWork__ = \(String(describing: responseString))")
            }
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if showLogs{
                   print("__NetWork__ = \(json)")
                }
                completion(true, json)
                return
            }catch {
                
                if showLogs{
                    print("__NetWork__ error=\(String(describing: error))")
                }
                return
            }            
        }
        task.resume()
    }
}
