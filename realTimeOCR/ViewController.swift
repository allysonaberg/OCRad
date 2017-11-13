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
  
  //PRAGMA MARK: VARS/DECLARATIONS
  @IBOutlet weak var itemLabel: UILabel!
  @IBOutlet weak var cameraLayer: UIView!
  
  private lazy var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
  fileprivate var lastObservation: VNDetectedObjectObservation?
  private let handler = VNSequenceRequestHandler()

  //camera stuff
  private lazy var captureSession: AVCaptureSession = {
    let session = AVCaptureSession()
    session.sessionPreset = AVCaptureSession.Preset.photo
    guard let backCamera = AVCaptureDevice.default(for: .video),
    let input = try? AVCaptureDeviceInput(device: backCamera) else {return session}
    session.addInput(input)
    return session
  }()
  
  //tracker stuff
  lazy var highlightView: UIView = {
    let view = UIView()
    view.layer.borderColor = UIColor.red.cgColor
    view.layer.borderWidth = 4;
    view.backgroundColor = .clear
    return view
  }()
  
  
  //PRAGMA MARK: FCNS
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(highlightView)
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(tapAction))
    view.addGestureRecognizer(tapGestureRecognizer)
    captureSession.startRunning()
    
    //displaying camera stuff
    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    cameraLayer.layer.addSublayer(previewLayer)
    previewLayer.frame = cameraLayer.frame

    //handling images taken in
    let dataOutput = AVCaptureVideoDataOutput()
    dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
    captureSession.addOutput(dataOutput)
  }
  
  
  
  //called everytime a camera frame is captured
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
    guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
    let observation = lastObservation else {return}
    guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
    
    
    //IMAGE RECOGNITION
    let request = VNCoreMLRequest(model: model) {(finishedReq, err) in
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
    
    //IMAGE DETECTION
    let requestDetection = VNTrackObjectRequest(detectedObjectObservation: observation) { (request, error) in
      self.handle(request, error: error)
    }
    requestDetection.trackingLevel = .accurate
    do {
      try self.handler.perform([request], on: pixelBuffer)
    }
    catch {
      print(error)
    }
    
    //running the two different requests
    try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([requestDetection])
  }

  //PRAGMA MARK: ACTIONS
  
  @objc private func tapAction(recognizer: UITapGestureRecognizer) {
    highlightView.frame.size = CGSize(width: 120, height: 120)
    highlightView.center = recognizer.location(in: view)
    
    let originalRect = highlightView.frame
    var convertedRect = previewLayer.metadataOutputRectConverted(fromLayerRect: originalRect)
    convertedRect.origin.y = 1 - convertedRect.origin.y
    
    lastObservation = VNDetectedObjectObservation(boundingBox: convertedRect)
  }
  
  
  fileprivate func handle(_ request: VNRequest, error: Error?) {
    DispatchQueue.main.async {
      guard let newObservation = request.results?.first as? VNDetectedObjectObservation else {
        return
      }
      self.lastObservation = newObservation
      
      var transformedRect = newObservation.boundingBox
      transformedRect.origin.y = 1 - transformedRect.origin.y
      let convertedRect = self.previewLayer.layerRectConverted(fromMetadataOutputRect: transformedRect)
      self.highlightView.frame = convertedRect
    }
  }
}
