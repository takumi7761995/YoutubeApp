//
//  ContentView.swift
//  ProfileApp
//
//  Created by 杉本匠 on 2022/04/24.
//

import SwiftUI

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

struct ContentView: View {
  init() {
    UITabBar.appearance().barTintColor = UIColor.black
    UITabBar.appearance().unselectedItemTintColor = UIColor.white
    let config = UINavigationBarAppearance()
    UINavigationBar.appearance().standardAppearance = config
    UINavigationBar.appearance().compactAppearance = config
    UINavigationBar.appearance().scrollEdgeAppearance = config
  }
  
  var body: some View {
    TabView {
      NavigationView {
        MovieListView()
          .navigationTitle(Text("Youtube API"))
          .navigationBarTitleDisplayMode(.inline)
      }
      .tabItem {
        createTabItem(tabItem: .home)
      }
      NavigationView {
        SettingView()
      }
      .tabItem {
        createTabItem(tabItem: .setting)
      }
    }
  }
}


extension ContentView {
  @ViewBuilder
  private func createTabItem(tabItem: TabItem) -> some View{
    ZStack {
      Image(systemName: tabItem.item.image)
      Text(tabItem.item.label)
    }
  }
  
  enum TabItem {
    case home
    case setting
    
    var item: (image: String, label: String) {
      switch self {
      case .home: return (image: "house", label: "Home")
      case .setting: return (image: "gear", label: "Setting")
      }
    }
  }
}



struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
