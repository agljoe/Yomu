//
//  Request.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-07.
//

import Foundation

public class Request: NSObject {
    public func post<T: Encodable, R : Codable>(url: URL, value: String, content: T, result: R.Type, completion: @escaping (HTTPURLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.setValue(value, forHTTPHeaderField: "Content-Type")
        request.httpShouldHandleCookies = true
        
        request.httpMethod = "POST"
        
        request.httpBody = content as? Data
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                completion(nil, error)
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...404).contains(response.statusCode) else {
                print ("Unexpected response recieved from server: \(response!)")
                completion(response as? HTTPURLResponse, nil)
                return
            }
            
            if response.statusCode != 200 {
                print(response)
                completion(response, nil)
                return
            }
            
            if data == nil {
                print("nil data reviced from server.")
                completion(response, error)
                return
            }
           
            if let data = data {
                do {
                    let _ = try JSONDecoder().decode(result, from: data)
//                    print(decodedResponse)
                    completion(response, nil)
                } catch let error {
                    print("Failed to decode \(data), \(error)")
                    completion(response, error)
                    return
                }
            } else {
                completion(response, error)
                return
            }
        }.resume()
    }
}

