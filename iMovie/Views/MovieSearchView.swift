//
//  MovieSearchView.swift
//  iMovie
//
//  Created by Alexandr Bahno on 05.07.2023.
//

import SwiftUI

struct MovieSearchView: View {
    
    @ObservedObject var movieSearchState = MovieSearchState()
    @ObservedObject var imageLoader = ImageLoader()

    
    var body: some View {
        List {
            SearchBarView(placeHolder: "Search movies", text: self.$movieSearchState.query)
                .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
            
            LoadingView(isLoading: self.movieSearchState.isLoading, error: self.movieSearchState.error) {
                Task {
                    await self.movieSearchState.search(query: self.movieSearchState.query)
                }
            }
            
            if self.movieSearchState.movies != nil {
                ForEach(self.movieSearchState.movies!) { movie in
                    NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
                        MovieSearchCard(movie: movie)
                    }
                }
            }
        }
        .onAppear {
            self.movieSearchState.startObserve()
        }
        .navigationTitle("Search")
    }
}

struct MovieSearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MovieSearchView()
        }
    }
}
