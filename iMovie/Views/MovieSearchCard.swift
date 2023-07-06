//
//  MovieSearchCard.swift
//  iMovie
//
//  Created by Alexandr Bahno on 06.07.2023.
//

import SwiftUI

struct MovieSearchCard: View {
    
    @ObservedObject var imageLoader = ImageLoader()
    let movie: Movie
    
    var body: some View {
        HStack (alignment: .center) {
            ZStack {
                if self.imageLoader.image != nil {
                    Image(uiImage: self.imageLoader.image!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(4)
                        .shadow(radius: 4)
                } else {
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .cornerRadius(8)
                        .shadow(radius: 4)
                }
            }
            .frame(width: 50, height: 75)
            VStack (alignment: .leading) {
                Text(movie.title)
                    .lineLimit(1)
                Text(movie.yearText)
            }
        }
        .onAppear {
            self.imageLoader.loadImage(with: self.movie.posterURL)
        }
    }
}

struct MovieSearchCard_Previews: PreviewProvider {
    static var previews: some View {
        MovieSearchCard(movie: Movie.stubbedMovie)
    }
}
