//
//  ScanViewController.swift
//  IDScanner
//
//  Created by Sanjeewa Gunathilake on 5/8/21.
//

import AVFoundation
import UIKit
import Vision

// ScannerViewDelegate
protocol ScannerViewDelegate: AnyObject {
    func didFindScannedTextAndImage(scanData:ScanData)
}

class ScannerViewController: UIViewController {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    // ScannerView delegate
    public weak var delegate: ScannerViewDelegate?
    
    // scan data model
    private var scanData = ScanData()
    
    // mask to detect boarders
    private var boarderMaskLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        // initiate capture session
        captureSession = AVCaptureSession()
        
        // checking device capabilities for scanning
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            showScanError()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            // define supported barcode types
            metadataOutput.metadataObjectTypes = [.code128, .code39]
        } else {
            showScanError()
            return
        }
        
        // video capture preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // setup camera output for capture snapshot
        self.setCameraOutput()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // reset scanData
        scanData.codeString = nil
        scanData.image = nil
        
        // start capture session
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // stop capture session
        captureSession.stopRunning()
    }
    
    
    // MARK: - Utility methods
    override var prefersStatusBarHidden: Bool {
        return true
    }
    // preview screen orientation lock to potrait
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // error in scanning
    func showScanError() {
        // show alert to user
        showDistructiveAlert(title: Constants.Scan_Error_Title, message: Constants.Scan_Error_Title, buttonText: Constants.Generic_Ok)
        captureSession = nil
    }
    
    
    // Rectangle Detection
    private func detectRectangle(in image: CVPixelBuffer) {
        removeMask()
        let request = VNDetectRectanglesRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                
                guard let results = request.results as? [VNRectangleObservation] else { return }
                self.removeMask()
                
                guard let rect = results.first else{return}
                self.drawBoundingBox(rect: rect)
                
                // check for scanned code
                if(self.scanData.codeString != nil){
                    // set captured image
                    self.scanData.image = self.imageExtraction(rect, from: image)
                    self.delegate?.didFindScannedTextAndImage(scanData: self.scanData)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })
        
        //Set the value for the detected rectangle
        request.minimumAspectRatio = VNAspectRatio(0.3)
        request.maximumAspectRatio = VNAspectRatio(0.9)
        request.minimumSize = Float(0.3)
        request.maximumObservations = 1
        
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        try? imageRequestHandler.perform([request])
    }
    
    // Draw Bounding Box
    func drawBoundingBox(rect : VNRectangleObservation) {
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.previewLayer.bounds.height)
        let scale = CGAffineTransform.identity.scaledBy(x: self.previewLayer.bounds.width, y: self.previewLayer.bounds.height)
        
        let bounds = rect.boundingBox.applying(scale).applying(transform)
        
        createLayer(in: bounds)
    }
    
    private func createLayer(in rect: CGRect) {
        boarderMaskLayer = CAShapeLayer()
        boarderMaskLayer.frame = rect
        boarderMaskLayer.cornerRadius = 10
        boarderMaskLayer.opacity = 1
        boarderMaskLayer.borderColor = UIColor.systemYellow.cgColor
        boarderMaskLayer.borderWidth = 6.0
        previewLayer.insertSublayer(boarderMaskLayer, at: 1)
        
    }
    
    func removeMask() {
        boarderMaskLayer.removeFromSuperlayer()
    }
    
    // Extract image
    func imageExtraction(_ observation: VNRectangleObservation, from buffer: CVImageBuffer) -> UIImage {
        var ciImage = CIImage(cvImageBuffer: buffer)
        
        let topLeft = observation.topLeft.scaled(to: ciImage.extent.size)
        let topRight = observation.topRight.scaled(to: ciImage.extent.size)
        let bottomLeft = observation.bottomLeft.scaled(to: ciImage.extent.size)
        let bottomRight = observation.bottomRight.scaled(to: ciImage.extent.size)
        
        // pass filters to extract the image
        ciImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: topLeft),
            "inputTopRight": CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight": CIVector(cgPoint: bottomRight),
        ])
        
        let context = CIContext()
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        let output = UIImage(cgImage: cgImage!)
        
        //return image
        return output
    }
    
}

//MARK: AVCaptureMetadata Delegate
extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate{
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let codeString = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            // set codeString
            scanData.codeString = codeString
        }
        
        dismiss(animated: true)
    }
}

//MARK: AVCaptureVideo Delegate
extension ScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    
    private func setCameraOutput() {
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        
        guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
              connection.isVideoOrientationSupported else { return }
        
        connection.videoOrientation = .portrait
    }
    
    func captureOutput(_ output: AVCaptureOutput,didOutput sampleBuffer: CMSampleBuffer,from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        self.detectRectangle(in: frame)
    }
}

extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width,
                       y: self.y * size.height)
    }
}
