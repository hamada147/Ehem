//
//  ItemsReceivedDelegate.swift
//  Ehem
//
//  Created by Ahmed Moussa on 9/21/18.
//  Copyright © 2018 Moussa Tech. All rights reserved.
//

protocol ItemsReceivedDelegate {
    func itemsDidReceive(items: Array<DeliveryItem>)
    func itemsFaildToRetrieve(errorMessage: String)
    func itemsEmpty()
}
