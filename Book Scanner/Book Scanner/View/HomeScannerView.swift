//
//  HomeScannerView.swift
//  Book Scanner
//
//  Created by Israel Manzo on 10/26/25.
//

import SwiftUI

struct ScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        ScannerViewController(scannerDelegate: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scannerView: self)
    }
    
    class Coordinator: NSObject, ScannerProtocol {
        private var scannerView: ScannerView
        
        init(scannerView: ScannerView) {
            self.scannerView = scannerView
        }
        
        func didCaptureCode(_ code: String) {
            scannerView.scannedCode = code
        }
        
        func find(_ barcode: String) {
            scannerView.scannedCode = barcode
        }
        
        func surface(_ error: CameraError) {
            print(error)
        }
    }
}

struct HomeScannerView: View {
    
    @State private var scannedCodeString = ""
    
    var body: some View {
        NavigationView {
            VStack {
                ScannerView(scannedCode: $scannedCodeString)
                    .frame(maxWidth: 300, minHeight: 20, maxHeight: 250)
                Label("", image: scannedCodeString.isEmpty ? "barcode.viewfinder" : "barcode")
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
            .navigationTitle("Barcode")
        }
    }
}

#Preview {
    HomeScannerView()
}
