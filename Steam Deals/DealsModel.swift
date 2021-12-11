//
//  DealsModel.swift
//  Steam Deals
//
//  Created by Isaac Paschall on 10/13/21.
//

import Foundation

struct Deal:Codable {
    let internalName: String?
    let title: String?
    let metacriticLink: String?
    let dealID: String?
    let storeID: String?
    let gameID: String?
    let salePrice: String?
    let normalPrice: String?
    let isOnSale: String?
    let savings: String?
    let metacriticScore: String?
    let steamRatingText: String?
    let steamRatingPercent: String?
    let steamRatingCount: String?
    let steamAppID: String?
    let releaseDate: Int?
    let lastChange: Int?
    let dealRating: String?
    let thumb: String?
}

/*
 {
     "internalName": "DUNGEONSIEGEII",
     "title": "Dungeon Siege II",
     "metacriticLink": "/game/pc/dungeon-siege-ii",
     "dealID": "yump1xHYf6GNwK9HJJSKDUPFFSFDetGTtptGxualJZ4%3D",
     "storeID": "1",
     "gameID": "305",
     "salePrice": "0.97",
     "normalPrice": "6.99",
     "isOnSale": "1",
     "savings": "86.123033",
     "metacriticScore": "80",
     "steamRatingText": "Mostly Positive",
     "steamRatingPercent": "71",
     "steamRatingCount": "1617",
     "steamAppID": "39200",
     "releaseDate": 1124150400,
     "lastChange": 1621540944,
     "dealRating": "8.9",
     "thumb": "https://cdn.cloudflare.steamstatic.com/steam/apps/39200/capsule_sm_120.jpg?t=1592491309"
   },
 */
