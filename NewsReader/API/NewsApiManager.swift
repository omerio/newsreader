//
//  NewsApiManager.swift
//  NewsReader
//
//  Created by Jose Jeria on 21.02.18.
//  Copyright © 2018 José Jeria. All rights reserved.
//

import Foundation

class NewsApiManager {
    
    // MARK: - Public
    
    static let instance = NewsApiManager()
    
    func mostPopular(onSuccess: @escaping ([Article]) -> Void, onError: @escaping (String) -> Void) {
        dataTask?.cancel()
        dataTask = urlSession.dataTask(with: apiRequest) { data, response, error in
            guard error == nil, let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                onError("Request failed")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)
                
                let response = try decoder.decode(Response.self, from: data)
                let sortedArticlesByDate = response.articles.sorted { $0.published > $1.published }
                
                onSuccess(sortedArticlesByDate)
            } catch let error {
                onError("Decode error: \(error)")
                return
            }
            }
        dataTask?.resume()
    }
    
    // MARK: - Private
    
    private init() {}
    private var dataTask: URLSessionDataTask?
    private let apiBaseUrl = "https://api.nytimes.com/svc/mostpopular/v2/mostviewed/all-sections/7.json"
    private let apiKey = "api-key"
    private let apiKeyValue = "<API-Key>"
    private var urlSession: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        
        return URLSession(configuration: configuration)
    }
    private var apiUrl: URL {
        return URL(string: apiBaseUrl)!.withQueryParams([apiKey: apiKeyValue])
    }
    
    private var apiRequest: URLRequest {
        var request = URLRequest(url: apiUrl)
        request.cachePolicy = .reloadRevalidatingCacheData
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        
        return request
    }
    
}
