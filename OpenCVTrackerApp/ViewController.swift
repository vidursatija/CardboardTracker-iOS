//
//  ViewController.swift
//  OpenCVTrackerApp
//
//  Created by Vidur Satija on 04/03/16.
//  Copyright © 2016 Aromatic Studios. All rights reserved.
//

import UIKit
import AVFoundation
import MultipeerConnectivity

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, MPCManagerDelegate {
    
    //@property (nonatomic, strong) AVCaptureSession *session;
    //@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
    var session:AVCaptureSession!
    var previewLayer:AVCaptureVideoPreviewLayer!
    var handRecog = OpenCVWrapper()
    var mpcManager: MPCManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mpcManager = MPCManager()
        mpcManager.delegate = self
        mpcManager.advertiser.startAdvertisingPeer()
        mpcManager.browser.startBrowsingForPeers()
        //setupCaptureSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func invitationWasReceived(_ fromPeer: String) {
        self.mpcManager.invitationHandler(true, mpcManager.session)
    }
    
    func connectedWithPeer(_ peerID: MCPeerID) {
        setupCaptureSession()
        mpcManager.advertiser.stopAdvertisingPeer()
    }
    
    func setupCaptureSession()
    {
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetMedium
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        var input:AVCaptureDeviceInput!
        
        do
        {
            input = try AVCaptureDeviceInput.init(device: device)
        }catch _{
            print("Error in I/P")
        }
        
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        session.addOutput(output)
        
        let queue = DispatchQueue(label: "myQueue", attributes: [])
        
        output.setSampleBufferDelegate(self, queue: queue)
        
        output.videoSettings = NSDictionary(object: NSNumber(value: kCVPixelFormatType_32BGRA as UInt32), forKey:kCVPixelBufferPixelFormatTypeKey as! NSCopying) as! [AnyHashable: Any]
        
        startCapturingWithSession(session)
        
        //setSession(session)
        
    }
    
    func startCapturingWithSession(_ captureSession: AVCaptureSession)
    {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        let layerRect = self.view.layer.bounds
        self.previewLayer.bounds = layerRect
        self.previewLayer.position = CGPoint(x: layerRect.midX, y: layerRect.midY)
        let CameraView = UIView()
        self.view.addSubview(CameraView)
        self.view .sendSubview(toBack: CameraView)
        
        CameraView.layer.addSublayer(self.previewLayer)
        
        captureSession.startRunning()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        connection.videoOrientation = AVCaptureVideoOrientation.landscapeRight
        
        let image = imageFromSampleBuffer(sampleBuffer)
        
        let processed = handRecog.processImage(withOpenCV: image)
        
        /*let imageData = UIImagePNGRepresentation(processed)
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        let imagePath = documentsDirectory.stringByAppendingPathComponent(NSString.localizedStringWithFormat("%@.png", "cached") as String)
        imageData?.writeToFile(imagePath, atomically: false)*/
        
        let messageDictionary: [String: String] = ["x": String(Int(processed.x)), "y": String(Int(processed.y))]
        
        mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: mpcManager.session.connectedPeers[0] as MCPeerID)
            
        
    }
    
    func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage
    {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        CVPixelBufferLockBaseAddress(imageBuffer!, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer!)
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!)
        let width = CVPixelBufferGetWidth(imageBuffer!)
        let height = CVPixelBufferGetHeight(imageBuffer!)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bInfo)
        let quartzImage = context?.makeImage()
        CVPixelBufferUnlockBaseAddress(imageBuffer!, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        let image = UIImage(cgImage: quartzImage!)
        
        return image
        
    }

}

