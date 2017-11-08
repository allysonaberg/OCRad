//
//  ViewController.swift
//  realTimeOCR
//
//  Created by Allyson Aberg on 2017-11-04.
//  Copyright © 2017 Allyson Aberg. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
  
  @IBOutlet weak var itemLabel: UILabel!
  @IBOutlet weak var cameraLayer: UIView!
  
  private let handler = VNSequenceRequestHandler()
  fileprivate var lastObservation: vNDetectedObjectObservation
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    
    //PRAGMA: CAMERA STUFF
    //camera stuff
    let captureSession = AVCaptureSession()
    guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
    guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
    captureSession.addInput(input)
    captureSession.sessionPreset = .photo
    captureSession.startRunning()
    
    
    //displaying camera stuff
    let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    cameraLayer.layer.addSublayer(previewLayer)
    previewLayer.frame = cameraLayer.frame

    //PRAGRMA: HANDLING IMAGES TAKEN IN
    let dataOutput = AVCaptureVideoDataOutput()
    dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
    captureSession.addOutput(dataOutput)
    
  }
  
  //called everytime a camera frame is capture
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
    guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
    guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
    //IMAGE DETECTION
    
    
    //IMAGE RECOGNITION
    let request = VNCoreMLRequest(model: model) {(finishedReq, err) in
      //error checking
      guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
      
      guard let firstObservation = results.first else {return}
      
      print(firstObservation.identifier, firstObservation.confidence)
      DispatchQueue.main.async {
        let name = firstObservation.identifier.components(separatedBy: ",")[0]
        let confidence = firstObservation.confidence
        self.itemLabel.text = "\(name)" + "  " + "\(confidence)"
        self.itemLabel.bringSubview(toFront: self.view)
      }
    }
    
    try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

