//
//  MovieDetailView.swift
//  iMovie
//
//  Created by Alexandr Bahno on 02.07.2023.
//

import SwiftUI

struct MovieDetailView: View {
    let movieId: Int
    @ObservedObject private var movieDetailState = MovieDetailState()
    
    var body: some View {
        ZStack {
            LoadingView(isLoading: self.movieDetailState.isLoading, error: self.movieDetailState.error) {
                Task {
                    await self.movieDetailState.loadMovie(id: self.movieId)
                }
            }
            
            if movieDetailState.movie != nil {
                MovieDetailListView(movie: self.movieDetailState.movie!)
            }
        }
        .navigationTitle(movieDetailState.movie?.title ?? "")
        .onAppear {
            Task {
                await self.movieDetailState.loadMovie(id: self.movieId)
            }
        }
    }
}


struct MovieDetailListView: View {
    
    let movie: Movie
    @State private var selectedTrailer: MovieVideo?
    
    var body: some View {
        List {
            Group {
                MovieDetailImage(imageURL: self.movie.backdropURL)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                HStack {
                    Text(movie.genreText)
                    Text("·")
                    Text(movie.yearText)
                    Text(movie.durationText)
                }.lineLimit(1)
                
                Text(movie.overview)
                HStack {
                    if !movie.ratingText.isEmpty {
                        Text(movie.ratingText).foregroundColor(.yellow)
                    }
                    Text(movie.scoreText)
                }
                
                Divider()
                
                HStack(alignment: .top, spacing: 4) {
                    if movie.cast != nil && movie.cast!.count > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Starring").font(.headline)
                            ForEach(self.movie.cast!.prefix(9)) { cast in
                                Text(cast.name)
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        Spacer()
                    }
                    
                    if movie.crew != nil && movie.crew!.count > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            if movie.directors!.count > 0 {
                                Text("Director(s)").font(.headline)
                                ForEach(self.movie.directors!.prefix(2)) { director in
                                    Text(director.name)
                                }
                            }
                            
                            if movie.producers != nil && movie.producers!.count > 0 {
                                Text("Producer(s)").font(.headline)
                                    .padding(.top)
                                ForEach(self.movie.producers!.prefix(2)) { producer in
                                    Text(producer.name)
                                }
                            }
                            
                            if movie.screenWriters != nil && movie.screenWriters!.count > 0 {
                                Text("Sceenwriter(s)").font(.headline)
                                    .padding(.top)
                                ForEach(movie.screenWriters!.prefix(2)) { screenWriter in
                                    Text(screenWriter.name)
                                }
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                }
                Divider()
                
                if movie.youtubeTrailers != nil && movie.youtubeTrailers!.count > 0 {
                    Text("Trailers").font(.headline)
                    
                    ForEach(movie.youtubeTrailers!.reversed().prefix(5)) { trailer in
                        Button {
                            self.selectedTrailer = trailer
                        } label: {
                            HStack {
                                Text(trailer.name)
                                Spacer()
                                Image(systemName: "play.circle.fill")
                                    .foregroundColor(Color(uiColor: .systemBlue))
                            }
                        }
                    }
                }
            }
            .listRowSeparator(.hidden)
            .sheet(item: self.$selectedTrailer) { trailer in
                SafariView(url: trailer.youtubeURL!)
            }
        }
    }
}

struct MovieDetailImage: View {
    
    @ObservedObject private var imageLoader = ImageLoader()
    let imageURL: URL
    
    var body: some View {
        ZStack {
            Rectangle().fill(.gray.opacity(0.3))
            if self.imageLoader.image != nil {
                Image(uiImage: self.imageLoader.image!)
                    .resizable()
            }
        }
        .aspectRatio(16/9, contentMode: .fit)
        .onAppear {
            self.imageLoader.loadImage(with: self.imageURL)
        }
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MovieDetailView(movieId: Movie.stubbedMovie.id)
        }
    }
}
