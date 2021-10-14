//
//  ViewController.swift
//  MachineLearning
//
//  Created by Fatih Kilit on 9.10.2021.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    var chosenImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chosePhoto))
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func chosePhoto() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!) {
            chosenImage = ciImage
        }
        
        recognizeImage(image: chosenImage)
    }

    func recognizeImage(image: CIImage) {
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            let request = VNCoreMLRequest(model: model) { vnRequest, error in
                
                if let results = vnRequest.results as? [VNClassificationObservation] {
                    
                    if results.count > 0 {
                        let topResult = results.first
                        
                        DispatchQueue.main.async {
                            
                            let identifier = topResult?.identifier ?? ""
                            let confidenceLevel = (topResult?.confidence ?? 0.0) * 100
                            let roundedConfidenceLevel = Int(confidenceLevel.rounded())
                            
                            self.label.text = ("it's  %\(roundedConfidenceLevel) \(identifier).")
                        }
                    }
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("Error!")
                }
            }
        }
    }
}

