//
//  CollectionViewController.swift
//  LookrStore
//
//  Created by Keshav Gangwal on 20/06/19.
//  Copyright © 2019 Lenskart. All rights reserved.
//

import UIKit

class CollectionViewController: BaseViewController ,
UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var dittoid = "" ,token = "" , mnumber = "", filterglassstring="Sunglasses"
    var products = ""
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var share: UIImageView!
    @IBOutlet weak var back: UIImageView!
    
    var collectionviewArray = [[String : AnyObject]]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapshare = UITapGestureRecognizer(target: self, action: #selector(CollectionViewController.tappedmeshare))
        let tapback = UITapGestureRecognizer(target: self, action: #selector(CollectionViewController.tappedMeback))

        back.addGestureRecognizer(tapback)
        back.isUserInteractionEnabled = true
        share.addGestureRecognizer(tapshare)
        share.isUserInteractionEnabled = true
        collectionview.dataSource = self
        collectionview.delegate = self
        
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
        
        getcomparisonproduct()
       
        
    }
    
    
    func getcomparisonproduct(){
        if let intnumebr = Int(mnumber){
            let urlstring = "https://labs.lenskart.com/v108/lookr/api/getcomparisonproduct?mobile=\(intnumebr)&dittoid=\(dittoid)"
            
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
                    let data = json["success"] as? [String: Any]
                    let posts = data?["products"] as? [[String: AnyObject]]
                    self.collectionviewArray = posts!
                    self.collectionview.reloadData()
                   
                    
                } catch let error as NSError {
                    print(error)
                }
                
            })
            
            task.resume()
            
        }
        
    }
    

    @objc func tappedMeback(){
        DispatchQueue.main.async {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let balanceViewController = storyBoard.instantiateViewController(withIdentifier: "wishlistui") as! WishlistViewController
            self.present(balanceViewController, animated: true, completion: nil)
        }
        //self.view.removeFromSuperview()
    }
    
    @objc func tappedmeshare()
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "shareui") as! ShareCollectionViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
    }

    
    //MARK:
    //MARK: Collection view Delegete and Datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return collectionviewArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> UIEdgeInsets{
        
        let totalCellWidth = 80 * collectionView.numberOfItems(inSection: 0)
        let totalSpacingWidth = 10 * (collectionView.numberOfItems(inSection: 0) - 1)
        
        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
        
        //  return CGSize(width: (collectionView.frame.size.width - 30 ) / 2 , height: (UIScreen.main.bounds.size.height * (180/667)) + 15)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print(indexPath.section , indexPath.row ,collectionView.tag)
        
        // get a reference to our storyboard cell
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectioncell", for: indexPath as IndexPath) as! CollectionimageViewController
        

        let sku = ((collectionviewArray[indexPath.row] as AnyObject).value(forKey: "sku") as! String)
        let fimage = ((collectionviewArray[indexPath.row] as AnyObject).value(forKey: "image") as! String)

        let skuurl = URL(string: "https://d1.lk.api.ditto.com/comparison/?ditto_id="+dittoid+"&product_id="+sku)
        
        let data = try? Data(contentsOf: skuurl!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        
        let task = URLSession.shared.dataTask(with: skuurl!) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async() {    // execute on main thread
                cell.imageview.image = UIImage(data: data)
            }
        }
        
       
        let furl = URL(string: fimage)
        
        let fdata = try? Data(contentsOf: furl!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        
        let ftask = URLSession.shared.dataTask(with: furl!) { fdata, response, error in
            guard let fdata = fdata, error == nil else { return }
            
            DispatchQueue.main.async() {    // execute on main thread
                cell.framsimage.image = UIImage(data: fdata)
            }
        }
        
        
        task.resume()
        ftask.resume()

        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
    
    
    
}