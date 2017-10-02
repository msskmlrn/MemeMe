//
//  MemeEditorViewController.swift
//  MemeMe
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    var meme: Meme?
    
    static let topText = "TOP"
    static let bottomText = "BOTTOM"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        //custom text attributes
        let memeTextAttributes:[String:Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 20)!,
            NSAttributedStringKey.strokeWidth.rawValue: -3.0]
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        topTextField.text = MemeEditorViewController.topText
        bottomTextField.text = MemeEditorViewController.bottomText
        
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        
        //enable the share button only if there is a meme to share
        if self.meme != nil {
            shareButton.isEnabled = true
        } else {
            shareButton.isEnabled = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // enable the camera button only if the device has a camera
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //push the view up so that the text field is visible if the bottom text field is clicked
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    //reset the view up when the keyboard is dismissed from the bottom text field
    @objc func keyboardWillHide(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    //calculate the keyboard height
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    //send notifications when the keyboard is shown and hidden
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    //unsubscribe from keyboard notifications
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    //use the camera to take an image
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    //select an image from the gallery
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    //react to image picker closed event
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //update the view if a valid image was picked
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.contentMode = UIViewContentMode.scaleAspectFill
            imagePickerView.image = image
            shareButton.isEnabled = true
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    //dismiss the image picker if the action was cancelled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //clear the text field if the default text was present in the selected field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == topTextField && topTextField.text == "TOP") {
            topTextField.text = ""
        }
        if (textField == bottomTextField && bottomTextField.text == "BOTTOM") {
            bottomTextField.text = ""
        }
    }
    
    //dismiss the keyboard when return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard(textField: textField)
        return true
    }

    // dismiss the keyboard
    func dismissKeyboard(textField: UITextField) {
        textField.endEditing(true)
        textField.resignFirstResponder()
    }
    
    //generate and save a new meme
    func save() {
        let memeImage = generateMemedImage()
        
        // Create the meme
        meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memeImage: memeImage)
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme!)
    }
    
    //generate a meme image from the picture and text field contents
    func generateMemedImage() -> UIImage {
        // Hide toolbar & navbar to create image instance
        topToolbar.isHidden = true
        bottomToolbar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar after image is created
        topToolbar.isHidden = false
        bottomToolbar.isHidden = false
        
        return memedImage
    }
    
    //handle share button press. Save an image if the share action is completed successfully
    @IBAction func share(_ sender: Any) {
        let memeImage = generateMemedImage()
        let controller = UIActivityViewController.init(activityItems: [memeImage], applicationActivities: nil)
        
        controller.completionWithItemsHandler = { (activity, success, items, error) in
            self.dismiss(animated: true, completion: nil)
            
            if success {
                self.save()
            }
        }
        present(controller, animated: true, completion: nil)
    }
    
    //dismiss the view if the cancel button is pressed
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

