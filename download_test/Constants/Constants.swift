//
//  Constants.swift
//  download_test
//
//  Created by Ahmet on 09.02.2022.
//

import Foundation

struct K {
    struct Buttons {
        static let startDownloadButtonTitle = "Download"
        static let cancelDownloadButtonTitle = "Cancel"
    }
    
    struct FileStorage {
        struct AssetStoreInfoFile {
            static let name = "HLSData"
            static let `extension` = "plist"
        }
        
        struct DownloadsConfiguration {
            static let hlsIdentifier = "BeletFilmsHLSDownloadsIdentifier"
        }
    }
}
