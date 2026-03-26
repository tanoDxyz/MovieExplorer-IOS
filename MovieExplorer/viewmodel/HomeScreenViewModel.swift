
//
//  HomeScreenViewModel.swift
//  MovieExplorer
//
//  Created by syed tanveer hussain on 16/02/2026.
//

import Foundation
import Combine
@MainActor
class HomeScreenViewModel: ObservableObject {
    private let apiManager = TmdbApiManager()
    @Published var popularMoviesData: [MovieDetails?]? = nil
    @Published var loadingPopularMovies = false
    @Published var errorLoadingPopularMovies: String? = nil
    
    private var loadPopularTask: Task<Void, Never>? = nil
    
    private var loadTrendingTask:Task<Void,Never>? = nil
    @Published var loadingTrendingMovies = false
    @Published var errorLoadingTrendingMovies:String? = nil
    @Published var trendingMoviesData:Array<MovieDetails?>? = nil

    func isFavorite(id:Int) -> Bool {
        return FavoritesStore.isFavorite(id: id)
    }
    
    func movie(id:Int) -> MovieDetails? {
        return FavoritesStore.movie(withID: id)
    }
    func getFavorites() -> [MovieDetails] {
        return FavoritesStore.load()
    }
    func toggleFavorite(_ movie: MovieDetails)->[MovieDetails] {
        return FavoritesStore.toggle(movie)
    }
    func loadPopularMoviesData() {
        // Cancel any previous in-flight task
        loadPopularTask?.cancel()
        
        loadPopularTask = Task {
            loadingPopularMovies = true
            defer { loadingPopularMovies = false }
            
            do {
                let movies = try await apiManager.popularMovies()
                
                // Respect cancellation before updating state
                if Task.isCancelled { return }
                
                popularMoviesData = movies
                errorLoadingPopularMovies = nil
            } catch is CancellationError {
                // task was cancelled — ignore or handle quietly
                errorLoadingPopularMovies = "Task Canceled."
            } catch {
                errorLoadingPopularMovies = error.localizedDescription
                print("failed to load movies \(error)")
            }
        }
    }
    
    func loadTrendingMovies() {
        loadTrendingTask?.cancel()
        loadTrendingTask = Task {
            loadingTrendingMovies = true
            defer {loadingTrendingMovies = false}
            
            do {
                let movies = try await apiManager.trendingMovies()
                if Task.isCancelled {return}
                self.trendingMoviesData = movies
            }catch is   CancellationError{
                
            } catch {
                errorLoadingTrendingMovies = error.localizedDescription
                print("failed to load movies \(error)")
            }
        }
    }
    
    
    func loadYoutubeKeyIdForVideo(id:Int)async -> String? {
        return await apiManager.getYoutubeVideoId(movieId: id)
    }
    
    func searchForMovie(query:String) async ->[MovieDetails?]? {
        return await apiManager.searchForMovie(query: query)
    }
    deinit {
        loadPopularTask?.cancel()
        loadTrendingTask?.cancel()
    }
    
    
}
