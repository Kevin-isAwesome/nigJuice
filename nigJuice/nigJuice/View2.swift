//
//  View2.swift
//  nigJuice
//
//  Created by Kevin Vo on 3/10/17.
//  Copyright © 2017 Kevin Vo. All rights reserved.
//

import UIKit
import AVFoundation

class View2: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet var cameraView: UIView!
    @IBOutlet var button: UIButton!
    @IBOutlet var libraryButton: UIButton!
    @IBOutlet var modeButton: UIButton!
    @IBOutlet var clearButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    
    @IBOutlet var processButton: UIButton!

    @IBOutlet weak var imageView: UIImageView!
    

    @IBOutlet var cameraBackground: UIImageView!
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let deviceSession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInDuoCamera,.builtInTelephotoCamera,.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified)
        
        for device in (deviceSession?.devices)! {
            
            if device.position == AVCaptureDevicePosition.front {
                
                do {
                    
                    let input = try AVCaptureDeviceInput(device: device)
                    
                    if captureSession.canAddInput(input){
                        captureSession.addInput(input)
                        
                        if captureSession.canAddOutput(sessionOutput){
                            captureSession.addOutput(sessionOutput)
                            
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                            previewLayer.connection.videoOrientation = .portrait
                            
                            cameraView.layer.addSublayer(previewLayer)
                            cameraView.addSubview(cameraBackground)
                            cameraView.addSubview(button)
                            cameraView.addSubview(libraryButton)
                            cameraView.addSubview(modeButton)
                            
                            previewLayer.position = CGPoint (x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
                            previewLayer.bounds = cameraView.frame
                            
                            captureSession.startRunning()
                            
                        }
                    }
                    
                    
                } catch let avError {
                    print(avError)
                }
                
                
            }
            
        }
        
    }

    @IBAction func takePhoto(_ sender: Any) {
        
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String : previewPixelType, kCVPixelBufferWidthKey as String : 160, kCVPixelBufferHeightKey as String : 160]
        
        settings.previewPhotoFormat = previewFormat
        sessionOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
    @IBOutlet var tempImageview: UIImageView!
    
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?)
    {
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer,
            let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            
            let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: nil)
            let dataProvider = CGDataProvider(data: imageData as! CFData)
            
            let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.absoluteColorimetric)
            
            
            let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.leftMirrored)
            
            
            
            print(UIScreen.main.bounds.width)
            
            
            self.tempImageview.image = image
            self.tempImageview.isHidden = false
            self.view.addSubview(tempImageview)
            self.view.addSubview(clearButton)
            self.view.addSubview(processButton)
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

            
            
        } else {
            
        }
        
        
    }
    @IBAction func libraryClicked(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
        {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
            
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!){
        tempImageview.image = image
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func clearClicked(_ sender: UIButton) {
        if (tempImageview.image != nil) {
            tempImageview.image = nil
            clearButton.removeFromSuperview()
            processButton.removeFromSuperview()
            saveButton.removeFromSuperview()
        }
        else {
            return
        }
        
    }
    @IBAction func processButton(_ sender: Any) {
        if (tempImageview.image == nil) {
            failNotice()
        }
        else {
            let imageData = UIImageJPEGRepresentation(tempImageview.image!, 0.9)
            let strBase64:String = imageData!.base64EncodedString(options: .lineLength64Characters)
            let params = ["image":[ "content_type": "image/jpeg", "filename":"test.jpg", "file_data": strBase64]]
            var request = URLRequest(url: URL(string: "http://10.99.6.117:5000/todo/api/v1.0/tasks")!)
            do{
                try request.httpBody = JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions() )
            }
            catch{
                print("didnt work")
            }
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let postString = "{\"title\":\"Success\",\"description\":\" \"}"
            print(postString)
            request.httpBody = postString.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString)")
                print(request)
            }
            jsonSuccess(mes: "Success")
            task.resume()
            processButton.removeFromSuperview()
            self.view.addSubview(saveButton)
        }
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        if (tempImageview.image != nil) {
            tempImageview.image = nil
            clearButton.removeFromSuperview()
            processButton.removeFromSuperview()
            saveButton.removeFromSuperview()
        }
        else {
            return
        }
    }
    
    
    
    
    func failNotice() {
        let alertController = UIAlertController(title: "Error", message: "You need to select an image!", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func jsonSuccess(mes: String) {
        let alertController = UIAlertController(title: "Success!!", message: "You have succeeded!!" + mes, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }


    
   
    

    


}
