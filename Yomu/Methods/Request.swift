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
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...404).contains(response.statusCode) else {
                print ("Unexpected response recieved from server: \(response!)")
                return
            }
            
            if response.statusCode != 200 {
                print(response)
                return
            }
            
            if data == nil {
                print("nil data reviced from server.")
                return
            }
           
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(result, from: data)
                    print(decodedResponse)
                } catch let error {
                    print("Failed to decode \(data), \(error)")
                    return
                }
            } else {
                return
            }
        }.resume()
    }
}

