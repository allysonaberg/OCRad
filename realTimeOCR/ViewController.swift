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
    view.layer.addSublayer(previewLayer)
    previewLayer.frame = view.frame
    
    //PRAGRMA: HANDLING IMAGES TAKEN IN
    let dataOutput = AVCaptureVideoDataOutput()
    dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
    captureSession.addOutput(dataOutput)
    
  }
  
  //called everytime a camera frame is capture
  func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    print("CAMERA CAPTURED")
    
    guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
    guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else {return}
    let request = VNCoreMLRequest(model: model) {(finishedReq, err) in
      //error checking
      print(finishedReq.results)
      guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
      
      guard let firstObservation = results.first else {return}
      
      print(firstObservation.identifier, firstObservation.confidence)
    }
//    try? VNImageRequestHandler(cgImage: , options: <#T##[VNImageOption : Any]#>).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
    try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

