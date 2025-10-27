//
//  HomeScannerView.swift
//  Book Scanner
//
//  Created by Israel Manzo on 10/26/25.
//

import SwiftUI

//struct ScannerView: UIViewControllerRepresentable {
//    @Binding var scannedCode: String
//    
//    func makeUIViewController(context: Context) -> some UIViewController {
//        <#code#>
//    }
//}

struct HomeScannerView: View {
    
    @State private var scannedCodeString = ""
    
    var body: some View {
        VStack {
            Label("Scanned Code: \(scannedCodeString)", image: scannedCodeString.isEmpty ? "barcode.viewfinder" : "barcode")
                .contentTransition(.symbolEffect(.replace))
                .font(.title2)
                .fontDesign(.rounded)
                .fontWeight(.bold)
                .padding()
            
            Text(scannedCodeString.isEmpty ? "No Code Found" : scannedCodeString)
                .font(.largeTitle)
                .fontDesign(.rounded)
                .fontWeight(.light)
                .foregroundStyle(scannedCodeString.isEmpty ? .red : .green)
        }
    }
}

#Preview {
    HomeScannerView()
}
