//
//  ViewController.swift
//  SeeFood
//
//  Created by Angelique Babin on 04/03/2021.
//

import UIKit
import CoreML
import Vision

final class ViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var imageView: UIImageView!
    
    // MARK: - Properties
    
    private let imagePicker = UIImagePickerController()
    
    // MARK: - Actions
    
    @IBAction private func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImagePicker()
    }
}

// MARK: - Extension UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {
//                return
                fatalError("Could not convert UIImage into CIImage")
            }
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    private func setImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    private func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: .init()).model) else {
            fatalError("Loading CoreML Model failed") // return
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.") // return
            }
            
            if let firstResult = results.first {
                self.navigationItem.title = firstResult.identifier.capitalized
//                if firstResult.identifier.contains("hotdog") {
//                    self.navigationItem.title = "Hotdog !"
//                } else {
//                    self.navigationItem.title = "Not Hotdog !"
//                }
            }
            print(results[0], results[1], results[2])
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}
