//
//  M.I.R_algorithm.swift
//  Non-Editable-Social-Media
//
//  Created by James McArdle on 29/03/2021.
//

import Foundation
import ImageIO
import PhotosUI

class MIR_algorithm {
    var screenWidth: Int = Int(UIScreen.main.nativeBounds.width)
    var screenHeight: Int = Int(UIScreen.main.nativeBounds.height)
    
    func testImage(results: [PHPickerResult]) -> Bool {
        
        for item in results {
            let image = item.itemProvider
            let registeredTypes = image.registeredTypeIdentifiers
            
            for type in registeredTypes {
                if !type.contains("jpg") || !type.contains("HEIC") {
//                    print("Rejected: only .jpg and .HEIC allowed.")
                    return false
                }
            }
            
            // metadata
            if let assetId = item.assetIdentifier {
                let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
                let date = assetResults.firstObject?.creationDate
                let modDate = assetResults.firstObject?.modificationDate
                let imageHeight = assetResults.firstObject?.pixelHeight
                let imageWidth = assetResults.firstObject?.pixelWidth
                let dateStr = date?.description
                let modStr = modDate?.description
                if dateStr != nil && modStr != nil {
                    if String(((dateStr?.prefix(15))!)) != String((modStr?.prefix(15))!) {
//                        print("Rejected: creation date does not match modification date")
                        return false
                    }
                }
                
                if screenHeight == imageHeight && screenWidth == imageWidth {
//                    print("Rejected: screenshot detected")
                    return false
                }
            }
        }
//        print("Accepted: image has not been modified")
        return true
    }
}


//
//print("*****************\nAsset: \(assetId),\ndate: \(date?.description), \nlocation: \(gps), \nmodification date: \(modDate?.description), \nburstIdentifier: \(burst), \nimage height type: \(imageHeight)\n*******************\n")
//let gps = assetResults.firstObject?.location?.coordinate
//let burst = assetResults.firstObject?.sourceType

