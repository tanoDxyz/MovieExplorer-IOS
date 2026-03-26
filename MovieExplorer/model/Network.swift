//
//  Network.swift
//  MovieExplorer
//
//  Created by syed tanveer hussain on 10/02/2026.
//

import Foundation
import TMDb
// https://github.com/adamayoung/TMDb
class TmdbApiManager {
    private let tmdbClient = TMDbClient(
        apiKey:"f848da95b53bc887353a8f7d526b20ed"
    )
    
    func popularMovies() async throws -> Array<MovieDetails?> {
        let popularMovies = try await tmdbClient.discover.movies(
            sortedBy: .popularity(descending: true)
        ).results
        
        var results = Array<MovieDetails?>(
            repeating: nil,
            count: popularMovies.count
        )
        
        try await withThrowingTaskGroup(of: (Int, MovieDetails).self) { group in
            for (index, movie) in popularMovies.enumerated() {
                group.addTask { [self] in
                    let movieUrl = await self.generatePosterURLFor(
                        posterPath: movie.posterPath
                    )
                    let id = movie.id
                    let popularity = movie.popularity
                    let title = movie.title
                    let description = movie.overview
                    let releaseDate = movie.releaseDate
                    let details = MovieDetails(
                        posterUrl: movieUrl,
                        id: id,
                        title: title,
                        description: description,
                        year:Calendar.current
                            .component(.year, from: releaseDate ?? Date()),
                        score: popularity ?? 0
                    )
                    return (index, details)
                }
            }
            
            for try await (index, details) in group {
                results[index] = details
            }
        }
        
        return results.compactMap { $0 }
        
    }
    
    func trendingMovies()async throws -> Array<MovieDetails> {
        let trendingMovies = try await tmdbClient.discover.movies(
            sortedBy: .revenue(descending: true)
        ).results
        
        var results = Array<MovieDetails?>(
            repeating: nil,
            count: trendingMovies.count
        )
        
        try await withThrowingTaskGroup(of: (Int, MovieDetails).self) { group in
            for (index, movie) in trendingMovies.enumerated() {
                group.addTask { [self] in
                    let movieUrl = await self.generatePosterURLFor(
                        posterPath: movie.posterPath
                    )
                    
                    let id = movie.id
                    let popularity = movie.popularity
                    let title = movie.title
                    let description = movie.overview
                    let releaseDate = movie.releaseDate
                    let details = MovieDetails(
                        posterUrl: movieUrl,
                        id: id,
                        title: title,
                        description: description,
                        year:Calendar.current
                            .component(.year, from: releaseDate ?? Date()),
                        score: popularity ?? 0
                    )
                    return (index, details)
                }
            }
            
            for try await (index, details) in group {
                results[index] = details
            }
        }
        
        return results.compactMap { $0 }
    }
    func generatePosterURLFor(posterPath:URL?) async -> URL? {
        guard let posterPath = posterPath else {
            return nil
        }
        do {
            let config = try await tmdbClient.configurations.apiConfiguration()
            let posterURL = config.images.posterURL(
                for: posterPath,
                idealWidth: 500
            )
            return posterURL
        }catch {
            return nil
        }
    }
    
    
    func getYoutubeVideoId(movieId:Int)async ->String? {
        do {
            // likely API shape (inferred from service naming):
            let response = try await tmdbClient.movies.videos(forMovie: movieId)
            
            let youtubeKey = response.results.first {
                ($0.site.lowercased() == "youtube") && !(
                    $0.key.isEmpty
                )
            }?.key
            return youtubeKey
        }catch {
            return nil
        }
    }
    
    func searchForMovie(query:String) async -> [MovieDetails?]? {
        let job = BackgroundJob<Array<MovieDetails?>?>()
        do {
            let searchResults = try await self.tmdbClient.search.searchMovies(
                query: query
            )
            
            job.start {
                var movies:[MovieDetails?]? = Array(repeating: nil, count: searchResults.results.count)
                for (index,movie) in searchResults.results.enumerated(){
                    let moviePosterUrl = await self.generatePosterURLFor(
                        posterPath: movie.posterPath
                    )
                    let movieDetails = MovieDetails(
                        posterUrl: moviePosterUrl,
                        id: movie.id,
                        title: movie.title,
                        description: movie.overview,
                        year: Calendar.current
                            .component(.year, from:movie.releaseDate ?? Date()),
                        score: movie.popularity ?? 0
                    )
                    movies?.insert(movieDetails, at: index)
                }
                return movies
            }
            let result = try await job.value()
            return result
        } catch {
            // will catch here ?
            return nil
        }
        
    }
    
}







enum APIError: Error {
    case invalidURL
    case networkFailed
    case decodingFailed
}

protocol Movie {
    var posterUrl: URL? { get }
    var id: Int { get }
    var title: String { get }
    var description: String { get }
    var year: Int { get }
    var score: Double { get }
}
struct MovieDetails: Movie,Codable,Hashable {
    var posterUrl: URL?
    var id: Int
    var title: String
    var description: String
    var year: Int
    var score: Double
}

