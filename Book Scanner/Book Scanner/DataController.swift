//
//  DataController.swift
//  Book Scanner
//
//  Created by Israel Manzo on 4/29/24.
//

import Foundation
import CoreData
import SwiftUI

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "BookScanner")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error {
                print("Core data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
