//
//  FirstViewController.swift
//  Snart
//
//  Created by Daniel Björkander on 2019-03-08.
//  Copyright © 2019 Daniel Björkander. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications

class NewMemoryViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    let notificationTitles = [
        "If we can't make memories, we can't heal.",
        "I can't remember to forget you.",
        "Now... where was I?",
        "I have this condition.",
        "I take it I've told you about my condition.",
        "Remember Sammy Jankis."
    ]
    
    let dateFormat: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm"
        return format
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(photoOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(photoOutput)
                setupLivePreview()
            }
        }
        catch let error {
            print("Error: Unable to initialize back camera: \(error.localizedDescription)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    func getNotificationTime() -> Date {
        let secondsToNotifcation = Double(slider.value * 60)
        return Date(timeIntervalSinceNow: secondsToNotifcation)
    }
    
    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
    }
    
    func addNotification(attachmentURL: URL) {
        do {
            // TODO: Should probably fetch time from URL instead to make it more independent
            let notificationTime = getNotificationTime()
            let identifier = attachmentURL.absoluteString
            
            let content = UNMutableNotificationContent()
            let randomTitleIndex = Int(arc4random_uniform(UInt32(notificationTitles.count)))
            content.title = NSString.localizedUserNotificationString(forKey: notificationTitles[randomTitleIndex], arguments: nil)
            content.sound = UNNotificationSound.default
            
            let attachment = try UNNotificationAttachment(identifier: identifier, url: attachmentURL, options: nil)
            content.attachments = [attachment]
            
            let cal = NSCalendar.current
            let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: notificationTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                if (error != nil) {
                    print("Local push notification failed: %@", error.debugDescription);
                }
            }
        } catch {
            print(error)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        do {
            guard let imageData = photo.fileDataRepresentation()
                else { return }
            
            guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                else { return }
            
            let notificationTime = getNotificationTime()
            let fileURL = documentsURL.appendingPathComponent("\(notificationTime.timeIntervalSince1970).jpg")
            try imageData.write(to: fileURL)
            addNotification(attachmentURL: fileURL)
        } catch {
            print(error)
        }
    }

    @IBAction func didTapOnTakePhotoButton(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func onSliderUpdate(sender: UISlider) {
        let notificationTime = getNotificationTime()
        sliderLabel.text = dateFormat.string(from: notificationTime)
    }
}

