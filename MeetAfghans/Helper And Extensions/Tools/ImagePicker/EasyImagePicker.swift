//
//  EasyImagePicker.swift
//  Lamienins
//
//  Created by Arunaday roy on 02/08/19.
//  Copyright © 2019 infoware. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import Photos


public protocol EasyImagePickerDelegate: class {
    func didSelect(image: UIImage?, video : URL?, fileName : String?)
}

open class EasyImagePicker: NSObject {
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: EasyImagePickerDelegate?
    
    public enum mediaType {
        case images
        case video
    }
    
    public init(presentationController: UIViewController, delegate: EasyImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        super.init()
        self.presentationController = presentationController
        self.delegate = delegate
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
    }
    
    public func present(from sourceView: UIView, mediaType : mediaType, onViewController : UIViewController) {
        sourceView.translatesAutoresizingMaskIntoConstraints = false
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if mediaType == .video{
            self.pickerController.mediaTypes = ["public.movie"]
            let actionVideo = UIAlertAction(title: "Take Video", style: .default) { (action) in
                if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined || AVAudioSession.sharedInstance().recordPermission == .undetermined{
                    let _ = self.checkMicPermission()
                    let _ = self.checkCameraPermission()
                    self.presentAlert(sourceView: sourceView, alertController: alertController)
                }else{
                    if self.checkCameraPermission() && self.checkMicPermission(){
                        self.pickerController.sourceType = .camera
                        self.presentationController?.present(self.pickerController, animated: true)
                    }else{
                        self.presentCameraSettings(with: "We need camera and microphone access for recording video", fromView: onViewController)
                    }
                }
            }
            var isVideo :Bool{
                if mediaType == .video {
                    return true
                }else if mediaType == .images{
                    return false
                }else{
                    return false
                }
            }
            if let actionLibrary  = self.checkPhotoLibrary(isVideo: isVideo, sourceView: sourceView, onViewController: onViewController, alertController: alertController){
                alertController.addAction(actionLibrary)
            }
            if UIImagePickerController.isSourceTypeAvailable(.camera){ alertController.addAction(actionVideo) }
        }else if mediaType == .images{
            self.pickerController.mediaTypes = ["public.image"]
            let actionCamera = UIAlertAction(title: "Take Photo", style: .default) { (action) in
                if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined{
                    let _ = self.checkCameraPermission()
                    self.presentAlert(sourceView: sourceView, alertController: alertController)
                }else{
                    if self.checkCameraPermission(){
                        self.pickerController.sourceType = .camera
                        self.presentationController?.present(self.pickerController, animated: true)
                    }else{
                        self.presentCameraSettings(with: "We need camera access for capturing picture.", fromView: onViewController)
                    }
                }
            }
            
            if let actionLibrary  = self.checkPhotoLibrary(isVideo: false, sourceView: sourceView, onViewController: onViewController, alertController: alertController){
                alertController.addAction(actionLibrary)
            }
            if UIImagePickerController.isSourceTypeAvailable(.camera){ alertController.addAction(actionCamera) }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addAction(cancel)
        presentAlert(sourceView: sourceView, alertController: alertController)
    }
    
    private func checkPhotoLibrary(isVideo : Bool,sourceView : UIView,onViewController : UIViewController,alertController : UIAlertController)-> UIAlertAction?{
        let actionLibrary = UIAlertAction(title: "\(isVideo ? "Video" : "Photo") Library", style: .default) { (action) in
            if PHPhotoLibrary.authorizationStatus() == .notDetermined{
                let _ = self.checkPhotoLibraryPermission()
                self.presentAlert(sourceView: sourceView, alertController: alertController)
            }else{
                if self.checkPhotoLibraryPermission(){
                    self.pickerController.sourceType = .photoLibrary
                    self.presentationController?.present(self.pickerController, animated: true)
                }else{
                    self.presentCameraSettings(with: "We gallery permission for pick \(isVideo ? "video" : "photo") from you.", fromView: onViewController)
                }
            }
        }
        return actionLibrary
    }
    
    private func presentAlert(sourceView : UIView, alertController : UIAlertController){
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, image: UIImage?, video : URL?, file : String?) {
        controller.dismiss(animated: true, completion: nil)
        self.delegate?.didSelect(image: image, video: video, fileName: file)
    }
    
    func checkCameraPermission() -> Bool{
        var permissionCheck: Bool = false
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            permissionCheck = false
        case .restricted:
            permissionCheck = false
        case .authorized:
            permissionCheck = true
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    permissionCheck = true
                    
                } else {
                    permissionCheck = false
                }
            }
        default : break
        }
        return permissionCheck
    }
    
    func checkPhotoLibraryPermission() -> Bool {
        
        var permissionCheck: Bool = false
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            permissionCheck = true
            break
        //handle authorized status
        case .denied, .restricted :
            permissionCheck = false
            break
        //handle denied status
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    permissionCheck = true
                    break
                // as above
                case .denied, .restricted:
                    permissionCheck = false
                    break
                // as above
                case .notDetermined:
                    permissionCheck = true
                    break
                // won't happen but still
                default : break
                }
            }
        default : break
        }
        return permissionCheck
    }
    
    func checkMicPermission() -> Bool {
        
        var permissionCheck: Bool = false
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            permissionCheck = true
        case AVAudioSession.RecordPermission.denied:
            permissionCheck = false
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    permissionCheck = true
                } else {
                    permissionCheck = false
                }
            })
        default:
            break
        }
        return permissionCheck
    }
    
    func presentCameraSettings(with text: String, fromView : UIViewController) {
        let alertController = UIAlertController(title: "Error",
                                                message: text,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })
        fromView.present(alertController, animated: true)
    }
}

extension EasyImagePicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let mediaURL = info[.mediaURL] as? URL  {
            self.pickerController(picker, image: nil, video: mediaURL, file: mediaURL.lastPathComponent)
        }else{
            self.pickerController(picker, image: nil, video: nil, file: nil)
        }
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, image: nil, video: nil, file: nil)
        }
        self.pickerController(picker, image: image, video: nil, file: nil)
    }
}

extension EasyImagePicker: UINavigationControllerDelegate {
    
}

