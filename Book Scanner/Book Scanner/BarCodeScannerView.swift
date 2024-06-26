//
//  BarCodeScannerView.swift
//  Book Scanner
//
//  Created by Israel Manzo on 12/6/23.
//

import SwiftUI
import AVFoundation

struct BarCodeScannerView: View {
    
    @State private var captureSession: AVCaptureSession?
    @State private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private func startSession() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.frame = UIScreen.main.bounds
            DispatchQueue.global(qos: .background).async {
                self.captureSession?.startRunning()
            }
            
        } catch {
            print(error)
        }
    }
    
    var body: some View {
        ZStack {
            VideoCaptureView(
                captureSession: $captureSession,
                videoPreviewLayer: $videoPreviewLayer
            )
            .edgesIgnoringSafeArea(.all)
            BarcodeOverlay(
                captureSession: $captureSession
            )
            .edgesIgnoringSafeArea(.all)
        }
        .onAppear(perform: startSession)
    }
}

struct BarcodeOverlay: View {
    @Binding var captureSession: AVCaptureSession?
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 300, height: 200)
                .overlay(
                    Text("Scan Barcode Here")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                )
                .background(Color.black.opacity(0.5))
                .cornerRadius(20)
                .onTapGesture {
                    DispatchQueue.global(qos: .background).async {
                        self.captureSession?.startRunning()
                    }
                    
                }
                .onAppear {
                    self.captureSession?.stopRunning()
                }
        }
    }
}

struct VideoCaptureView: UIViewRepresentable {
    @Binding var captureSession: AVCaptureSession?
    @Binding var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        videoPreviewLayer?.removeFromSuperlayer()
        if let videoPreviewLayer = videoPreviewLayer {
            uiView.layer.addSublayer(videoPreviewLayer)
        }
    }
}

#Preview {
    BarCodeScannerView()
}
