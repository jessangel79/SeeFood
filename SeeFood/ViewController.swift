//
//  ViewController.swift
//  SeeFood
//
//  Created by Angelique Babin on 04/03/2021.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    
    let imagePicker = UIImagePickerController()
    
    // MARK: - Actions
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    // MARK: - Methods

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
//                return
                fatalError("Could not convert UIImage into CIImage")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
//        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: .init()).model) else {
//            return
            fatalError("Loading CoreML Model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
//                return
                fatalError("Model failed to process image.")
            }
            
            
            if let firstResult = results.first {
                self.navigationItem.title = firstResult.identifier.capitalized
//                if firstResult.identifier.contains("hotdog") {
//                    self.navigationItem.title = "Hotdog !"
//                } else {
//                    self.navigationItem.title = "Not Hotdog !"
//                }
            }
            print(results)
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }

}

