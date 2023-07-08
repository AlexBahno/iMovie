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
    @Published private(set) var phase: DataFetchPhase<Movie?> = .empty
    var movie: Movie? {
        phase.value ?? nil
    }
    
    init(movieService: MovieService = MovieStore.shared) {
        self.movieService = movieService
    }
    
    func loadMovie(id: Int) async {
        if Task.isCancelled { return }
        
        phase = .empty
        
        do {
            let movie = try await self.movieService.fecthMovie(id: id)
            phase = .success(movie)
        } catch {
            phase = .failure(error)
        }
    }
}
