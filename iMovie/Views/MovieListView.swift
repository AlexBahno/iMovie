//
//  MovieListView.swift
//  iMovie
//
//  Created by Alexandr Bahno on 02.07.2023.
//

import SwiftUI

struct MovieListView: View {
    
    @ObservedObject private var nowPlayingState = MovieListState()
    @ObservedObject private var upcomingState = MovieListState()
    @ObservedObject private var topRatedState = MovieListState()
    @ObservedObject private var popularState = MovieListState()
    
    var body: some View {
        NavigationView {
            List {
                Group {
                    if nowPlayingState.movies != nil {
                        MovieThumbnailCarouselView(title: "Now Playing", movies: nowPlayingState.movies!, thumbnailType: .poster())
                    } else {
                        LoadingView(isLoading: nowPlayingState.isLoading, error: nowPlayingState.error) {
                            Task {
                                await self.nowPlayingState.loadMovies(with: .nowPlaying)
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 8, trailing: 0))
                .listRowSeparator(.hidden)
                
                
                Group {
                    if upcomingState.movies != nil {
                        MovieThumbnailCarouselView(title: "Upcoming", movies: upcomingState.movies!, thumbnailType: .backdrop)
                    } else {
                        LoadingView(isLoading: upcomingState.isLoading, error: upcomingState.error) {
                            Task {
                                await self.upcomingState.loadMovies(with: .upcoming)
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowSeparator(.hidden)
                
                Group {
                    if topRatedState.movies != nil {
                        MovieThumbnailCarouselView(title: "Top Rated", movies: topRatedState.movies!, thumbnailType: .backdrop)
                    } else {
                        LoadingView(isLoading: topRatedState.isLoading, error: topRatedState.error) {
                            Task {
                                await self.topRatedState.loadMovies(with: .topRated)
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowSeparator(.hidden)
                
                Group {
                    if popularState.movies != nil {
                        MovieThumbnailCarouselView(title: "Popular", movies: popularState.movies!, thumbnailType: .backdrop)
                    } else {
                        LoadingView(isLoading: popularState.isLoading, error: popularState.error) {
                            Task {
                                await self.popularState.loadMovies(with: .popular)
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationTitle("iMovie")
        }
        .onAppear {
            Task {
                await self.nowPlayingState.loadMovies(with: .nowPlaying)
                await self.upcomingState.loadMovies(with: .upcoming)
                await self.topRatedState.loadMovies(with: .topRated)
                await self.popularState.loadMovies(with: .popular)
            }
        }
    }
}

struct MovieListView_Previews: PreviewProvider {
    static var previews: some View {
        MovieListView()
    }
}
