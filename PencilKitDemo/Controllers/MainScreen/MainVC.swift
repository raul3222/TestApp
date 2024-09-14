//
//  MainVC.swift
//  PencilKitDemo
//
//  Created by Raul Shafigin on 13.09.2024.
//

import UIKit
import CoreImage
import AVFoundation
import Photos
import PencilKit
import FirebaseAuth

enum Filters: String {
    case defaults
    case grayscale = "CIColorControls"
    case sepia = "CISepiaTone"
}

class MainVC: UIViewController, PKCanvasViewDelegate {
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var takePhotoBtn: CameraButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var galleryBtn: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var previewImgView: UIImageView!
    @IBOutlet weak var pickerContainer: UIView!
    
    let photoOutput = AVCapturePhotoOutput()
    let canvas = PKCanvasView()
    let captureModesList = ["Default", "Sepia", "Gray"]
    
    var previewImage: UIImage?
    var selectedFilter: Filters = .grayscale
   
    var cameraLayer: AVCaptureVideoPreviewLayer!
    var flashMode: AVCaptureDevice.FlashMode = .auto
    var captureDevice: AVCaptureDevice!
    var cameraModePicker: UIPickerView!
    var rotationAngle: CGFloat! = -90  * (.pi/180)
     
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        cameraModePicker = UIPickerView()
        cameraModePicker.dataSource = self
        cameraModePicker.delegate = self
        cameraModePicker.backgroundColor = .clear
        pickerContainer.addSubview(cameraModePicker)
        cameraModePicker.transform = CGAffineTransform(rotationAngle: rotationAngle)
        cameraModePicker.frame = CGRect(x: -250, y: -30, width: pickerContainer.bounds.width + 400, height: 100)
        NSLayoutConstraint.activate([
            cameraModePicker.leadingAnchor.constraint(equalTo: pickerContainer.leadingAnchor),
            cameraModePicker.trailingAnchor.constraint(equalTo: pickerContainer.trailingAnchor),
            cameraModePicker.topAnchor.constraint(equalTo: pickerContainer.topAnchor),
            cameraModePicker.bottomAnchor.constraint(equalTo: pickerContainer.bottomAnchor),
            
        ])
        canvas.delegate = self
        canvas.drawingPolicy = .anyInput
        previewImgView.addSubview(canvas)
        canvas.backgroundColor = .clear
        openCamera()
        saveBtn.isHidden = true
        shareBtn.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           canvas.frame = previewImgView.bounds
       }
    
    
    @IBAction func galleryBtn(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func closeImageTapped(_ sender: Any) {
        hidePreview()
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(previewImage!, nil, nil, nil)
        hidePreview()
    }
    @IBAction func flashBtnPressed(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        switch flashMode {
        case .auto:
          flashMode = .off
            flashBtn.setImage(UIImage(systemName: "bolt"), for: .normal)
            flashBtn.tintColor = .lightGray
        case .off:
          flashMode = .on
            flashBtn.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
            flashBtn.tintColor = .yellow
        case .on:
          flashMode = .auto
            flashBtn.tintColor = .lightGray
            flashBtn.setImage(UIImage(systemName: "bolt.badge.automatic.fill"), for: .normal)
        default:
          flashMode = .auto
        }
    }
    @IBAction func signoutBtnPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            ControllerManager.presentController(id: "LoginVC")
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    @IBAction func shareBtnTapped(_ sender: Any) {
      
        guard let img = self.previewImage else { return }
        let myQueue = DispatchQueue(__label: "my.queue", attr: nil)
        myQueue.async(execute: { [self] () -> Void in
            var photoToShare: [URL] = []
            guard let previewImage = previewImage else { return }
                let urlShare = createImageToShare(image: previewImage)
                photoToShare.append(urlShare)
            
            DispatchQueue.main.async {
                let ac = UIActivityViewController(activityItems: photoToShare, applicationActivities: nil)
                ac.overrideUserInterfaceStyle = .dark
                self.present(ac, animated: true) {
                }
            }
        })
    }
    
    private func hidePreview() {
        previewImgView.isHidden = true
        cameraView.isHidden = false
        takePhotoBtn.isHidden = false
        saveBtn.isHidden = true
        shareBtn.isHidden = true
        pickerContainer.isHidden = true
    }
    
    private func showPreview() {
        previewImgView.isHidden = false
        cameraView.isHidden = true
        takePhotoBtn.isHidden = true
        saveBtn.isHidden = false
        pickerContainer.isHidden = false
        shareBtn.isHidden = false
    }
    
    func applySepiaFilter(intensity: Float, image: UIImage) {
      let ciImage = CIImage(image: image)
      guard let filter = CIFilter(name: "CISepiaTone") else { return }
      filter.setValue(ciImage, forKey: kCIInputImageKey)
      filter.setValue(intensity, forKey: kCIInputIntensityKey)
      guard let outputImage = filter.outputImage else { return }

      let newImage = UIImage(ciImage: outputImage)
      previewImgView.image = newImage
    }
    
    func applyGrayScaleFilter(intensity: Float, image: UIImage) {
      let ciImage = CIImage(image: image)
      guard let filter = CIFilter(name:"CIColorControls") else { return }
      filter.setValue(ciImage, forKey: kCIInputImageKey)
      filter.setValue(intensity, forKey: kCIInputSaturationKey)
      guard let outputImage = filter.outputImage else { return }
      let newImage = UIImage(ciImage: outputImage)
      previewImgView.image = newImage
    }
    
    @IBAction func takePhotoBtnPRessed(_ sender: Any) {
       handleTakePhoto()
    }
}

