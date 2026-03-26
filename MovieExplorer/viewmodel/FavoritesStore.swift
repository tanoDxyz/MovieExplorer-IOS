//
//  FavoritesStore.swift
//  MovieExplorer
//
//  Created by syed tanveer hussain on 14/03/2026.
//


import SwiftUI
enum FavoritesStore {
    private static let key = "favoriteMovies"
    
    static func load() -> [MovieDetails] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let movies = try? JSONDecoder().decode([MovieDetails].self, from: data)
        else { return [] }
        return movies
    }
    
    static func save(_ movies: [MovieDetails]) {
        if let data = try? JSONEncoder().encode(movies) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    static func toggle(_ movie: MovieDetails) -> [MovieDetails] {
        var current = load()
        if let idx = current.firstIndex(of: movie) {
            current.remove(at: idx)
        } else {
            current.append(movie)
        }
        save(current)
        return current
    }
    
    static func movie(withID id: Int) -> MovieDetails? {
        load().first { $0.id == id }
    }
    
    static func isFavorite(id: Int) -> Bool {
        load().contains { $0.id == id }
    }
}
