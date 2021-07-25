//
//  ScanbrewApp.swift
//  Scanbrew
//
//  Created by Jan Krzempek on 27/06/2021.
//

import SwiftUI
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

@main
struct ScanbrewApp: App {
    
    init() {
       FirebaseApp.configure()
     }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
