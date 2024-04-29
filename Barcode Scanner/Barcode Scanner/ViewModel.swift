//
//  ViewModel.swift
//  Barcode Scanner
//
//  Created by Israel Manzo on 4/23/24.
//

import SwiftUI
import VisionKit
import AVKit

enum ScanType: String {
    case barcode
    case text
}

enum ScannerAccesStatus {
    case undetermined
    case cameraAccessDenied
    case cameraUnavailable
    case scannerAvailable
    case scannerUnavailable
}

@MainActor
final class ViewModel: ObservableObject {
    
    @Published var scannerAccesStatus: ScannerAccesStatus = .undetermined
    @Published var recognizedItems: [RecognizedItem] = []
    @Published var scanType: ScanType = .barcode
    @Published var textContentType: DataScannerViewController.TextContentType?
    @Published var recognizedMulitpleItems = true
    
    var headerText: String {
        if recognizedItems.isEmpty {
            return "Scanning \(scanType.rawValue)"
        } else {
            return "Recognized \(recognizedItems.count) item(s)"
        }
    }
    
    var dataScannerViewId: Int {
        var hasher = Hasher()
        hasher.combine(scanType)
        hasher.combine(recognizedMulitpleItems)
        if let textContentType {
            hasher.combine(textContentType)
        }
        return hasher.finalize()
    }
    
    var recognizedDataType: DataScannerViewController.RecognizedDataType {
        scanType == .barcode ? .barcode() : .text(textContentType: textContentType)
    }
    
    private var isScannerAvailable: Bool {
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    
    func requestScannerAccesStatus() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            scannerAccesStatus = .cameraUnavailable
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            scannerAccesStatus = isScannerAvailable ? .scannerAvailable : .scannerUnavailable
        case .restricted, .denied:
            scannerAccesStatus = .cameraAccessDenied
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                scannerAccesStatus = isScannerAvailable ? .scannerAvailable : .scannerUnavailable
            } else {
                scannerAccesStatus = .cameraAccessDenied
            }
        default:
            break
        }
    }
}
