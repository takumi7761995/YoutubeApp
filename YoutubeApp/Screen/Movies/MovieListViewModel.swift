//
//  ProfileViewModel.swift
//  ProfileApp
//
//  Created by 杉本匠 on 2022/04/24.
//

import Foundation
import Combine

class MovieListViewModel: ObservableObject {
  @Published private(set) var state: State = .idle
  @Published private(set) var movies: [Movie] = []
  @Published private(set) var history: [String] = []
  @Published private(set) var errorText = ""
  @Published var text = ""
  @Published var alert = false
 
  private var cancellable = Set<AnyCancellable>()
  private var onCommitSubject = PassthroughSubject<String, Never>()
  private var errorSubject = PassthroughSubject<APIServiceError, Never>()
  
  private var apiService: APIServiceType // プロトコル型プログラミング
  
  init(apiService: APIServiceType) {
    self.apiService = apiService
    bind()
  }
  
  private func bind(){
    onCommitSubject
      .filter({ query in
        !self.history.contains(query) // 重複削除
      })
      .sink(receiveValue: { query in
        self.history.append(query)    // 検索履歴に追加
      })
      .store(in: &cancellable)
    
    onCommitSubject
      .map {_ in .loading}
      .assign(to: \.state, on: self)
      .store(in: &cancellable)
    
    onCommitSubject
      .flatMap({ query in
        self.apiService.request(with: SearchRequest(query: query)) // fetch
          .catch { error -> Empty<SearchResponse, Never> in
            self.errorSubject.send(error)
            return .init() // flatMap が　where P: Publisher, P.Failure == Never　のため
          }
      })
      .map({ $0.items })
      .sink(receiveValue: { items in
        self.movies = self.convert(model: items)
        self.state = .loaded(self.movies)
      })
      .store(in: &cancellable)
    
    
    errorSubject
      .sink(receiveValue: { error in
        self.alert = true
        self.state = .loaded([])
        self.errorText = error.message
      })
      .store(in: &cancellable)
  }
  
  func send(event: Event) {
    switch event {
    case .onAppear:
      break
    case .onCommit(let query):
      onCommitSubject.send(query)
    case .deleteHistory(let index):
      self.history.remove(atOffsets: index)
    }
  }
}

extension MovieListViewModel {
  enum State {
    case idle
    case loading
    case loaded([Movie])
    case error(Error)
  }
  
  enum Event {
    case onAppear
    case onCommit(query: String)
    case deleteHistory(idnex: IndexSet)
  }
}

extension MovieListViewModel {
  struct Movie: Identifiable {
    let id: String
    let title: String
    let channelTitle: String
    let description: String
    let thumbnail: URL?
  }
  
  func convert(model: [Item]) -> [Movie] {
    model.compactMap { item in
      return Movie(id: item.snippet.channelId,
                   title: item.snippet.title,
                   channelTitle: item.snippet.channelTitle,
                   description: item.snippet.description,
                   thumbnail: item.snippet.thumbnails.medium.url
      )
      
    }
  }
}