extension MainVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        previewImgView.image = selectedImage
        self.previewImage = selectedImage
        showPreview()
        dismiss(animated: true)
  }
}


extension MainVC: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return captureModesList.count
    }
    //Here we need to display a label , you can add any custom UI here.
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let modeView = UIView()
        modeView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let modeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        modeLabel.textColor = .yellow
        modeLabel.text = captureModesList[row]
        modeLabel.textAlignment = .center
        modeView.addSubview(modeLabel)
        // Here the view rotates 90 degree on right side hence we are using positive value.
        modeView.transform = CGAffineTransform(rotationAngle: 90 * (.pi/180))
        return modeView
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 100
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            applySepiaFilter(intensity: 0, image: previewImage!)
        case 1:
            applySepiaFilter(intensity: 0.9, image: previewImage!)
        case 2:
            applyGrayScaleFilter(intensity: 0, image: previewImage!)
        default: break
        }
    }
    
    
}
// MARK: Camera
extension MainVC {
    private func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.setupCaptureSession()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    print("the user has granted to access the camera")
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                } else {
                    print("the user has not granted to access the camera")
                    self.handleDismiss()
                }
            }
        case .denied:
            print("the user has denied previously to access the camera.")
            self.handleDismiss()
            
        case .restricted:
            print("the user can't give camera access due to some restriction.")
            self.handleDismiss()
            
        default:
            print("something has wrong due to we can't access the camera.")
            self.handleDismiss()
        }
    }
    
    private func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        
        if let device = AVCaptureDevice.default(for: AVMediaType.video) {
            self.captureDevice = device
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch let error {
                print("Failed to set input device with error: \(error)")
            }
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            cameraLayer.frame = cameraView.bounds
            cameraLayer.videoGravity = .resizeAspectFill
            cameraView.layer.cornerRadius = 38
            cameraLayer.cornerRadius = 38
            cameraView.layer.insertSublayer(cameraLayer, at: 0)
           
            DispatchQueue.global().async {
                captureSession.startRunning()
            }
        }
    }
    
    @objc private func handleDismiss() {
        DispatchQueue.main.async {
            self.cameraView.isHidden = true
        }
    }
    
    @objc private func handleTakePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        
        if captureDevice.hasFlash {
            photoSettings.flashMode = flashMode
            
        }
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    private func createImageToShare(image: UIImage) -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("MyPhoto", isDirectory: false)
            .appendingPathExtension("jpg")
        
        if let data = image.jpegData(compressionQuality: 0.7) {
            do {
                try data.write(to: url)
                
            } catch {
                print("Handle the error")
            }
        }
        return url
    }
}


extension MainVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let previewImage = UIImage(data: imageData)
        self.previewImage = previewImage
        previewImgView.image = previewImage
        showPreview()
    }
}

extension MainVC: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return previewImgView
  }
}
