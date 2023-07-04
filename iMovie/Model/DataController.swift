//
//  DataController.swift
//  iMovie
//
//  Created by Alexandr Bahno on 30.06.2023.
//

import Foundation

class DataController: ObservableObject {
    
    @Published var movies = [Movie]()
    
    let headers = [
      "X-RapidAPI-Key": "b1019a2933msh914afd677b6b4c2p147253jsn070d7ce695e6",
      "X-RapidAPI-Host": "movie-database-alternative.p.rapidapi.com"
    ]
    
    func requ() {
        let request = NSMutableURLRequest(url: NSURL(string: "https://movie-database-alternative.p.rapidapi.com/?s=Avengers%20Endgame&r=json&page=1")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print("Failed to get data: \(error.localizedDescription)")
            }
            
            let httpResponse = response as? HTTPURLResponse
            print(httpResponse)
            
            guard let data = data else {
                print("Failed to get data")
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let movies = try! decoder.decode([Movie].self, from: data)
            print(movies)
        })
        dataTask.resume()
    }
}
