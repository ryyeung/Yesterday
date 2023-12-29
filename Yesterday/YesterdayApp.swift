//
//  YesterdayApp.swift
//  Yesterday
//
//  Created by Ryan Yeung on 12/25/23.
//

import SwiftUI

@main
struct YesterdayApp: App {
    
    @StateObject var album = Album()
    
    
    
    var body: some Scene {
        WindowGroup {
            HomePage()
            
        }
    }
}
