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
  @IBOutlet weak var valueLabel: UILabel!
  @IBOutlet weak var itemLabel: UILabel!
  @IBOutlet weak var cameraLayer: UIView!
  
  private lazy var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
  fileprivate var lastObservation: VNDetectedObjectObservation?
  private let handler = VNSequenceRequestHandler()
  var requests = [VNRequest]()
  let dispatchQueueML = DispatchQueue(label: "com.hw.dispatchqueueml")
  
  
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
  
  //PRAGMA MARK: FXNS
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(highlightView)
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(tapAction))
    view.addGestureRecognizer(tapGestureRecognizer)
    
    //displaying camera stuff
    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    cameraLayer.layer.addSublayer(previewLayer)
    previewLayer.frame = cameraLayer.frame
    
    //handling images taken in
    let dataOutput = AVCaptureVideoDataOutput()
    dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
    captureSession.addOutput(dataOutput)
    captureSession.startRunning()

  }
  
  
  
  //called everytime a camera frame is captured
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
    guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
    guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
    
    
    //IMAGE RECOGNITION
    performRecognition(pixelBuffer: pixelBuffer, model: model)
    
    //IMAGE DETECTION AND TRACKING?
    performTracking(pixelBuffer: pixelBuffer)
    
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
  
  fileprivate func performRecognition(pixelBuffer: CVPixelBuffer, model: VNCoreMLModel) {
    let request = VNCoreMLRequest(model: model, completionHandler: recognitionCompleteHandler)
    request.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop //make it easier to detect object in center
    requests = [request]
    dispatchQueueML.sync {
      updateCoreML(pixelBuffer: pixelBuffer)
    }
    
  }
  
  fileprivate func performTracking(pixelBuffer: CVPixelBuffer) {
    guard let observation = lastObservation else {return}
    let requestDetection = VNTrackObjectRequest(detectedObjectObservation: observation) { (request, error) in
      self.handle(request, error: error)
    }
    requestDetection.trackingLevel = .accurate
    do {
      try self.handler.perform([requestDetection], on: pixelBuffer)
    }
    catch {
      print(error)
    }
//    try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([requestDetection])
  }
  
  
  func updateCoreML(pixelBuffer: CVPixelBuffer) {
    
    // Get Camera Image as RGB
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    
    // Prepare CoreML/Vision Request
    let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
    // let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage!, orientation: myOrientation, options: [:]) // Alternatively; we can convert the above to an RGB CGImage and use that. Also UIInterfaceOrientation can inform orientation values.
    
    // Run Image Request
    do {
      try imageRequestHandler.perform(self.requests)
    } catch {
      print(error)
    }
    
  }
  
  func recognitionCompleteHandler(request: VNRequest, error: Error?) {
    if error != nil {
      print("Error: " + (error?.localizedDescription)!)
      return
    }
    guard let observations = request.results else {
      print("No results")
      return
    }
    
    // Get Classifications
    let classifications = observations[0...1]
      .flatMap({ $0 as? VNClassificationObservation })
      .map({ "\($0.identifier) \(String(format:"- %.2f", $0.confidence))" })
      .joined(separator: "\n")
    
    
    DispatchQueue.main.async {
      // Print Classifications
      print(classifications)
      print("--")
      
      // Store the latest prediction
      var objectName:String = "…"
      var assurance:String = ""
      objectName = classifications.components(separatedBy: "-")[0]
      objectName = objectName.components(separatedBy: ",")[0]
      assurance = classifications.components(separatedBy: "\n")[0]
      assurance = assurance.components(separatedBy: "-")[1]
      self.itemLabel.text = objectName
      self.valueLabel.text = assurance
      self.itemLabel.isHidden = false
      self.valueLabel.isHidden = false
    }
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

