//
//  CameraViewController.swift
//  Feed-iOS
//
//  Created by Akhila Ballari on 1/27/18.
//  Copyright © 2018 Akhila Ballari. All rights reserved.
//

import UIKit
import AVKit
import Vision

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var captureButtonView: UIView!
    @IBOutlet weak var border: UIView!
    var captureSession: AVCaptureSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        captureButtonView.layer.cornerRadius = captureButtonView.frame.size.width/2
        captureButtonView.clipsToBounds = true
        
        border.layer.cornerRadius = border.frame.size.width/2
        border.clipsToBounds = true

        border.layer.borderWidth = 2
        border.layer.borderColor = UIColor.white.cgColor
        border.backgroundColor = .clear
        
        captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        
        labelView.layer.zPosition = 1
        captureButtonView.layer.zPosition = 1
        border.layer.zPosition = 1
        
        self.view.bringSubview(toFront: labelView)

    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            print(firstObservation.identifier, firstObservation.confidence)
            
            DispatchQueue.main.async {
                self.label.text = "\(firstObservation.identifier) \(firstObservation.confidence * 100)"
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    @IBAction func captureImage(_ sender: Any) {
        captureSession.stopRunning()
        self.performSegue(withIdentifier: "goToSend", sender: self)
    }
    
}

