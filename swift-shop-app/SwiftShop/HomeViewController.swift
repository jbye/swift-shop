//
//  HomeViewController.swift
//  SwiftShop
//
//  Created by John Alexander Bye on 23/01/15.
//  Copyright (c) 2015 SwiftShop. All rights reserved.
//

import UIKit
import Alamofire

class HomeViewController: UIViewController, RNFrostedSidebarDelegate, SwipeViewDataSource, SwipeViewDelegate {
    
    var sidebar: RNFrostedSidebar!
    var swipeView: SwipeView!
    var products: [Dictionary<String,AnyObject>] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let leftButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"),
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "handleMenuButtonTap")
        navigationItem.leftBarButtonItem = leftButton
        
        let btn: MIBadgeButton = MIBadgeButton()
        btn.frame = CGRect(x: 0, y: 0, width: 32, height: 32);
        btn.setImage(UIImage(named: "shopping_cart"), forState: UIControlState.Normal)
        btn.badgeString = "2"
        btn.badgeEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 12)
        
        let cartButton: UIBarButtonItem = UIBarButtonItem(customView: btn)
        navigationItem.rightBarButtonItem = cartButton
        
        let sidebarImages: [UIImage] = [
            UIImage(named: "menu_icon_search")!,
            UIImage(named: "menu_icon_profile")!,
            UIImage(named: "menu_icon_location")!
        ]
        sidebar = RNFrostedSidebar(images: sidebarImages)
        sidebar.delegate = self
        
        self.swipeView = SwipeView(frame: CGRect(x: 0, y: 64, width: 375, height: 604))
        self.swipeView.backgroundColor = UIColor.clearColor()
        self.swipeView.wrapEnabled = true
        self.view.addSubview(self.swipeView)
        
        self.swipeView.delegate = self
        self.swipeView.dataSource = self
        
        getProducts()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleMenuButtonTap() {
        sidebar.show()
    }
    
    func handleShoppingCartTap() {
    }
    
    func handleFavoriteButtonTap(sender: AnyObject?) {
        let btn = sender as UIButton!
        btn.selected = !btn.selected
        
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject("TRUE", forKey: String(btn.tag))
    }
    
    func swipeView(swipeView: SwipeView!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        let product: Dictionary<String,AnyObject> = self.products[index]
        
        let view = UIView(frame: CGRectMake(0, 0,
            swipeView.frame.size.width, swipeView.frame.size.height))
        
        let imageView = UIImageView(frame: CGRectMake(0, 0, 375, 250)) //UIImageView(image: UIImage(named: "0172.jpg"))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.alpha = 0.9
        imageView.backgroundColor = UIColor.whiteColor()
        imageView.sd_setImageWithURL(NSURL(string: product["image_url"] as String!))
        view.addSubview(imageView)
        
        let favoriteButton = UIButton(frame: CGRectMake(325, 205, 32, 32))
        favoriteButton.setImage(UIImage(named: "heart_empty"), forState: UIControlState.Normal)
        favoriteButton.setImage(UIImage(named: "heart_filled"), forState: UIControlState.Selected)
        favoriteButton.addTarget(self, action: "handleFavoriteButtonTap:", forControlEvents: UIControlEvents.TouchUpInside)
        favoriteButton.tag = product["id"] as Int!
        
        let productStatus = NSUserDefaults.standardUserDefaults().objectForKey(String(favoriteButton.tag))
        favoriteButton.selected = productStatus != nil
        
        view.addSubview(favoriteButton)
        
        let titleLabel = UILabel(frame: CGRectMake(15, 260, 345, 28))
        titleLabel.text = product["title"] as String!
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name: "HelveticaNeue-Italic", size: 24.0)
        titleLabel.shadowColor = UIColor.purpleColor()
        view.addSubview(titleLabel)
        
        let priceLabel = UILabel(frame: CGRectMake(15, 298, 345, 20))
        let price = product["price"] as Float!
        priceLabel.text = NSString(format: "%.f,-", price)
        priceLabel.textAlignment = NSTextAlignment.Right
        priceLabel.textColor = UIColor.whiteColor()
        priceLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18.0)
        view.addSubview(priceLabel)
        
        let brandLabel = UILabel(frame: CGRectMake(15, 298, 345, 20))
        brandLabel.text = product["brand_title"] as String!
        brandLabel.textColor = UIColor.whiteColor()
        brandLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 16.0)
        view.addSubview(brandLabel)
        
        let descriptionLabel = UILabel(frame: CGRectMake(15, 330, 345, 200))
        descriptionLabel.text = product["description"] as String!
        descriptionLabel.textColor = UIColor.whiteColor()
        descriptionLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 18.0)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.sizeToFit()
        view.addSubview(descriptionLabel)
        
        let addToCartButton = UIButton(frame: CGRectMake(15, 540, 345, 40))
        addToCartButton.setTitle("Add to cart", forState: UIControlState.Normal)
        view.addSubview(addToCartButton)
        
        return view
    }
    
    func numberOfItemsInSwipeView(swipeView: SwipeView!) -> Int {
        return self.products.count
    }
    
    func getProducts() {
        // Do any additional setup after loading the view, typically from a nib.
        
        Alamofire.request(.GET, "http://172.16.9.194:3000/products")
            .responseJSON { (_, _, JSON, _) in
                let data = JSON as NSArray!
                for productData in data {
                    var product: Dictionary<String,AnyObject> = [
                        "id": productData.valueForKeyPath("id") as Int!,
                        "title": productData.valueForKeyPath("title") as String!,
                        "description": productData.valueForKeyPath("description") as String!,
                        "price": productData.valueForKeyPath("price") as Float!,
                        "brand_title": productData.valueForKeyPath("brand.title") as String!,
                        "image_url": productData.valueForKeyPath("image_url") as String!,
                        "favorite": false
                    ]
                    self.products.append(product)
                    println(product.description)
                }
                
                self.swipeView.reloadData()
        }
    }

}
