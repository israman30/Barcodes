//
//  ScannerViewController.swift
//  Book Scanner
//
//  Created by Israel Manzo on 10/26/25.
//

import UIKit
import AVFoundation

enum CameraError: String {
    case invalidDeviceInput
    case invalidScannedValue
}

protocol ScannerProtocol {
    func find(_ barcode: String)
    func surface(_ error: CameraError)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var scannerDelegate: ScannerProtocol?
    
    init(scannerDelegate: ScannerProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.scannerDelegate = scannerDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            scannerDelegate?.surface(.invalidDeviceInput)
            return
        }
        let videoInput: AVCaptureDeviceInput
        
        do {
            try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            scannerDelegate?.surface(.invalidDeviceInput)
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            scannerDelegate?.surface(.invalidScannedValue)
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13]
        } else {
            scannerDelegate?.surface(.invalidScannedValue)
            return
        }
        
        guard var previewLayer else { return }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
}

extension ScannerViewController {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let machineReadableCodeObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            scannerDelegate?.surface(.invalidScannedValue)
            return
        }
        guard let barcode = machineReadableCodeObject.stringValue else {
            scannerDelegate?.surface(.invalidDeviceInput)
            return
        }
        captureSession.stopRunning()
        scannerDelegate?.find(barcode)
    }
}
