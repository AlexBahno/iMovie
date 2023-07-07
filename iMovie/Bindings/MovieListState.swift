//
//  MovieListState.swift
//  iMovie
//
//  Created by Alexandr Bahno on 02.07.2023.
//

import SwiftUI

@MainActor
class MovieListState: ObservableObject {
    @Published var movies: [Movie]?
    @Published var isLoading = false
    @Published var error: NSError?
    
    private let movieService: MovieService
    
    init(movieService: MovieService = MovieStore.shared) {
        self.movieService = movieService
    }
    
    func loadMovies(with endpoint: MovieListEndpoint) async {
        self.movies = nil
        self.isLoading = true
        
        do {
            let movies = try await movieService.fetchMovies(from: endpoint)
            self.isLoading = false
            self.movies = movies
        } catch {
            self.isLoading = false
            self.error = error as NSError
        }
    }
}
