//
//  HomeScreenView.swift
//  MovieExplorer
//
//  Created by syed tanveer hussain on 09/02/2026.
//

import SwiftUI

struct HomeScreenView: View {
    @StateObject private var vm = HomeScreenViewModel()
    @State private var clickedMovie:MovieCardParams? =  nil
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("appName").font(.titleLarge)
                Text("popular").font(.bodyMedium).padding(.top, .margin36)
                PopularMoviesList()
                Text("trending").font(.bodyMedium).padding(.top, .margin36)
                TrendingMoviesList()
            }.frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .padding().task(id: "loadOnce") {

                vm.loadPopularMoviesData()
                vm.loadTrendingMovies()
            }
            .navigationDestination(item:$clickedMovie) { movie in
                return MovieDetailsView(movieDetails: movie).environmentObject(vm)
            }
        }
    }

    func onMovieClicked(movieParams:MovieCardParams) {
        self.clickedMovie = movieParams
    }
    
    @ViewBuilder
    func TrendingMoviesList() -> some View {
        
        if vm.loadingTrendingMovies {
            ProgressView {
                Text("Loading")
            }.frame(maxWidth: .infinity,maxHeight: 150,alignment: .center)
        } else if let errorWhileLoadingTrendingMovies = vm
            .errorLoadingTrendingMovies
        {
            Text("Error occured \(errorWhileLoadingTrendingMovies)")
        } else {
            if let trendingMovies = vm.popularMoviesData {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(trendingMovies, id: \.self) { movie in
                            MovieCardView(
                                movieCardParams: MovieCardParams.create(
                                    id:movie?.id ?? 0,
                                    title: movie?.title ?? "",
                                    imageURL: (movie?.posterUrl?.absoluteString)
                                    ?? "",
                                    width: 100,
                                    height: 150,
                                    cornerRadius: 12,
                                    onClick: onMovieClicked
                                )
                            )
                        }
                    }
                    .padding(.horizontal)
                }.frame(height: 200)

            } else {
                EmptyView()
            }
        }
    }
    
    
    @ViewBuilder
    func PopularMoviesList() -> some View {
        if vm.loadingPopularMovies {
            ProgressView {
                Text("Loading")
            }.frame(maxWidth: .infinity,maxHeight: 150,alignment: .center)
        } else if let errorWhileLoadingPopularMovies = vm
            .errorLoadingPopularMovies
        {
            Text("Error occured \(errorWhileLoadingPopularMovies)")
        } else {
            if let popularMovies = vm.popularMoviesData {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(popularMovies, id: \.self) { movie in
                            MovieCardView(
                                movieCardParams: MovieCardParams.create(
                                    id:movie?.id ?? 0,
                                    title: movie?.title ?? "",
                                    imageURL: (movie?.posterUrl?.absoluteString)
                                    ?? "",
                                    width: 100,
                                    height: 150,
                                    cornerRadius: 12,
                                    onClick: onMovieClicked
                                )
                            )
                        }
                    }
                    .padding(.horizontal)
                }.frame(height: 200)

            } else {
                EmptyView()
            }
        }
    }
}


#Preview {
    HomeScreenView()
}
