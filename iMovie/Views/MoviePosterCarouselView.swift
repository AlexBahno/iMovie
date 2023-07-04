//
//  MoviePosterCarouselView.swift
//  iMovie
//
//  Created by Alexandr Bahno on 02.07.2023.
//

import SwiftUI

struct MoviePosterCarouselView: View {
    let title: String
    let movies: [Movie]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(movies) { movie in
                        NavigationLink {
                            MovieDetailView(movieId: movie.id)
                        } label: {
                            MoviePosterCard(movie: movie)
                                .padding(.leading, movie.id == self.movies.first!.id ? 16 : 0)
                                .padding(.trailing, movie.id == self.movies.last!.id ? 16 : 0)
                        }
                    }
                }
            }
        }
    }
}

struct MoviePosterCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        MoviePosterCarouselView(title: "Now Playing", movies: Movie.stubbedMovies)
    }
}
