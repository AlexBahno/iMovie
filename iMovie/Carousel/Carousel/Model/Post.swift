//
//  Post.swift
//  Carousel
//
//  Created by Alexandr Bahno on 30.06.2023.
//

import SwiftUI

//Post model and sample data

struct Post: Identifiable {
    var id = UUID().uuidString
    var postImage: String
}
