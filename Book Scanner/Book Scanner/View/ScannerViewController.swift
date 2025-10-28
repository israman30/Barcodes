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

protocol ScannerProtocol: AnyObject {
    func find(_ barcode: String)
    func surface(_ error: CameraError)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var videoInput: AVCaptureDeviceInput!
    weak var scannerDelegate: ScannerProtocol?
    
    init(scannerDelegate: ScannerProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.scannerDelegate = scannerDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        addGetureRecognizers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let previewLayer else {
            scannerDelegate?.surface(.invalidDeviceInput)
            return
        }
        previewLayer.frame = view.bounds
    }
    
    func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else{
            scannerDelegate?.surface(.invalidDeviceInput)
            return
        }
        
        do {
            try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            scannerDelegate?.surface(.invalidDeviceInput)
            return
        }
        
        if captureSession.canAddInput(videoInput){
            captureSession.addInput(videoInput)
        } else {
            scannerDelegate?.surface(.invalidScannedValue)
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .qr] // This ean8 y 13 barcodes
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func addGetureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapFocus))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTapFocus(_ gesture: UITapGestureRecognizer) {
        let pointView = gesture.location(in: view)
        guard let pointInCamera = previewLayer?.captureDevicePointConverted(fromLayerPoint: pointView) else { return }
        
        let videoDevice = videoInput.device
        do {
            try videoDevice.lockForConfiguration()
            
            if videoDevice.isFocusPointOfInterestSupported {
                videoDevice.focusPointOfInterest = pointInCamera
            }
            
            if videoDevice.isFocusModeSupported(.autoFocus) {
                videoDevice.focusMode = .autoFocus
            }
            videoDevice.unlockForConfiguration()
        } catch {
            print("Could not lock device for configuration: \(error.localizedDescription)")
        }
    }
}

extension ScannerViewController {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            scannerDelegate?.surface( .invalidScannedValue)
            return
        }
        guard let barcode = object.stringValue else {
            scannerDelegate?.surface( .invalidDeviceInput)
            return
        }
        captureSession.stopRunning()
        scannerDelegate?.find(barcode)
    }
}

