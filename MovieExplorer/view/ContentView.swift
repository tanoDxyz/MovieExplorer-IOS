//
//  ContentView.swift
//  MovieExplorer
//
//  Created by syed tanveer hussain on 30/01/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                
                HomeScreenView()
                
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
        
            NavigationStack {
                SearchScreenView()
            }
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
        
            
            NavigationStack {
                FavoritesScreen()
            }
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favorite")
                }
        }
        
       
    }
}

#Preview {
    ContentView()
}
