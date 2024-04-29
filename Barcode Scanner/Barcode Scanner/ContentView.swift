//
//  ContentView.swift
//  Barcode Scanner
//
//  Created by Israel Manzo on 4/21/24.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var vm = ViewModel()
    
    var body: some View {
        HomeView()
            .environmentObject(vm)
            .task {
                await vm.requestScannerAccesStatus()
            }
    }
}

#Preview {
    ContentView()
}


