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
       
        MovieThumbnailCarouselView(title: "", movies: movieMarkedState.movies)
        .frame(maxWidth: .infinity, alignment: .top)
        .task { loadMovies() }
        .overlay(DataFetchPhaseOverlayView(phase: movieMarkedState.phase, retryAction: { loadMovies() }))
        .listStyle(.plain)
        .navigationTitle("Saved")
    }
    
    private func loadMovies() {
        Task { await movieMarkedState.loadMovies(ids:savedMovies.map({ Int($0.id) })) }
    }
}

struct MoviesMarkedView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesMarkedView()
    }
}
