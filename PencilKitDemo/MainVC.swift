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

enum Filters: String {
    case defaults
    case grayscale = "CIColorControls"
    case sepia = "CISepiaTone"
}

class MainVC: UIViewController {
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var takePhotoBtn: CameraButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var galleryBtn: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var previewImgView: UIImageView!
    @IBOutlet weak var pickerContainer: UIView!
    var previewImage: UIImage?
    var selectedFilter: Filters = .grayscale
    let photoOutput = AVCapturePhotoOutput()
    var cameraLayer: AVCaptureVideoPreviewLayer!
    var flashMode: AVCaptureDevice.FlashMode = .auto
    var captureDevice: AVCaptureDevice!
    
    var cameraModePicker: UIPickerView!
    
    let captureModesList = ["Default", "Sepia", "Gray"]
    var rotationAngle: CGFloat! = -90  * (.pi/180)
     
    override func viewDidLoad() {
        super.viewDidLoad()
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
        openCamera()
        saveBtn.isHidden = true
    }
    @IBAction func galleryBtn(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func closeImageTapped(_ sender: Any) {
//        previewImgView.isHidden = true
//        cameraView.isHidden = false
//        takePhotoBtn.isHidden = false
//        pickerContainer.isHidden = true
        hidePreview()
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(previewImage!, nil, nil, nil)
        hidePreview()
    }
    
    private func hidePreview() {
        previewImgView.isHidden = true
        cameraView.isHidden = false
        takePhotoBtn.isHidden = false
        saveBtn.isHidden = true
        pickerContainer.isHidden = true
    }
    
    private func showPreview() {
        previewImgView.isHidden = false
        cameraView.isHidden = true
        takePhotoBtn.isHidden = true
        saveBtn.isHidden = false
        pickerContainer.isHidden = false
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
//    
//    @IBAction func sliderValueChanged(_ sender: Any) {
//        guard let image = previewImage else { return }
//        switch selectedFilter {
//        case .defaults:
//            break
//        case .grayscale:
//            applyGrayScaleFilter(intensity: 0.7, image: image)
//        case .sepia:
//            applySepiaFilter(intensity: 0.7, image: image)
//        }
//    }
    
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
//        cameraView.isHidden = true
//        takePhotoBtn.isHidden = true
//        previewImgView.isHidden = false
//        pickerContainer.isHidden = false
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
                DispatchQueue.main.async {
//                    self.bottomView.isHidden = false
                }
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
}


extension MainVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let previewImage = UIImage(data: imageData)
        self.previewImage = previewImage
        previewImgView.image = previewImage
//        cameraView.isHidden = true
//        takePhotoBtn.isHidden = true
//        pickerContainer.isHidden = false
//        previewImgView.isHidden = false
        showPreview()
    }
}

extension MainVC: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return previewImgView
  }
}
