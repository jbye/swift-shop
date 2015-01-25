//
//  Constants.swift
//  SwiftShop
//
//  Created by John Alexander Bye on 25/01/15.
//  Copyright (c) 2015 SwiftShop. All rights reserved.
//

import Foundation

struct Constants {
    
    struct View {
        static let NAVBAR_H: CGFloat = 64
        static let MARGIN: CGFloat = 15
        static let VIEW_H: CGFloat = UIScreen.mainScreen().bounds.size.height - NAVBAR_H
        static let VIEW_W: CGFloat = UIScreen.mainScreen().bounds.size.width
        static let CONTENT_W: CGFloat = VIEW_W - (MARGIN*2)
    }
    
    struct API {
        static let baseURL: String = "http://localhost:3000"
        static let products: String = Constants.API.baseURL + "/products"
    }
    
}