//
//  MovieDetailState.swift
//  iMovie
//
//  Created by Alexandr Bahno on 02.07.2023.
//

import SwiftUI

@MainActor
class MovieDetailState: ObservableObject {
    private let movieService: MovieService
    @Published var movie: Movie?
    @Published var isLoading = false
    @Published var error: NSError?
    
    init(movieService: MovieService = MovieStore.shared) {
        self.movieService = movieService
    }
    
    func loadMovie(id: Int) async {
        self.movie = nil
        self.isLoading = true
        
        do {
            let movie = try await self.movieService.fecthMovie(id: id)
            self.movie = movie
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.error = error as NSError
        }
    }
}
