//
//  Moview.swift
//  iMovie
//
//  Created by Alexandr Bahno on 30.06.2023.
//

import Foundation
import CoreData
import SwiftUI

struct MovieResponse: Decodable {
    let results: [Movie]
}


struct Movie: Decodable, Identifiable, Hashable {
    
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: Int
    let title: String
    let backdropPath: String?
    let posterPath: String?
    let overview: String
    let voteAverage: Double
    let voteCount: Double
    let runtime: Int?
    let releaseDate: String?
    
    let genres: [MovieGenre]?
    let credits: MovieCredit?
    let videos: MovieVideoResponse?
    let reviews: MovieReviewResponse?
    let similar: MovieRecommendationResponse?
    
    static private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    static private let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()
    
    var backdropURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(backdropPath ?? "")")!
    }
    
    var posterURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath ?? "")")!
    }
    
    var genreText: String {
        genres?.first?.name ?? "n/a"
    }
    
    var ratingText: String {
        let rating = Int(voteAverage)
        let ratingText = (0...rating).reduce("") { (acc, _) -> String in
            return acc + "★"
        }
        return ratingText
    }
    
    var scoreText: String {
        guard ratingText.count > 0 else {
            return "n/a"
        }
        return "\(ratingText.count)/10"
    }
    
    var yearText: String {
        guard let releaseDate = self.releaseDate, let date = Utils.dateFormatter.date(from: releaseDate) else {
            return "n/a"
        }
        return Movie.yearFormatter.string(from: date)
    }
    
    var durationText: String {
        guard let runtime = self.runtime, runtime > 0 else {
            return "n/a"
        }
        return Movie.durationFormatter.string(from: TimeInterval(runtime) * 60) ?? "n/a"
    }
    
    var cast: [MovieCast]? {
        credits?.cast
    }
    
    var crew: [MovieCrew]? {
        credits?.crew
    }
    
    var directors: [MovieCrew]? {
        crew?.filter { $0.job.lowercased() == "director" }
    }
    
    var producers: [MovieCrew]? {
        crew?.filter { $0.job.lowercased() == "producer" }
    }
    
    var screenWriters: [MovieCrew]? {
        crew?.filter { $0.job.lowercased() == "story" }
    }
    
    var youtubeTrailers: [MovieVideo]? {
        videos?.results.filter { $0.youtubeURL != nil }
    }
    
    var comments: [MovieReview]? {
        reviews?.results.filter { !$0.content.isEmpty }
    }
    
    var similarMovie: [Movie]? {
        similar?.results
    }
}


struct MovieGenre: Decodable, Hashable {
    let name: String
}

struct MovieCredit: Decodable, Hashable {
    let cast: [MovieCast]
    let crew: [MovieCrew]
}

struct MovieCast: Decodable, Identifiable, Hashable {
    let id: Int
    let character: String
    let name: String
}

struct MovieCrew: Decodable, Identifiable, Hashable {
    let id: Int
    let job: String
    let name: String
}

struct MovieVideoResponse: Decodable, Hashable {
    let results: [MovieVideo]
}

struct MovieVideo: Decodable, Identifiable, Hashable {
    let id: String
    let key: String
    let name: String
    let site: String
    
    var youtubeURL: URL? {
        guard site == "YouTube" else {
            return nil
        }
        return URL(string: "https://youtube.com/watch?v=\(key)")
    }
}

struct MovieReviewResponse: Decodable, Hashable {
    let results: [MovieReview]
}

struct MovieReview: Identifiable, Decodable, Hashable {
    let id: String
    let content: String
    let createdAt: String
    let updatedAt: String?
    let authorDetails: AuthorDetails
}

struct AuthorDetails: Decodable, Hashable {
    let username: String
    let avatarPath: String?
    
    var avatarURL: URL {
        if let avatarPath = avatarPath {
            if avatarPath.contains("gravatar") {
                return URL(string: avatarPath)!
            }
            return URL(string: "https://image.tmdb.org/t/p/w500\(avatarPath)")!
        }
        return URL(string: "https://image.tmdb.org/t/p/w500")!
    }
}

struct MovieRecommendationResponse: Decodable, Hashable {
    let results: [Movie]
}

