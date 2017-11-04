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

class ViewController: UIViewController {

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
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

