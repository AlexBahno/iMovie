//
//  DataFetchPhase.swift
//  iMovie
//
//  Created by Alexandr Bahno on 07.07.2023.
//

import Foundation

enum DataFetchPhase<V> {
    
    case empty
    case success(V)
    case failure(Error)
    
    var value: V? {
        if case .success(let value) = self {
            return value
        }
        return nil
    }
}
