//
//  SearchBookManager.swift
//  Book Scanner
//
//  Created by Israel Manzo on 4/29/24.
//

import Foundation
import UIKit
import AVFoundation

final class SearchBookManager {
    
    static let shred = SearchBookManager()
    
    func search(isbn: String, completion: @escaping (Books) -> Void) {
        
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration)
        
        guard var url = URL(string: "https://www.googleapis.com/books/v1/volumes/") else { return }
        
        url.append(queryItems: [URLQueryItem(name: "q", value: "isbn:\(isbn)")])
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                print("Error in url session")
               return
            }
            guard let data = data else { return }
            do {
                let bookData = try JSONDecoder().decode(Books.self, from: data)
                completion(bookData)
            } catch {
                print("Error decoding book data")
            }
        }
        task.resume()
    }
}

