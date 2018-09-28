//
//  MainViewPresenter.swift
//  Lalamove
//
//  Created by Ahmed Moussa on 9/16/18.
//  Copyright © 2018 Moussa Tech. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class MainViewPresenter {
    let API = "https://mock-api-mobile.dev.lalamove.com/deliveries"
    var ItemsToDeliver: Array<DeliveryItem> = []
    let viewController: MainViewController
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    init(viewController: MainViewController) {
        self.viewController = viewController
    }
    
    func getSavedData() {
        // get only items that has not been delivered
        self.ItemsToDeliver.removeAll()
        let request: NSFetchRequest<DeliveryItem> = DeliveryItem.fetchRequest()
        let predicate = NSPredicate(format: "itemDelivered == %@", "false")
        request.predicate = predicate
        do {
            self.ItemsToDeliver = try self.context.fetch(request)
            viewController.itemsDidReceive(items: self.ItemsToDeliver)
        } catch {
            print("Unresolved error fetching data from context \(error)")
        }
    }
    
    func getOffset() -> Int {
        let request: NSFetchRequest<DeliveryItem> = DeliveryItem.fetchRequest()
        request.fetchLimit = 1
        
        let predicate = NSPredicate(format: "id==max(id)")
        request.predicate = predicate
        
        var offset64: Int64? = nil
        
        do {
            let result = try self.context.fetch(request).first
            offset64 = result?.id
        } catch {
            print("Unresolved error in retriving max id value \(error)")
        }
        
        if (offset64 == nil) {
            return 0
        } else {
            guard let offset = Int(exactly: offset64!) else {
                print("error in converting value from Int64 to Int")
                return 0
            }
            return offset
        }
    }
    
    func getData() {
        let offset: Int = self.getOffset()
        let parameters: [String : Int] = ["offset": offset, "limit": 20]
        Alamofire.request(API, method: .get, parameters: parameters).responseJSON { response in
            if (response.result.isSuccess) {
                let data: JSON = JSON(response.result.value!)
                self.parseData(data)
            } else {
                // print("failed \(String(describing: response.result.error))")
                self.viewController.itemsFaildToRetrieve(errorMessage: response.result.error!.localizedDescription)
            }
        }
    }
    
    func parseData(_ data: JSON) {
        if (data != JSON.null && data.array?.count != nil && data.array!.count > 0) {
            let tempImageData = UIImage(imageLiteralResourceName: "tempDelivery").jpegData(compressionQuality: 0.7)!
            let thread = DispatchQueue(label: "DownloadImageFromURL")
            for i in 0..<data.array!.count {
                let curr = data.array![i]
                let newItem = DeliveryItem(context: self.context)
                newItem.id = Int64(curr["id"].int!)
                newItem.itemDescription = curr["description"].string!
                newItem.imageUrl = curr["imageUrl"].string!
                newItem.image = tempImageData
                let loc = Location(context: self.context)
                loc.address = curr["location"]["address"].string!
                loc.lat = curr["location"]["lat"].double!
                loc.lng = curr["location"]["lng"].double!
                newItem.deliveryLocation = loc
                self.ItemsToDeliver.append(newItem)
                // DO something async to update the image data value
                thread.async {
                    self.getImageFromURL(newItem)
                }
            }
            do {
                try self.context.save()
            } catch {
                print("Unresolved error while saving data \(error)")
            }
        } else {
            // no data
            print("no data")
            self.viewController.itemsEmpty()
        }
        self.viewController.itemsDidReceive(items: self.ItemsToDeliver)
    }
    
    private func getImageFromURL(_ item: DeliveryItem) {
        let failedImage: Data = UIImage(imageLiteralResourceName: "tempDelivery").jpegData(compressionQuality: 0.7)!
        guard let url: URL = URL(string: item.imageUrl!) else {
            item.image = failedImage
            return
        }
        guard let imageData: Data = try? Data(contentsOf: url) else {
            item.image = failedImage
            return
        }
        item.image = imageData
        do {
            try self.context.save()
            NotificationCenter.default.post(name: .DeliveryItemImageDownloaded, object: nil)
        } catch {
            print("Unresolved error while updating image data \(error)")
        }
    }
    
    /*
    private func tempDataForTesting() {
        self.ItemsToDeliver.append(DeliveryItemDetails(id: 0, description: "This is description #1", imageUrl: "https://www.what-dog.net/Images/faces2/scroll0015.jpg", lat: 22.336093, lng: 114.155288, address: "Cheung Sha Wan"))
        self.ItemsToDeliver.append(DeliveryItemDetails(id: 1, description: "This is description #1", imageUrl: "https://www.what-dog.net/Images/faces2/scroll0015.jpg", lat: 22.336093, lng: 114.155288, address: "Cheung Sha Wan"))
        self.ItemsToDeliver.append(DeliveryItemDetails(id: 2, description: "This is description #1", imageUrl: "https://www.what-dog.net/Images/faces2/scroll0015.jpg", lat: 22.336093, lng: 114.155288, address: "Cheung Sha Wan"))
        self.ItemsToDeliver.append(DeliveryItemDetails(id: 3, description: "This is description #1", imageUrl: "https://www.what-dog.net/Images/faces2/scroll0015.jpg", lat: 22.336093, lng: 114.155288, address: "Cheung Sha Wan"))
        self.ItemsToDeliver.append(DeliveryItemDetails(id: 4, description: "This is description #1", imageUrl: "https://www.what-dog.net/Images/faces2/scroll00g", lat: 22.336093, lng: 114.155288, address: "Cheung Sha Wan"))
    }
     */
    
}
