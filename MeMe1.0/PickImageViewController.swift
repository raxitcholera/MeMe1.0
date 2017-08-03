//
//  PickImageViewController.swift
//  MeMe1.0
//
//  Created by Raxit Cholera on 6/4/17.
//  Copyright © 2017 Raxit Cholera. All rights reserved.
//

import UIKit

class PickImageViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var meemImageView: UIImageView!
    @IBOutlet weak var meemTopText: UITextField!
    @IBOutlet weak var meemBottomText: UITextField!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    var meemExportImage = UIImage()
    let imagePickerController = UIImagePickerController()
    var pickedImage = UIImage()
    var keyboardSize: CGFloat = 0.0

    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3.0]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        edgesForExtendedLayout = UIRectEdge(rawValue: 0);
        configureTextField(textField: meemTopText)
        configureTextField(textField: meemBottomText)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func configureTextField(textField: UITextField) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = self
        textField.textAlignment = .center
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (meemTopText.text?.isEmpty)!{
            meemTopText.text = "Top Text"
        } else if (meemBottomText.text?.isEmpty)! {
            meemBottomText.text  = "Bottom Text"
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        meemImageView.contentMode = .scaleAspectFit
        meemImageView.image = pickedImage
        shareButton.isEnabled = true
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func shareButtonClicked(_ sender: Any) {
        createMemeImage()
        let controller = UIActivityViewController(activityItems: [meemExportImage as Any], applicationActivities: nil)
        controller.completionWithItemsHandler = {
            type, ok, items, err in
            if ok {
                self.save()
            } else {
                print(err as Any)
            }
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func galleryButtonClicked(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            presentImagePicker(sourceType: .photoLibrary)
        }else {
            displayAlert(title: "Alert!", message: "PhotoLibrary is not available")
        }
        
    }
    
    func presentImagePicker(sourceType: UIImagePickerControllerSourceType)
    {
        imagePickerController.sourceType = sourceType
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func clearButtonClicked(_ sender: Any) {
        shareButton.isEnabled = false
        meemTopText.text = "Top Text"
        meemBottomText.text = "Bottom Text"
        meemImageView.image = nil
    }
    
    @IBAction func camaraButtonClicked(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            presentImagePicker(sourceType: .camera)
        }else {
            displayAlert(title: "Alert!", message: "Camera is not available")
        }
    }
    
    func keyboardWillShow(_ notification:Notification) {
        if meemBottomText.isFirstResponder {
            mainView.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }
    
    func keyboardWillHide(_ notification:Notification){
        if meemBottomText.isFirstResponder {
            mainView.frame.origin.y += getKeyboardHeight(notification)
        }
    }

    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func displayAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func createMemeImage()
    {
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, UIScreen.main.scale)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        meemExportImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage!
        UIGraphicsEndImageContext()
    }
    func save() {
        let meme = Meme(topText: meemTopText.text!, bottomText: meemBottomText.text!, image: meemImageView.image, memeImage: meemExportImage)
        appDelegate.memes.append(meme)
    }
}

