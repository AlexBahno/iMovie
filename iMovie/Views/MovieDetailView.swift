//
//  MovieDetailView.swift
//  iMovie
//
//  Created by Alexandr Bahno on 02.07.2023.
//

import SwiftUI

struct MovieDetailView: View {
    
    let movieId: Int
    let movieTitle: String
    @StateObject private var movieDetailState = MovieDetailState()
    @State private var selectedTrailerURL: URL?
    @FetchRequest(sortDescriptors: [SortDescriptor(\.id)]) var savedMovies: FetchedResults<SavedMovie>
    
    var isSaved: Bool {
        return !savedMovies.filter({ $0.id == movieId }).isEmpty
    }
    
    var body: some View {
        List {
            if let movie = movieDetailState.movie {
                MovieDetailImage(imageURL: movie.backdropURL)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                
                MovieDetailListView(movie: movie, selectedTrailerURL: $selectedTrailerURL, isSaved: isSaved)
            }
        }
        .listStyle(.plain)
        .task {
            loadMovie()
        }
        .overlay(DataFetchPhaseOverlayView(
            phase: movieDetailState.phase,
            retryAction: loadMovie)
        )
        .sheet(item: $selectedTrailerURL) {
            SafariView(url: $0).edgesIgnoringSafeArea(.bottom)
        }
        .navigationTitle(movieTitle)
    }
    
    private func loadMovie() {
        Task { await self.movieDetailState.loadMovie(id:movieId) }
    }
}


struct MovieDetailListView: View {
    
    var movie: Movie
    @Binding var selectedTrailerURL: URL?
    @State var isSaved: Bool
    @Environment (\.managedObjectContext) var managedObjContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.id)]) var savedMovies: FetchedResults<SavedMovie>
    
    
    var body: some View {
        movieDescriptionSection.listRowSeparator(.visible)
        movieCastSection.listRowSeparator(.hidden)
        movieTrailerSection
        reviewsSection
        if let similar = movie.similarMovie {
            MovieThumbnailCarouselView(title: "Similar", movies: similar)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .padding(.vertical)
                .listRowSeparator(.hidden, edges: .bottom)
        }
    }
    
    
    private var movieDescriptionSection: some View {
        VStack (alignment: .leading, spacing: 16) {
            Text(movieGenreYearDurationText)
                .font(.headline)
                .lineLimit(1)
            Text(movie.overview)
            HStack {
                if !movie.ratingText.isEmpty {
                    Text(movie.ratingText).foregroundColor(.yellow)
                }
                HStack {
                    Text(movie.scoreText)
                    Spacer()
                    Button {
                        saveMovie()
                    } label: {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 25))
                    }

                }
            }
        }
        .padding(.vertical)
    }
    
    private func saveMovie() {
        if isSaved {
            guard let movie = savedMovies.first(where: { $0.id == self.movie.id }) else { return }
            managedObjContext.delete(movie)
            DataController().save(context: managedObjContext)
            isSaved.toggle()
            return
        }
        DataController().saveMovie(movieId: movie.id, context: managedObjContext)
        isSaved.toggle()
    }
    
    private var movieCastSection: some View {
        HStack(alignment: .top, spacing: 4) {
            if let cast = movie.cast, !cast.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Starring").font(.headline)
                    ForEach(cast.prefix(9)) { Text($0.name) }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
            
            if let crew = movie.crew, !crew.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    if let directors = movie.directors, !directors.isEmpty {
                        Text("Director(s)").font(.headline)
                        ForEach(directors.prefix(2)) { Text($0.name) }
                    }
                    
                    if let producers = movie.producers, !producers.isEmpty {
                        Text("Producer(s)").font(.headline)
                            .padding(.top)
                        ForEach(producers.prefix(2)) { Text($0.name) }
                    }
                    
                    if let screenWriters = movie.screenWriters, !screenWriters.isEmpty {
                        Text("Sceenwriter(s)").font(.headline)
                            .padding(.top)
                        ForEach(screenWriters.prefix(2)) { Text($0.name) }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical)
    }
    
    @ViewBuilder
    private var movieTrailerSection: some View {
        if let trailers = movie.youtubeTrailers, !trailers.isEmpty {
            Text("Trailers").font(.headline)
            ForEach(trailers.reversed().prefix(5)) { trailer in
                Button {
                    guard let url = trailer.youtubeURL else { return }
                    selectedTrailerURL = url
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
    
    @ViewBuilder
    private var reviewsSection: some View {
        if let reviews = movie.comments, !reviews.isEmpty {
            Text("Reviews").font(.headline)
                .listRowSeparator(.hidden)
                .padding(.top)
            ForEach(reviews.prefix(10)) { review in
                MovieReviewRow(review: review)
            }
        }
    }
    
    
    private var movieGenreYearDurationText: String {
        "\(movie.genreText) · \(movie.yearText) · \(movie.durationText)"
    }
}

struct MovieReviewRow: View {
    let review: MovieReview
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
        NavigationLink {
            MovieReviewDetail(review: review)
        } label: {
            HStack (alignment: .top) {
                VStack (alignment: .center) {
                    ZStack {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 32))
                        if let image = imageLoader.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
                    .onAppear { imageLoader.loadImage(with: review.authorDetails.avatarURL) }
                    
                    Text(review.authorDetails.username)
                        .lineLimit(1)
                        .font(.subheadline)
                        .padding(.top, 8)
                }
                .frame(width: 70)
                Text(review.content)
                    .multilineTextAlignment(.leading)
                    .lineLimit(5)
            }
        }
    }
}

struct MovieReviewDetail: View {
    @StateObject private var imageLoader = ImageLoader()
    let review: MovieReview
    
    var body: some View {
        HStack (alignment: .center) {
            ScrollView {
                VStack (alignment: .leading) {
                    HStack (alignment: .bottom) {
                        ZStack {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 42))
                            if let image = imageLoader.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 70, height: 70)
                                    .scaledToFit()
                            }
                        }
                        .onAppear {
                            imageLoader.loadImage(with: review.authorDetails.avatarURL)
                        }
                        
                        Text(review.authorDetails.username)
                            .font(.title2)
                            .padding(.top, 8)
                        
                        Spacer()
                        
                        Text("Created " + review.createdAt.prefix(10))
                            .font(.headline)
                    }.padding(.vertical)
                    Text(review.content)
                        .padding(.bottom)
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle("Review")
    }
}

struct MovieDetailImage: View {
    
    @StateObject private var imageLoader = ImageLoader()
    let imageURL: URL
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3)
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
            }
        }
        .aspectRatio(16/9, contentMode: .fit)
        .onAppear { imageLoader.loadImage(with: imageURL) }
    }
}

extension URL: Identifiable {
    public var id: Self { self }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MovieDetailView(movieId: Movie.stubbedMovie.id, movieTitle: "The Godfather")
        }
    }
}
