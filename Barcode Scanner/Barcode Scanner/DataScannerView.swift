//
//  ScannerView.swift
//  Barcode Scanner
//
//  Created by Israel Manzo on 4/23/24.
//

import SwiftUI
import VisionKit
import Foundation

struct DataScannerView: UIViewControllerRepresentable {
    
    @Binding var recognizedItems: [RecognizedItem]
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    let recognizedMultipleItems: Bool
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(recognizedDataTypes: [recognizedDataType], qualityLevel: .balanced, recognizesMultipleItems: recognizedMultipleItems, isGuidanceEnabled: true, isHighlightingEnabled: true)
        return vc
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedItems: $recognizedItems)
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        do {
            try uiViewController.startScanning()
        } catch {
            print("Something went wrong startScanning: \(error.localizedDescription)")
        }
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        
        @Binding var recognizedItems: [RecognizedItem]
        
        init(recognizedItems: Binding<[RecognizedItem]>) {
            self._recognizedItems = recognizedItems
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            print("did tap on: \(item)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            recognizedItems.append(contentsOf: addedItems)
            print("Did add itmes:\(addedItems)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            self.recognizedItems = recognizedItems.filter { item in
                !removedItems.contains(where: { $0.id == item.id} )
            }
            print("remove items: \(removedItems)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("Become unavailable with error: \(error.localizedDescription)")
        }
    }
}
