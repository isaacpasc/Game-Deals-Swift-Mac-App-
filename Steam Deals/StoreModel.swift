//
//  StoreModel.swift
//  Steam Deals
//
//  Created by Isaac Paschall on 10/14/21.
//

import Foundation

struct Store:Codable {
    let storeID: String?
    let storeName: String?
    let isActive: Int?
    let images: Image?
}

struct Image:Codable {
    let banner: String?
    let logo: String?
    let icon: String?
}
/*
 {"storeID":"1",
 "storeName":"Steam",
 "isActive":1,
 "images":{"banner":"\/img\/stores\/banners\/0.png",
        "logo":"\/img\/stores\/logos\/0.png",
        "icon":"\/img\/stores\/icons\/0.png"}
 */
