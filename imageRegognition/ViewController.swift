//
//  ViewController.swift
//  imageRegognition
//
//  Created by Helgi Gunnarsson on 02/02/2019.
//  Copyright © 2019 Helgi Gunnarsson. All rights reserved.
//
//
struct analyseVariables {
    static var imgString = ""
    static var pathString = ""
    static var extraPath = ""
    static var pathArray:[String] = []
    static var nameArray:[String] = []
    
}



struct Result: Decodable {
    let name: String
    let entity: Entity
    let releventLinks: [Link]

}

struct Entity: Decodable {
    let discription: String
    let thumbnailUrl: String
    let wikiUrl: String
}

struct Link: Decodable {
    let name: String
    let url: String
    let snippet: String?
    
}

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var skrolladView: UIView!
    @IBOutlet var buttPath: UIButton!

    
    
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
        self.present(imagePicker,animated: true, completion: nil)
        name.text = "Loading..."
        buttPath.setTitle("", for: .normal)
        
        
        // Set the 'click here' substring to be the link
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func path(_ sender: Any) {
        if let url = NSURL(string:analyseVariables.pathString){
            UIApplication.shared.openURL(url as URL)
        }
    }
    func setText(nafn:String, info:String){
        print("er í falli")
        
            name.text = nafn
            textView.text = info
        
        
      
        return
    }
    @IBOutlet weak var name: UILabel!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("BOY")
    }
    @IBOutlet weak var img_view: UIImageView!
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
    //Label Hjálparfall
    //Function: Helper function the create the headerLabel.
    func createLabel(labels: String, nafn: String, counter: Float){
        let labels = UILabel(frame: CGRect(x: 20, y: Int(counter), width: 300, height: 40))
        labels.font = UIFont.preferredFont(forTextStyle: .footnote)
        labels.textColor = UIColor.black
        labels.font = UIFont.boldSystemFont(ofSize: 15)
        labels.text = nafn
        labels.font = labels.font.withSize(20)
        skrolladView.addSubview(labels)
    }
    //Button Hjálparfall
    func confirmButton(path: String, nafn: String, counter: Double){
        analyseVariables.extraPath = path
        let button = UIButton.init(type: .custom)
        button.adjustsImageWhenHighlighted = false
        button.frame = CGRect(x: 20, y: counter, width: 300, height: 50.0)
        button.setTitle(nafn, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 4
        button.titleLabel?.font =  UIFont.italicSystemFont(ofSize: CGFloat(15))
        button.addTarget(self, action: #selector(confirmed), for: .touchUpInside)
        skrolladView.addSubview(button)
    }
    @objc func confirmed(sender: UIButton){
        var pather = sender.currentTitle as! String
        if let url = NSURL(string:pather){
            UIApplication.shared.openURL(url as URL)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage{
            img_view.image = image
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
                                self.confirmButton(path: d.url, nafn: d.url, counter: counting)
                                self.createLabel(labels: d.name, nafn: d.name, counter: Float(counting-20))
                                counting = counting + 60.0
                            }
                        }
                        DispatchQueue.main.async {
                            analyseVariables.pathString = json.entity.wikiUrl
                            self.setText(nafn: json.name, info: json.entity.discription)
                            self.buttPath.setTitle("Wikipedia Article", for: .normal)
                        }
                    } catch let error {
                        DispatchQueue.main.async {
                            analyseVariables.pathString = ""
                            self.setText(nafn: "Monument not found", info: "")
                            self.buttPath.setTitle("", for: .normal)
                        }
                        print(error)
                        return
                    }
                    
                })
                task.resume()

        }
        dismiss(animated: true, completion: nil)
            
    }
    }}
