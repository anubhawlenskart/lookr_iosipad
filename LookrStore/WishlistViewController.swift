//
//  UserFreameViewController.swift
//  LookrStore
//
//  Created by Keshav Gangwal on 20/06/19.
//  Copyright © 2019 Lenskart. All rights reserved.
//

import UIKit

protocol WishListControllerDelegate: class {
    func didLogOut()
}

class UserFreameViewController : BaseViewController ,
UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var eyeglasses: UIButton!
    @IBOutlet weak var sunglasse: UIButton!
    @IBOutlet weak var fullimage: UIImageView!
    @IBOutlet weak var wishlistview: UICollectionView!
    @IBOutlet weak var skuname: UILabel!
    @IBOutlet weak var brandname: UILabel!
    @IBOutlet var viewOutlet: UIView!
    @IBOutlet weak var liftbutton: UIButton!
    @IBOutlet weak var rightbutton: UIButton!
    @IBOutlet weak var imageCirleView: UIView!
    @IBOutlet weak var wishlistcountOutlet: UILabel!
    @IBOutlet var addiconOutlet: UIButton!
    @IBOutlet weak var filterOutlet: RoundedCornerView!
    
    
    var dittoid = "" ,token = "" , mnumber = "", filterglassstring="Sunglasses" ,sku = ""
    var indexPathmain = 0
    var subFreamsArray = NSArray()
    var subeyeglassesArray = NSArray()
    var subsunglassesArray = NSArray()
    var collectionviewArray = [[String : AnyObject]]()
    var coutwishlist = 0
    
    var wishlistedProduct = ""
    weak var delegate: WishListControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        if let stringOne = defaults.string(forKey: "dittoid") {
            dittoid = stringOne
        }
        if let stringTwo = defaults.string(forKey: "token") {
            token = stringTwo
        }
        if let stringThree = defaults.string(forKey: "mobileno") {
            mnumber = stringThree
        }
        
        fullimage.layer.cornerRadius = 10
        fullimage.clipsToBounds = true
        fullimage.layer.borderWidth = 3
        fullimage.layer.borderColor = UIColor.white.cgColor
        
        wishlistview.delegate = self
    
        imageCirleView.layer.borderWidth = 2.0
        imageCirleView.layer.masksToBounds = false
        imageCirleView.layer.borderColor = LookrConstants.sharedInstance.color.cgColor
        imageCirleView.layer.cornerRadius = imageCirleView.frame.height/2
        imageCirleView.clipsToBounds = true
        
        viewOutlet.layer.backgroundColor = LookrConstants.sharedInstance.bgcolor.cgColor

        //self.wishlistview.scrollEnabled = ; // Disable automated scrolling
        
        gotocomparisonAPI()
        
    }
    
    @IBAction func collection(_ sender: Any) {
        getsetcomparison()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let balanceViewController = storyBoard.instantiateViewController(withIdentifier: "collectionui") as! CollectionViewController
        // self.present(balanceViewController, animated: true, completion: nil)
        navigationController?.pushViewController(balanceViewController, animated: true)
    }
    
    @IBAction func addToWishlistAction(_ sender: UIButton) {
        
        let string = "\(wishlistedProduct)"
        addiconOutlet.setImage( UIImage.init(named: "ic_add_circle_red"), for: .normal)
        if let intnumebr = Int(skuname.text!){
            if string.contains("\(intnumebr)") {
                print("exists")
            }else {
                
                self.coutwishlist += 1
                self.wishlistcountOutlet.text = "\(self.coutwishlist)"
                setsku(self.skuname.text ?? "")
            }
            
        }
        
    }
    
    @IBAction func sunglassesAction(_ sender: UIButton) {
        subFreamsArray = subsunglassesArray
        wishlistview.reloadData()
        setimage(0)
        
        let layer = UIView(frame: CGRect(x: 252.99, y: 33.99, width: 130.62, height: 52.41))
        layer.layer.cornerRadius = 26.21
        sunglasse.backgroundColor = UIColor.white
        self.view.addSubview(layer)
        
        sunglasse.setTitleColor(UIColor.black, for: UIControl.State.normal)
        eyeglasses.setTitleColor(UIColor.white,  for: UIControl.State.normal)

        eyeglasses.backgroundColor = UIColor.white.withAlphaComponent(0.0)

        
    }
    
    @IBAction func eyeglassesAction(_ sender: UIButton) {
        
        subFreamsArray = subeyeglassesArray
        wishlistview.reloadData()
        setimage(0)
        let layer = UIView(frame: CGRect(x: 252.99, y: 33.99, width: 130.62, height: 52.41))
        layer.layer.cornerRadius = 26.21
        eyeglasses.backgroundColor = UIColor.white
        self.view.addSubview(layer)
        
        eyeglasses.setTitleColor(UIColor.black, for: UIControl.State.normal)
        sunglasse.setTitleColor(UIColor.white,  for: UIControl.State.normal)

        sunglasse.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        
    }
    
    
    @IBAction func leftbutton(_ sender: Any) {
        indexPathmain -= 1
        setimage(indexPathmain)
    }
    
    
    @IBAction func rightbutton(_ sender: Any) {
        
        indexPathmain += 1
        setimage(indexPathmain)
        
    }
    
    @IBAction func filter(_ sender: Any) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "shareui") as! ShareCollectionViewController
        self.navigationController?.present(popOverVC, animated: true, completion: nil)
        
        
    }
    
    @IBAction func lablefilter(_ sender: Any) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "filter") as! FilterViewController
        navigationController?.present(popOverVC, animated: true, completion: nil)
        
        
        
    }
    @IBAction func chnageditto(_ sender: Any) {
        
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chnageditto") as! ChnageDittoViewController
        navigationController?.pushViewController(popOverVC, animated: true)
        
    }
    
    @IBAction func logout(_ sender: Any) {
        delegate?.didLogOut()
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        navigationController?.pushViewController(popOverVC, animated: true)    }
    
    
    
    func gotocomparisonAPI(){
        self.showLoader()
        if let intnumebr = Int(mnumber){
            let urlstring = "\(LookrConstants.sharedInstance.baseURL)getcomparisonproduct?mobile=\(intnumebr)&dittoid=\(dittoid)"
            let params = ["":""] as Dictionary<String, String>
            var request = URLRequest(url: URL(string: urlstring)!)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                DispatchQueue.main.async {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                        let data = json["success"] as? [String: Any]
                        if data != nil {
                            let posts = data?["products"] as? [[String: AnyObject]]
                              if posts != nil {
                                self.collectionviewArray = posts!
                                self.collectionviewArray.forEach { (product) in
                                    let skuString = String(self.sku)
                                    if let existingSKU = product["sku"] as? String {
                                        self.wishlistedProduct.append("\(existingSKU),")
                                        
                                    }
                                }
                                self.coutwishlist = self.collectionviewArray.count
                                self.wishlistcountOutlet.text = "\(self.coutwishlist)"
                                self.gotogetwishlistAPI()
                                self.gotogeteyeglasseswishlistAPI()
                                
                              }else{
                                self.gotogetwishlistAPI()
                                self.gotogeteyeglasseswishlistAPI()
                            }
                           
                            
                        }else{
                            
                            self.gotogetwishlistAPI()
                            self.gotogeteyeglasseswishlistAPI()
                            
                        }
                        
                    }catch {
                        print("error")
                    }
                }
            })
            task.resume()
        }
        
    }
    
    func setsku(_ sku: String) {
        wishlistedProduct.append("\(sku),")
    }
    
    
    func gotogetwishlistAPI(){
        if let intnumebr = Int(mnumber){
            let urlstring = "\(LookrConstants.sharedInstance.baseURL)userframes?mobile=\(intnumebr)&dittoid=\(dittoid)&type=\(filterglassstring)&count=300"
            let params = ["":""] as Dictionary<String, String>
            var request = URLRequest(url: URL(string: urlstring)!)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                DispatchQueue.main.async {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                        self.hideLoader(removeFrom: self.view)
                        let posts = json["success"] as? [[String: Any]] ?? []
                        self.subFreamsArray = posts as NSArray
                        self.subsunglassesArray = posts as NSArray
                        
                        self.wishlistview.reloadData()
                        
                        self.setimage(0)
                        
                    } catch let error as NSError {
                        print(error)
                    }
                }
                
            })
            
            task.resume()
            
        }
        
    }
    
    func gotogeteyeglasseswishlistAPI(){
        if let intnumebr = Int(mnumber){
            let urlstring = "\(LookrConstants.sharedInstance.baseURL)userframes?mobile=\(intnumebr)&dittoid=\(dittoid)&type=Eyeglasses&count=300"
            
            let params = ["":""] as Dictionary<String, String>
            var request = URLRequest(url: URL(string: urlstring)!)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    let posts = json["success"] as? [[String: Any]] ?? []
                    self.subeyeglassesArray = posts as NSArray
                    
                } catch let error as NSError {
                    print(error)
                }
                
            })
            
            task.resume()
            
        }
        
    }
    
    
    func getsetcomparison(){
        if let intnumebr = Int(mnumber){
            let urlstring = "\(LookrConstants.sharedInstance.baseURL)setcomparisonproduct?mobile=\(intnumebr)&dittoid=\(dittoid)&sku=\(wishlistedProduct)"
            
            let params = ["":""] as Dictionary<String, String>
            var request = URLRequest(url: URL(string: urlstring)!)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                DispatchQueue.main.async {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                        let data = json["success"] as? [String: Any]
                        let posts = data?["products"] as? [[String: AnyObject]]
                        
                    } catch let error as NSError {
                        print(error)
                    }
                }
                
            })
            
            task.resume()
            
        }
        
    }
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return subFreamsArray.count
    }

    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "freamimage", for: indexPath as IndexPath) as! WishlistImageViewCell
        
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        let imagePath = ((subFreamsArray[indexPath.row] as AnyObject).value(forKey: "image") as! String)
        
        let url = URL(string: imagePath)
        let data = try? Data(contentsOf: url!)
        if let imageData = data {
            cell.image.image = UIImage(data: imageData)
        }
    
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        indexPathmain = indexPath.row
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true) //here.....

        let sku = ((subFreamsArray[indexPath.row] as AnyObject).value(forKey: "sku") as! String)
        self.brandname.text = ((subFreamsArray[indexPath.row] as AnyObject).value(forKey: "brand") as! String)
        self.skuname.text = ((subFreamsArray[indexPath.row] as AnyObject).value(forKey: "sku") as! String)
        
        let url = URL(string: "https://d1.lk.api.ditto.com/comparison/?ditto_id="+dittoid+"&product_id="+sku)
        let data = try? Data(contentsOf: url!)
        if let imageData = data {
            self.fullimage.image = UIImage(data: imageData)
        }
    }
    
    
    func setimage(_ index: Int ) {
        
        if (index > -1 && index < 300) {
            
            let indexpath = IndexPath(row: index, section: 0)
            if let cell = wishlistview.cellForItem(at: indexpath) as? WishlistImageViewCell {
                cell.isSelected = true
            }
            wishlistview.scrollToItem(at: indexpath, at: .centeredHorizontally, animated: true) //here.....

            let sku = ((subFreamsArray[index] as AnyObject).value(forKey: "sku") as! String)
            self.brandname.text = ((subFreamsArray[index] as AnyObject).value(forKey: "brand") as! String)
            self.skuname.text = ((subFreamsArray[index] as AnyObject).value(forKey: "sku") as! String)
            let url = URL(string: "https://d1.lk.api.ditto.com/comparison/?ditto_id="+dittoid+"&product_id="+sku)
            let data = try? Data(contentsOf: url!)
            if let imageData = data {
                self.fullimage.image = UIImage(data: imageData)
            }
            let string = "\(wishlistedProduct)"
            if let intnumebr = Int(skuname.text!){
                if string.contains("\(intnumebr)") {
                    addiconOutlet.setImage( UIImage.init(named: "ic_add_circle_red"), for: .normal)
                }else {
                    addiconOutlet.setImage( UIImage.init(named: "ic_add_circle_48px"), for: .normal)
                }
                
            }
        }
    }
    
    
    
}

