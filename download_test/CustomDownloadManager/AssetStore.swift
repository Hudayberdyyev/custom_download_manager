//
//  AssetStore.swift
//  download_test
//
//  Created by Ahmet on 09.02.2022.
//

import Foundation

//MARK: - HLSData.plist file in user home directory which contains (key, value) pairs.
// Key = name of video
// Path = path of video

internal struct AssetStore {
    
    //MARK: - Properties

    /// Empty dictionary
    private static let emptyDictionary: [String: String] = [:]
    
    /// Shared instance
    private static var shared: [String: String] = {
        /// Safely getting storeURL else return nil
        guard let storeURL = storeURL else {return emptyDictionary}
        
        /// Check if we has the file in this path
        if FileManager.default.fileExists(atPath: storeURL.path) {
            
            /// Safely getting contents which stored in storeURL
            guard let dictionary = NSDictionary(contentsOf: storeURL) as? [String : String] else {
                /// Something went wrong return empty dictionary
                return emptyDictionary
            }
            
            /// Return obtained dictionary
            return dictionary
        }
        
        /// Finally if file hasn't in the file system then return empty dictionary
        return emptyDictionary
    }()
    
    private static let storeURL: URL? = {
        /// Get user home directory
        let lib = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        
        /// If hasn't path then return nil
        if lib.count == 0 { return nil }
        
        /// Get first path
        let library = lib[0]
        
        /// Create a HLSData file in user home directory with extension plist and return it
        return URL(fileURLWithPath: library).appendingPathComponent(K.FileStorage.AssetStoreInfoFile.name).appendingPathExtension(K.FileStorage.AssetStoreInfoFile.extension)
    }()
    
    static func allMap() -> [String: String] {
        return shared
    }
    
    static func path(forName: String) -> String? {
        /// If we has a file with name "forName" then get path to this file
        if let path = shared[forName] {
            return path
        }
        /// Else return nil
        return nil
    }
    
    @discardableResult
    static func set(path: String, forName: String) -> Bool {
        /// Safely getting storeURL else return nil
        guard let storeURL = storeURL else {return false}
        
        /// Set to path of this element (which name = forName)
        shared[forName] = path
        
        /// Get dictionary for shared
        let dict = shared as NSDictionary
        
        /// Write dictionary to storeURL
        return dict.write(to: storeURL, atomically: true)
    }
    
    @discardableResult
    static func remove(forName: String) -> Bool {
        /// Safely getting storeURL else return nilk
        guard let _ = shared.removeValue(forKey: forName),
              let storeURL = storeURL else { return false }
        
        /// Getting shared data as Dictionary
        let dict = shared as NSDictionary
        
        /// Write dictionary to storeURL
        return dict.write(to: storeURL, atomically: true)
    }
}
