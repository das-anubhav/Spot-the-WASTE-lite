//
//  ViewController.swift
//  Spot the WASTE lite
//
//  Created by ANUBHAV DAS on 06/08/20.
//  Copyright © 2020 Captain Anubhav. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController {
    
    let captureSession = AVCaptureSession()


    @IBOutlet weak var cameraView: UIView!
    
    
    @IBOutlet weak var descLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        cameraView.layer.cornerRadius = 15
//        descLabel.layer.cornerRadius = 15
        
        self.staringTheCam()
    }
    
    //MARK: - Starting the camera
    
    func staringTheCam() {
        
        //Set session preset
        captureSession.sessionPreset = .photo
        
        //Capturing Device
        guard let capturingDevice = AVCaptureDevice.default(for: .video) else { return }
        
        //Capture Input
        guard let capturingInput = try? AVCaptureDeviceInput(device: capturingDevice) else { return }
        
        //Adding input to capture session
        captureSession.addInput(capturingInput)

        //Data output
        let cameraDataOutput = AVCaptureVideoDataOutput()
        cameraDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "outputVideo"))
        captureSession.addOutput(cameraDataOutput)
        
        //Construct a camera preview layer
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        //Set the frame
        cameraPreviewLayer.frame = cameraView.bounds
        
        //Add this preview layer to sublayer of view
        cameraView.layer.addSublayer(cameraPreviewLayer)
        
        //Start the session
        captureSession.startRunning()
    }
    
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            
            
            //Get pixel buffer
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
                
            }
            
            //get model
            guard let resNetModel = try? VNCoreMLModel(for: ALLWaste_1().model) else { return }
            
            //Create a coreml request
            let requestCoreML = VNCoreMLRequest(model: resNetModel) { (vnReq, err) in
                
                //handling error and request
                
                DispatchQueue.main.async {
                    if err == nil{
                        
                        
                        
                        guard let capturedRes = vnReq.results as? [VNClassificationObservation] else { return }
                        
                        guard let firstObserved = capturedRes.first else { return }
                        
                        print(firstObserved.identifier, firstObserved.confidence)
                      
                        
                        if firstObserved.identifier.contains("O"){
                            
                            self.descLabel.backgroundColor = .yellow
                            self.descLabel.text = String(format: "It's a Organic WASTE %.2f%%", (firstObserved.confidence)*100, firstObserved.identifier)
                            self.descLabel.textColor = .blue
                            
                        }
                        if firstObserved.identifier.contains("E") {
                            
                            self.descLabel.backgroundColor = .red
                            self.descLabel.text = String(format: "It's a E-WASTE %.2f%%", (firstObserved.confidence)*100)
                            self.descLabel.textColor = .white
                        }
                        if firstObserved.identifier.contains("M") {
                            
                            self.descLabel.backgroundColor = .orange
                            self.descLabel.text = String(format: "It's a Metal WASTE %.2f%%", (firstObserved.confidence)*100)
                            self.descLabel.textColor = .black
                        }
                        if firstObserved.identifier.contains("P") {
                            
                            self.descLabel.backgroundColor = .cyan
                            self.descLabel.text = String(format: "It's a Paper WASTE %.2f%%", (firstObserved.confidence)*100)
                            self.descLabel.textColor = .blue
                        }
                        if firstObserved.identifier.contains("G") {
                            
                            self.descLabel.backgroundColor = .green
                            self.descLabel.text = String(format: "It's a Glass WASTE %.2f%%", (firstObserved.confidence)*100)
                            self.descLabel.textColor = .black
                        }
                        if firstObserved.identifier.contains("H") {
                            
                            
                            self.descLabel.backgroundColor = .brown
                            self.descLabel.text = String(format: "It's not a WASTE %.2f%%", (firstObserved.confidence)*100)
                            self.descLabel.textColor = .yellow
                        }
                        if firstObserved.identifier.contains("PL") {
                            
                            self.descLabel.backgroundColor = .black
                            self.descLabel.textColor = .white
                            self.descLabel.text = String(format: "It's a Plastic WASTE %.2f%%", (firstObserved.confidence)*100)
                        }
                        
//                        self.descLabel.text = String(format: "This may be %.2f%% %@", (firstObserved.confidence)*100, firstObserved.identifier)
                        
                        
                        
                    }
                    
                }
                
            }
            
            
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([requestCoreML])
            
        }
        
        
        
    }


