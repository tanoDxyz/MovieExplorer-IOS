//
//  FavoritesScreen.swift
//  MovieExplorer
//
//  Created by syed tanveer hussain on 14/03/2026.
//

import SwiftUI

struct FavoritesScreen: View {
    @StateObject private var vm = HomeScreenViewModel()
    
    @State private var clickedMovie:MovieCardParams? =  nil
    @State private var favorites:[MovieDetails] = []
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("favorites").font(.titleLarge)
            ShowFavorites()
        }.frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .topLeading).padding()
            .navigationDestination(item:$clickedMovie) { movie in
                return MovieDetailsView(movieDetails: movie)
                    .environmentObject(vm)
            }.onAppear() {
                favorites = vm.getFavorites()
            }
    }
    
    func onMovieClicked(movieParams:MovieCardParams) {
        self.clickedMovie = movieParams
    }
    @ViewBuilder private func ShowFavorites() -> some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
        if(favorites.isEmpty) {
            ContentUnavailableView(
                "No Favorites",
                systemImage: "magnifyingglass",
                description: Text("Try adding some movies to favorites.")
            )
        }
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns,spacing: 3) {
                ForEach(favorites, id: \.self) { movie in
                    let id = movie.id
                    let title = movie.title
                    let imageURL = movie.posterUrl?.absoluteString ?? ""
                    MovieCardView(
                        movieCardParams: MovieCardParams.create(
                            id: id,
                            title: title,
                            imageURL: imageURL,
                            width: 100,
                            height: 150,
                            cornerRadius: 12,
                            onClick: onMovieClicked
                        )
                    )
                }
            }
        }
        
    }
}

#Preview {
    FavoritesScreen()
}
