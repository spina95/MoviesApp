//
//  EditProfileTableViewController.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 18/07/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class EditProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var sex: UITextField!
    @IBOutlet weak var country: UITextField!
    
    var picker : UIPickerView!
    var activeTextField = 0
    var activeTF : UITextField!
    var activeValue = ""
    
    var sexTest = ["Male","Female", "Unspecified"]
    var countryText = ["Italy", "England", "France"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addShadow(navigationController: self.navigationController)
        profilePicture.roundCorners(value: Double(Int(profilePicture.frame.height/2)))
                
        let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        loadingView.backgroundColor = backgroundColor
        view.addSubview(loadingView)
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        view.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: view.frame.size.width*0.5, y: view.frame.size.height*0.3)
        activityIndicator.startAnimating()
        
        sex.delegate = self
        country.delegate = self
    
        self.loadTableView()
        let databaseRef = Database.database().reference()
        databaseRef.child("users").child(currentUserFirebase!.uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            // check if user has photo
            if snapshot.hasChild("user_photo"){
                // set image locatin
                let imageName = currentUserFirebase!.profilePictureUrl
                let filePath = "profile_images/\(imageName!).png"
                // Assuming a < 10MB file, though you can change that
                let storageRef = Storage.storage().reference()
                storageRef.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                    let userPhoto = UIImage(data: data!)
                    currentUserFirebase!.profilePicture = userPhoto
                    self.profilePicture.image = userPhoto
                    activityIndicator.stopAnimating()
                    loadingView.isHidden = true
                })
                } else {
                    self.tableView.reloadData()
                    activityIndicator.stopAnimating()
                    loadingView.isHidden = true
                }
            activityIndicator.stopAnimating()
                    loadingView.isHidden = true
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadTableView(){
        username.text = currentUserFirebase!.username
        sex.text = currentUserFirebase!.sex
        country.text = currentUserFirebase!.country
    }
   
    @IBAction func changePicture(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage]  else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        profilePicture.image = selectedImage as! UIImage
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func save(_ sender: Any) {
        let dati = [
            "username" : username.text,
            "sex" : sex.text,
            "country" : country.text
        ]
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
        
        if let _ = self.profilePicture.image, let  uploadData = self.profilePicture.image?.jpegData(compressionQuality: 0.1){
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil, metadata != nil {
                    print(error ?? "")
                    return
                }
                let ref = Database.database().reference().child("users").child(currentUserFirebase!.uid!)
                ref.updateChildValues(["user_photo": imageName])
                _ = self.navigationController?.popViewController(animated: true)

            })
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch activeTextField {
        case 1:
            return sexTest.count
        case 2:
            return countryText.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch activeTextField {
        case 1:
            return sexTest[row]
        case 2:
            return countryText[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch activeTextField {
        case 1:
            activeValue = sexTest[row]
            sex.text = sexTest[row]
        case 2:
            activeValue = countryText[row]
            country.text = countryText[row]
        default:
            activeValue = ""
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case sex:
            activeTextField = 1
        case country:
            activeTextField = 2
        default:
            activeTextField = 0
        }
        
        // set active Text Field
        activeTF = textField
        
        self.pickUpValue(textField: textField)
    }
    
    func pickUpValue(textField: UITextField) {
        
        // create frame and size of picker view
        picker = UIPickerView(frame:CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.size.width, height: 216)))
        
        // deletates
        picker.delegate = self
        picker.dataSource = self
        
        // if there is a value in current text field, try to find it existing list
        if let currentValue = textField.text {
            
            var row : Int?
            
            // look in correct array
            switch activeTextField {
            case 1:
                row = sexTest.index(of: currentValue)
            case 2:
                row = countryText.index(of: currentValue)
            default:
                row = nil
            }
            
            // we got it, let's set select it
            if row != nil {
                picker.selectRow(row!, inComponent: 0, animated: true)
            }
        }
        
        picker.backgroundColor = UIColor.white
        textField.inputView = self.picker
        
        // toolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.barTintColor = backgroundColor
        toolBar.sizeToFit()
        
        // buttons for toolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        doneButton.tintColor = mainColor
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    // done
    @objc func doneClick() {
        activeTF.text = activeValue
        activeTF.resignFirstResponder()
    }
    
    // cancel
    @objc func cancelClick() {
        activeTF.resignFirstResponder()
    }
    
    @IBAction func logout(_ sender: Any) {
        try! Auth.auth().signOut()
        self.performSegue(withIdentifier: "logout", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "save"{
            let vc = segue.destination as! CurrentUserInfoViewController
            vc.reloadView = true
        }
    }
}
