//
//  MemeGeneratorVC.swift
//  MemeMe V1.0-master
//
//  Created by Priyam Gupta on 27/12/17.
//  Copyright © 2017 Priyam Gupta. All rights reserved.
//

import UIKit

class MemeGeneratorVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageViewer: UIImageView!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        topTextField.defaultTextAttributes = memeTextAttribute
        bottomTextField.defaultTextAttributes = memeTextAttribute
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if Camera is Available
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // Text Field Specifications
        topTextField.text = "TOP"
        topTextField.textAlignment = .center
        bottomTextField.text = "BOTTOM"
        bottomTextField.textAlignment = .center
        
        keyBoardNotificationsOn()
        // Handling the Action Button
        if imageViewer.image == nil{
            actionButton.isEnabled = false
        }
        else{
            actionButton.isEnabled = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyBoardNotificationsOff()
    }
    
    let memeTextAttribute:[String: Any] = [
        NSAttributedStringKey.strokeColor.rawValue : UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue : UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -2.0,
    ]
    
    @IBAction func pickFromAlbum(_ sender: Any) {
        pickAnImage(source: .photoLibrary)
    }
    
    @IBAction func pickFromCamera(_ sender: Any) {
        pickAnImage(source: .camera)
    }
    
    func pickAnImage(source: UIImagePickerControllerSourceType){
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = source
        present(image, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            imageViewer.image = image
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (topTextField.text == "TOP"){
            topTextField.text = nil
        }
       else if(bottomTextField.text == "BOTTOM"){
        bottomTextField.text = nil
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        topTextField.resignFirstResponder()
        bottomTextField.resignFirstResponder()
        return true
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        if bottomTextField.isFirstResponder{
        self.view.frame.origin.y = -getKeyboardHeight(notification: notification)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        if bottomTextField.isFirstResponder{
        self.view.frame.origin.y = 0
        }
    }
    
    func keyBoardNotificationsOn(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyBoardNotificationsOff(){
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    struct Meme{
        var topText : String
        var bottomText : String
        let originalImage : UIImage
        var memedImage : UIImage
    }
    
    @IBAction func activityController(_ sender: Any) {
        let memedImage = generateMemedImage()
        let controller = UIActivityViewController.init(activityItems: [memedImage], applicationActivities: nil)
        controller.completionWithItemsHandler = {activity, completed, items, error in
            if completed{
                self.save(image: memedImage)
                self.dismiss(animated: true, completion: nil)
            }
        }
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        let controller = UIAlertController()
        controller.title = "Wait!"
        controller.message = "You are about to abandon the masterpiece .."
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default){
            action in self.dismiss(animated: true, completion: nil)
        }
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
        imageViewer.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
    }
    
    func save(image: UIImage){
        _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageViewer.image!, memedImage: generateMemedImage())
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        toolNavConfig(choice: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        toolNavConfig(choice: false)
        
        return memedImage
    }
    func toolNavConfig(choice : Bool){
        navigationBar.isHidden = choice
        toolbar.isHidden = choice
    }
}
