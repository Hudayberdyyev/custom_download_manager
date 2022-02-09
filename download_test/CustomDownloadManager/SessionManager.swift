//
//  SessionManager.swift
//  download_test
//
//  Created by Ahmet on 09.02.2022.
//

import Foundation
import AVFoundation

final internal class SessionManager: NSObject, AVAssetDownloadDelegate {
    //MARK: - Properties
    
    static let shared = SessionManager()
    
    internal let homeDirectoryURL = URL(fileURLWithPath: NSHomeDirectory())
    private var session: AVAssetDownloadURLSession!
    internal var downloadingMap = [AVAssetDownloadTask : HLSData]()
    
    override private init() {
        super.init()
        /// Downloads configuration
        let configuration = URLSessionConfiguration.background(withIdentifier: K.FileStorage.DownloadsConfiguration.hlsIdentifier)
        
        /// Initialize session with downloads configuration
        session = AVAssetDownloadURLSession(configuration: configuration,
                                            assetDownloadDelegate: self,
                                            delegateQueue: OperationQueue())
        
        /// Restore downloads map
        restoreDownloadsMap()
    }
    
    private func restoreDownloadsMap() {
        
        /// Get all tasks
        session.getAllTasks { tasksArray in
            
            /// Iterate over all tasks
            for task in tasksArray {
                
                /// Safely retrieve assetDownloadTask and hlsDataName
                guard let assetDownloadTask = task as? AVAssetDownloadTask, let hlsDataName = task.taskDescription else { break }
                
                /// Initialize with obtained values
                let hlsData = HLSData(asset: assetDownloadTask.urlAsset, description: hlsDataName)
                
                /// Put into downloading map
                self.downloadingMap[assetDownloadTask] = hlsData
            }
        }
    }
    
    /// Check if file with name has exists
    func assetExists(forName: String) -> Bool {
        guard let relativePath = AssetStore.path(forName: forName) else { return false }
        let filePath = homeDirectoryURL.appendingPathComponent(relativePath).path
        return FileManager.default.fileExists(atPath: filePath)
    }
    
    /// Download stream for obtaining HLSData model
    /// If downloaded file already exists then we should return immediately
    func downloadStream(_ hlsData: HLSData) {
        print("\(#function) -> \(assetExists(forName: hlsData.name))")
        guard assetExists(forName: hlsData.name) == false else { return }
        
        guard let task = session.makeAssetDownloadTask(
                asset: hlsData.urlAsset,
                assetTitle: hlsData.name,
                assetArtworkData: nil,
                options: [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 265_000])
        else { return }
        
        task.taskDescription = hlsData.name
        downloadingMap[task] = hlsData
        
        task.resume()
    }
    
    /// Cancel download for obtaining HLSData model
    func cancelDownload(_ hlsData: HLSData) {
        print(#function)
        downloadingMap.first(where: { $1 == hlsData })?.key.cancel()
        print("\(#function) completed")
    }
    
    /// Delete asset for obtaining name
    func deleteAsset(forName: String) throws {
        /// Get relative path from HLSData.plist file
        guard let relativePath = AssetStore.path(forName: forName) else { return }
        
        /// Get absolute path with homeDirectoryURL property
        let localFileLocation = homeDirectoryURL.appendingPathComponent(relativePath)
        
        /// Attempt to remove
        do {
            try FileManager.default.removeItem(at: localFileLocation)
        } catch {
            /// Error handling
            print(error.localizedDescription)
        }
        
        /// Remove from HLSData.plist file
        AssetStore.remove(forName: forName)
    }
    
    func getDownloadTask(_ hlsData: HLSData) -> AVAssetDownloadTask? {
        print(#function)
        return downloadingMap.first(where: { $1 == hlsData })?.key
    }
    
    // MARK: AVAssetDownloadDelegate

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print(#function)
        /// Try to remove downloadTask from downloadingMap
        guard let task = task as? AVAssetDownloadTask , let hlsData = downloadingMap.removeValue(forKey: task) else { return }
        
        /// Define which type of error
        if let error = error as NSError? {
            switch (error.domain, error.code) {
            
            case (NSURLErrorDomain, NSURLErrorCancelled):
                hlsData.result = .failure(error)
                guard let localFileLocation = AssetStore.path(forName: hlsData.name) else { return }
                
                do {
                    let fileURL = homeDirectoryURL.appendingPathComponent(localFileLocation)
                    try FileManager.default.removeItem(at: fileURL)
                } catch {
                    print("An error occured trying to delete the contents on disk for \(hlsData.name): \(error)")
                }
                
            case (NSURLErrorDomain, NSURLErrorUnknown):
                hlsData.result = .failure(error)
                fatalError("Downloading HLS streams is not supported in the simulator.")
                
            default:
                hlsData.result = .failure(error)
                print("An unexpected error occured \(error.domain)")
            }
        } else {
            hlsData.result = .success
        }
        switch hlsData.result {
        case .success:
            hlsData.finishClosure?(AssetStore.path(forName: hlsData.name)!)
        case .failure(let err):
            hlsData.errorClosure?(err)
        case .none:
            let error = NSError(domain: "", code: 401, userInfo: [ NSLocalizedDescriptionKey: "HLSData result is nil"])
            hlsData.errorClosure?(error)
        }
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        print(#function)
        
        /// Safely retrieve hlsData from downloadingMap
        guard let hlsData = downloadingMap[assetDownloadTask] else { return }
        
        /// Save downloaded file info HLSData.plist file
        AssetStore.set(path: location.relativePath, forName: hlsData.name)
    }
        
    func urlSession(_ session: URLSession,
                    assetDownloadTask: AVAssetDownloadTask,
                    didLoad timeRange: CMTimeRange,
                    totalTimeRangesLoaded loadedTimeRanges: [NSValue],
                    timeRangeExpectedToLoad: CMTimeRange) {
        
        print(#function)
        
        /// Safely retrieve hlsData from downloadingMap
        guard let hlsData = downloadingMap[assetDownloadTask] else { return }
        
        /// Result will be reseted
        hlsData.result = nil
        
        /// Safely retrieve progressClosure
        guard let progressClosure = hlsData.progressClosure else { return }
        
        /// Calculate percent which completed
        let percentComplete = loadedTimeRanges.reduce(0.0) {
            let loadedTimeRange : CMTimeRange = $1.timeRangeValue
            return $0 + CMTimeGetSeconds(loadedTimeRange.duration) / CMTimeGetSeconds(timeRangeExpectedToLoad.duration)
        }
        
        /// Call closure with percentage
        progressClosure(percentComplete)
    }
}
