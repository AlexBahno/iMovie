//
//  AppDelegate.swift
//  iMovie
//
//  Created by Alexandr Bahno on 02.07.2023.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UITableView.appearance().separatorStyle = .none
        return true
    }
}
