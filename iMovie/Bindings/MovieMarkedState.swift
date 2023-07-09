//
//  MovieMarkedState.swift
//  iMovie
//
//  Created by Alexandr Bahno on 08.07.2023.
//

import Foundation

@MainActor
class MovieMarkedState: ObservableObject {
     
    @Published private(set) var phase: DataFetchPhase<Set<Movie>> = .empty
    private let movieService: MovieService = MovieStore.shared

    var movies: Set<Movie> {
        phase.value ?? []
    }
    
    func loadMovies(ids: Set<Int>) async {
        if Task.isCancelled { return }
        
        phase = .empty
        
        do {
            let markedMovies = try await fetchMoviesById(ids)
            if Task.isCancelled { return }
            phase = .success(markedMovies)
        } catch {
            if Task.isCancelled { return }
            phase = .failure(error)
        }
    }
    
    
    private func fetchMoviesById(_ ids: Set<Int>) async throws -> Set<Movie> {
        let results: [Result<Movie, Error>] = await withTaskGroup(of: Result<Movie, Error>.self) { group in
            for id in ids {
                group.addTask {
                    await self.fetchMovieById(id: id)
                }
            }
            
            var results = [Result<Movie, Error>]()
            
            for await result in group {
                results.append(result)
            }
            return results
        }
        
        var movies: Set<Movie> = []
        var errors = [Error]()
        
        results.forEach { result in
            switch result {
            case .success(let movie):
                movies.insert(movie)
            case .failure(let error):
                errors.append(error)
            }
        }
        
        if errors.count == results.count, let error = errors.first {
            throw error
        }
        
        return movies
        //.sorted { $0.voteAverage > $1.voteAverage}
    }
    
    private func fetchMovieById(id : Int) async -> Result<Movie, Error> {
        do {
            let movie = try await movieService.fecthMovie(id: id)
            return .success(movie)
        } catch {
            return .failure(error)
        }
    }
}
