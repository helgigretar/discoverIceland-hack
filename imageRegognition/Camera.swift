//
//  Camera.swift
//  imageRegognition
//
//  Created by Helgi Gunnarsson on 02/02/2019.
//  Copyright © 2019 Helgi Gunnarsson. All rights reserved.
//

import UIKit

class Camera: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var camera: UIButton!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        print("kjsdbnfjksdnfkjsbfhj")
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        self.present(imagePicker,animated: true, completion: nil)
   

        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var imageDisplay: UIImageView!
    
    @IBAction func cameraAction(_ sender: Any) {
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage{
            imageDisplay.image = image
            //  Use image name from bundle to create NSData
            let image : UIImage = image
            //Now use image to create into NSData format
            let imageData:NSData = image.pngData()! as NSData
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            let replaced = strBase64.replacingOccurrences(of: "\n", with: "")
            //We have received the image and now lets send it
            let fortniteChallengesURL = URL(string: "https://reboot-hackathon.herokuapp.com/imagepost")
            if let unwrappedURL = fortniteChallengesURL {
                var req = URLRequest(url: unwrappedURL)
                
                let parameters = ["imgText":replaced] as [String : Any]
                
                //create the url with URL
                let url = URL(string: "https://reboot-hackathon.herokuapp.com/imagepost")!
                
                //create the session object
                let session = URLSession.shared
                
                //now create the URLRequest object using the url object
                //var request = URLRequest(url: req)
                
                req.httpMethod = "POST" //set http method as POST
                
                do {
                    req.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                } catch let error {
                    print(error.localizedDescription)
                }
                
                req.addValue("application/json", forHTTPHeaderField: "Content-Type")
                req.addValue("application/json", forHTTPHeaderField: "Accept")
                
                //create dataTask using the session object to send data to the server
                let task = session.dataTask(with: req as URLRequest, completionHandler: { data, response, error in
                    print("BOYYY")
                    if((error) != nil){
                        return
                    }
                    guard let data = data else {
                        return
                    }
                    do {
                        //create json object from data
                        let json = try JSONDecoder().decode(Result.self, from:data)
                        var counting = 600.0
                        for d in json.releventLinks {
                            DispatchQueue.main.async {
                                analyseVariables.nameArray.append(d.name)
                                analyseVariables.nameArray.append(d.url)
                                
                                counting = counting + 60.0
                            }
                        }
                        DispatchQueue.main.async {
                            analyseVariables.pathString = json.entity.wikiUrl
                           
                        }
                    } catch let error {
                        DispatchQueue.main.async {
                            analyseVariables.pathString = ""
                           
                        }
                        print(error)
                        return
                    }
                    
                })
                task.resume()
                
            }
            dismiss(animated: true, completion: nil)
    }
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

   }
}
