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
        
        // Prevent content behind navbar
        self.edgesForExtendedLayout = UIRectEdge.None
        
        setupNavBar()
        setupSidebar()
        setupSwipeView()
        
        fetchAndDisplayProducts()
    }
    
    func setupNavBar() {
        // Do any additional setup after loading the view.
        let menuBarButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"),
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "handleMenuButtonTap")
        navigationItem.leftBarButtonItem = menuBarButton
        
        let cartButton: MIBadgeButton = MIBadgeButton()
        cartButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32);
        cartButton.setImage(UIImage(named: "shopping_cart"), forState: UIControlState.Normal)
        cartButton.badgeString = "2"
        cartButton.badgeEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 12)
        cartButton.addTarget(self, action: "handleShoppingCartTap", forControlEvents: UIControlEvents.TouchUpInside)
        
        let cartBarButton: UIBarButtonItem = UIBarButtonItem(customView: cartButton)
        navigationItem.rightBarButtonItem = cartBarButton
    }
    
    func setupSidebar() {
        let sidebarImages: [UIImage] = [
            UIImage(named: "menu_icon_search")!,
            UIImage(named: "menu_icon_profile")!,
            UIImage(named: "menu_icon_location")!
        ]
        sidebar = RNFrostedSidebar(images: sidebarImages)
        sidebar.delegate = self
    }
    
    func setupSwipeView() {
        self.swipeView = SwipeView(frame: CGRect(x: 0, y: 0,
            width: Constants.View.VIEW_W, height: Constants.View.VIEW_H))
        self.swipeView.backgroundColor = UIColor.clearColor()
        self.swipeView.wrapEnabled = true
        self.view.addSubview(self.swipeView)
        
        self.swipeView.delegate = self
        self.swipeView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func handleMenuButtonTap() {
        sidebar.show()
    }
    
    func handleShoppingCartTap() {
        NSLog("Not yet implemented")
    }
    
    func handleAddToCartTap() {
        NSLog("Not yet implemented")
    }
    
    func handleFavoriteButtonTap(sender: AnyObject?) {
        let btn = sender as UIButton!
        btn.selected = !btn.selected
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            btn.transform = CGAffineTransformMakeScale(1.2, 1.2)
        }) { (Bool) -> Void in
            UIView.animateWithDuration(0.2, animations: { () -> Void in
            btn.transform = CGAffineTransformMakeScale(0.8, 0.8)
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    btn.transform = CGAffineTransformMakeScale(1.0, 1.0)
                })
            })
        }

        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject("TRUE", forKey: String(btn.tag))
    }
    
    func swipeView(swipeView: SwipeView!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        let product: Dictionary<String,AnyObject> = self.products[index]
        
        let view = UIView(frame: CGRectMake(0, 0,
            swipeView.frame.size.width, swipeView.frame.size.height))
        
        let imageView = UIImageView(frame: CGRectMake(0, 0, Constants.View.VIEW_W, 250))
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
        
        let productStatus: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey(String(favoriteButton.tag))
        favoriteButton.selected = productStatus != nil
        
        view.addSubview(favoriteButton)
        
        let titleLabel = UILabel(frame: CGRectMake(Constants.View.MARGIN, 260,
            Constants.View.CONTENT_W, 28))
        titleLabel.text = product["title"] as String!
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name: "HelveticaNeue-Italic", size: 24.0)
        titleLabel.shadowColor = UIColor.purpleColor()
        view.addSubview(titleLabel)
        
        let priceLabel = UILabel(frame: CGRectMake(Constants.View.MARGIN, 298,
            Constants.View.CONTENT_W, 20))
        let price = product["price"] as Float!
        priceLabel.text = NSString(format: "%.f,-", price)
        priceLabel.textAlignment = NSTextAlignment.Right
        priceLabel.textColor = UIColor.whiteColor()
        priceLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18.0)
        view.addSubview(priceLabel)
        
        let brandLabel = UILabel(frame: CGRectMake(Constants.View.MARGIN, 298,
            Constants.View.CONTENT_W, 20))
        brandLabel.text = product["brand_title"] as String!
        brandLabel.textColor = UIColor.whiteColor()
        brandLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 18.0)
        view.addSubview(brandLabel)
        
        let descriptionLabel = UILabel(frame: CGRectMake(Constants.View.MARGIN, 330,
            Constants.View.CONTENT_W, 200))
        descriptionLabel.text = product["description"] as String!
        descriptionLabel.textColor = UIColor.whiteColor()
        descriptionLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 18.0)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.sizeToFit()
        view.addSubview(descriptionLabel)
        
        let addToCartButton = UIButton(frame: CGRectMake(Constants.View.MARGIN, 540,
            Constants.View.CONTENT_W, 40))
        addToCartButton.setTitle("Add to cart", forState: UIControlState.Normal)
        addToCartButton.addTarget(self, action: "handleAddToCartTap", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(addToCartButton)
        
        return view
    }
    
    func numberOfItemsInSwipeView(swipeView: SwipeView!) -> Int {
        return self.products.count
    }
    
    func fetchAndDisplayProducts() {
        Alamofire.request(.GET, Constants.API.products)
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
                }
                self.swipeView.reloadData()
        }
    }
    
}
