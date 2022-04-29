//
//  ProfileView.swift
//  ProfileApp
//
//  Created by 杉本匠 on 2022/04/24.
//

import SwiftUI

struct MovieListView: View {
  @StateObject var viewModel: MovieListViewModel = .init(apiService: APIService())
  
  var body: some View {
    ZStack {
      setBackground()
      content
    }
    .onAppear {
      viewModel.send(event: .onAppear)
    }
    .alert(isPresented: $viewModel.alert) {
      Alert(title: Text("Error"), message: Text(viewModel.errorText))
    }
    .searchable(text: $viewModel.text, prompt: "Search Movies") {
      ForEach(viewModel.history, id: \.self) { history in
        Text(history).searchCompletion(history)
      }
    }
    .onSubmit(of: .search) {
      viewModel.send(event: .onCommit(query: viewModel.text))
    }
  }
  
  private var content: some View {
    switch viewModel.state {
    case .idle:
      return Color.clear.eraseToAnyView()
    case .loading:
      return ProgressView()
        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
        .eraseToAnyView()
    case .loaded(let movies):
      return list(of: movies).eraseToAnyView()
    case .error(let error):
      return Text(error.localizedDescription).eraseToAnyView()
    }
  }
  
  @ViewBuilder
  private func list(of movies: [MovieListViewModel.Movie]) -> some View {
    ScrollView(showsIndicators: false) { // LazyVStack inside ScrollView
      LazyVStack {
        ForEach(viewModel.movies) { movie in
          MovieItem(movie: movie)
        }
        //        ForEach(0..<15) { _ in
        //          RoundedRectangle(cornerRadius: 15)
        //            .frame(width: 200, height: 200)
        //            .foregroundColor(.white)
        //        }
      }
    }
  }
  
  
  private func setBackground() -> some View{
    let gradient = Gradient(stops: [
      .init(color: .black, location: 0.0),
      .init(color: .black, location: 0.3),
      .init(color: .purple, location: 1.0)
    ])
    return LinearGradient(gradient: gradient, startPoint: .bottom, endPoint: .top)
      .ignoresSafeArea()
  }
}


struct MovieItem: View {
  let movie: MovieListViewModel.Movie
  
  var body: some View {
    VStack {
      AsyncImage(url: movie.thumbnail) { image in
        image
          .resizable()
          .scaledToFill()
          .frame(height: 200)
        //          .overlay(alignment: .bottomLeading) {
        //            Text(movie.channelTitle)
        //              .bold()
        //              .lineLimit(1)
        //              .foregroundColor(.white)
        //              .font(.title)
        //              .padding()
        //          }
          .cornerRadius(15)
          .padding()
      } placeholder: {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
      }
    }
  }
}



struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    MovieListView(viewModel: .init(apiService: APIService()))
  }
}
