//
//  ContentView.swift
//  iMovie
//
//  Created by Alexandr Bahno on 30.06.2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView { MovieHomeView() }
                .tabItem { Label("Home", systemImage: "film") }
                .tag(0)
            
            NavigationView { MovieSearchView() }
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
