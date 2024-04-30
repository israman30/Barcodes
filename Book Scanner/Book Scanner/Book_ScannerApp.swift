//
//  Book_ScannerApp.swift
//  Book Scanner
//
//  Created by Israel Manzo on 12/2/23.
//

import SwiftUI

@main
struct Book_ScannerApp: App {
    @StateObject private var dataController = DataController()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
