//
//  CloudKit Manager.swift
//  AR Kit Practice
//
//  Created by Matthew Fails on 2/10/25.
//

import CloudKit
import RealityKit

class CloudKitManager {
    private let container = CKContainer.default()
    private let database = CKContainer.default().publicCloudDatabase
    
    func fetchUSDZModel(named modelName: String, completion: @escaping (URL?) -> Void) {
        let predicate = NSPredicate(format: "name == %@", modelName)
        let query = CKQuery(recordType: "USDZModels", predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { results, error in
            if let error = error {
                print("Error fetching USDZ file: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let record = results?.first,
                  let asset = record["usdzFile"] as? CKAsset,
                  let fileURL = asset.fileURL else {
                print("No USDZ file found.")
                completion(nil)
                return
            }
            
            completion(fileURL)
        }
    }
}

