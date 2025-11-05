//
//  BarcodeScanner.swift
//  Book Scanner
//
//  Created by Israel Manzo on 4/29/24.
//

import SwiftUI
import UIKit
import AVFoundation

struct BarCodeScanner: UIViewControllerRepresentable {
    @Binding var isbn: String?
    @Binding var foundBooks: Books?
    
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .black
        context.coordinator.captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            fatalError("Could not capture video")
        }
        
        let videoInput: AVCaptureDeviceInput
        videoInput = try! AVCaptureDeviceInput(device: videoCaptureDevice)
        
        if context.coordinator.captureSession.canAddInput(videoInput) {
            context.coordinator.captureSession.addInput(videoInput)
        } else {
            print("Could not add input from session")
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if context.coordinator.captureSession.canAddOutput(metadataOutput) {
            context.coordinator.captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        } else {
            print("No output")
        }
        
        context.coordinator.previewLayer = AVCaptureVideoPreviewLayer(session: context.coordinator.captureSession)
        context.coordinator.previewLayer.frame = viewController.view.layer.bounds
        context.coordinator.previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(context.coordinator.previewLayer)
        
        DispatchQueue.global(qos: .background).async {
            context.coordinator.captureSession.startRunning()
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let parent: BarCodeScanner
        
        var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!
        
        init(_ parent: BarCodeScanner) {
            self.parent = parent
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard let metadataObject = metadataObjects.first,
                  let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            foundCode(of: stringValue)
            captureSession.stopRunning()
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func foundCode(of isbn: String) {
            print(isbn)
            parent.isbn = isbn
            
            // Search Book manager
            SearchBookManager.shared.search(isbn: isbn) { [weak self] books in
                DispatchQueue.main.async {
                    if let self {
                        self.parent.foundBooks = books
                    }
                }
            }
        }
    }
}
