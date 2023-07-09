//
//  MarkedMoviesView.swift
//  iMovie
//
//  Created by Alexandr Bahno on 08.07.2023.
//

import SwiftUI

struct MoviesMarkedView: View {
    
    @StateObject private var movieMarkedState = MovieMarkedState()
    @FetchRequest(sortDescriptors: [SortDescriptor(\.id)]) var savedMovies: FetchedResults<SavedMovie>
    
    var body: some View {
       
        VStack {
            MovieMarkedCarousel(title: "", movies: movieMarkedState.movies.sorted(by: {
                $0.voteAverage > $1.voteAverage
            }))
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .task { loadMovies() }
        .overlay(DataFetchPhaseOverlayView(phase: movieMarkedState.phase, retryAction: { loadMovies() }))
        .listStyle(.plain)
        .navigationTitle("Saved")
    }
    
    private func loadMovies() {
        let ids: Set<Int> = Set(savedMovies.map({ Int($0.id) }))
        Task { await movieMarkedState.loadMovies(ids:ids) }
    }
}

struct MovieMarkedCarousel: View {
    let title: String
    let movies: [Movie]
    var thumbnailType: MovieThumbnailType = .poster()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 16) {
                    ForEach(movies) { movie in
                        NavigationLink(destination: MovieDetailView(movieId: movie.id, movieTitle: movie.title)) {
                            VStack {
                                MovieThumbnailView(movie: movie, thumbnailType: thumbnailType)
                                    .frame(width: 206, height: 309)
                                Text(movie.title)
                                    .font(.headline)
                                    .frame(width: 204)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                HStack {
                                    Text(movie.ratingText)
                                        .foregroundColor(.yellow)
                                    Text(movie.scoreText)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }
}


struct MoviesMarkedView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesMarkedView()
    }
}
