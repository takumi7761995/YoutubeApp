//
//  Search.swift
//  ProfileApp
//
//  Created by 杉本匠 on 2022/04/24.
//

import Foundation
import Combine

// MARK: - create URL components
// リクエストするときに必須の項目
protocol APIRequestType {
  var APIKey: String {get}
  var part: String {get}
  var path: String {get}
  var queryItems: [URLQueryItem] {get}
}


struct SearchRequest: APIRequestType {
  let query: String
  var APIKey: String { return "" } // YOUR_API_KEY
  var part: String { return "snippet" }
  var path: String { return "/youtube/v3/search" }
  var limit: Int { return 10 } // API is default 5
  var queryItems: [URLQueryItem] {
    return [
      .init(name: "key", value: APIKey),
      .init(name: "part", value: part),
      .init(name: "maxResults", value: String(limit)),
      .init(name: "q", value: query)
    ]
  }
}

// MARK: - API request

protocol APIServiceType {
  func request(with request: APIRequestType) -> AnyPublisher<SearchResponse, APIServiceError>
}

enum APIServiceError: Error {
  case invalidURL
  case responseError
  case parseError(Error)
  case none
  case other(Error)
  
  var message: String {
    switch self {
    case .invalidURL:
      return "無効なURLです"
    case .responseError:
      return "レスポンスエラー"
    case .parseError(let error):
      return "パースエラー：\(error.localizedDescription)"
    case .none:
      return "該当する検索結果がありません"
    case .other(let error):
      return "予期せぬエラー：\(error.localizedDescription)"
    }
  }
}

struct APIService: APIServiceType {
  private let baseURL = "https://www.googleapis.com"
  
  func request(with request: APIRequestType) -> AnyPublisher<SearchResponse, APIServiceError> {
    guard let url = URL(string: request.path, relativeTo: URL(string: baseURL)) else {
      return Fail(error: APIServiceError.invalidURL).eraseToAnyPublisher()
    }
    var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
    urlComponents.queryItems = request.queryItems
    
    let request = URLRequest(url: urlComponents.url!)
    let publisher = URLSession.shared.dataTaskPublisher(for: request)
      .tryMap { (data, response) in
        guard let response = response as? HTTPURLResponse,
              (200..<300).contains(response.statusCode) else {
          throw APIServiceError.responseError
        }
        return data
      }
      .mapError { _ in
        APIServiceError.responseError
      }
      .decode(type: SearchResponse.self, decoder: JSONDecoder())
      .mapError { error in
        APIServiceError.parseError(error)
      }
      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
    
    return publisher
  }
}
