//
//  HLSData.swift
//  download_test
//
//  Created by Ahmet on 09.02.2022.
//

import Foundation
import AVFoundation

public typealias ProgressParameter = (Double) -> Void
public typealias FinishParameter = (String) -> Void
public typealias ErrorParameter = (Error) -> Void

public class HLSData {
    public enum State: String {
        case notDownloaded
        case downloading
        case downloaded
    }
    
    enum Result {
        case success
        case failure(Error)
    }
    
    // MARK: Properties
    
    /// Identifier name.
    public let name: String
    /// Target AVURLAsset that have HLS URL.
    public let urlAsset: AVURLAsset
    /// Local url path that saved for offline playback. return nil if not downloaded.
    public var localUrl: URL? {
        /// Get relative path from HLSData.plist file
        guard let relativePath = AssetStore.path(forName: name) else { return nil }
        /// Get localURL which should be in home directory
        return SessionManager.shared.homeDirectoryURL.appendingPathComponent(relativePath)
    }
    
    /// Download state.
    public var state: State {
        
        /// If file exists in home directory then state is downloaded
        if SessionManager.shared.assetExists(forName: name) {
            return .downloaded
        }
        
        /// If asset has in downloadingMap then state is downloading
        if let _ = SessionManager.shared.downloadingMap.first(where: { $1 == self }) {
            return .downloading
        }
        
        /// State not downloaded
        return .notDownloaded
    }
    
    internal var result: Result?
    internal var progressClosure: ProgressParameter?
    internal var finishClosure: FinishParameter?
    internal var errorClosure: ErrorParameter?
    
    // MARK: Intialization
    
    internal init(asset: AVURLAsset, description: String) {
        name = description
        urlAsset = asset
    }
    
    /// Initialize HLSData
    ///
    /// - Parameters:
    ///   - url: HLS(m3u8) URL.
    ///   - options: AVURLAsset options.
    ///   - name: Identifier name.
    public convenience init(url: URL, options: [String: Any]? = nil, name: String) {
        let urlAsset = AVURLAsset(url: url, options: options)
        self.init(asset: urlAsset, description: name)
    }
    
    // MARK: Method
    
    /// Restore downloading tasks. You should call this method in AppDelegate.
    public static func restoreDownloadsTasks() {
        _ = SessionManager.shared
    }
    
    /// Start download HLS stream data as asset. Should delete asset when you want to re-download HLS stream, simply ignore if exist same HLSData.
    ///
    /// - Parameter closure: Progress closure.
    /// - Returns: Chainable self instance.
    @discardableResult
    public func download(progress closure: ProgressParameter? = nil) -> Self {
        progressClosure = closure
        SessionManager.shared.downloadStream(self)
        return self
    }
    
    /// Set progress closure.
    ///
    /// - Parameter closure: Progress closure that will invoke when download each time range files.
    /// - Returns: Chainable self instance.
    @discardableResult
    public func progress(progress closure: @escaping ProgressParameter) -> Self {
        progressClosure = closure
        return self
    }
    
    /// Set finish(success) closure.
    ///
    /// - Parameter closure: Finish closure that will invoke when successfully finished download media.
    /// - Returns: Chainable self instance.
    @discardableResult
    public func finish(relativePath closure: @escaping FinishParameter) -> Self {
        finishClosure = closure
        if let result = result, case .success = result {
            closure(AssetStore.path(forName: name) ?? "")
        }
        return self
    }
    
    /// Set failure closure.
    ///
    /// - Parameter closure: Finish closure that will invoke when failure finished download media.
    /// - Returns: Chainable self instance.
    @discardableResult
    public func onError(error closure: @escaping ErrorParameter) -> Self {
        print(#function)
        errorClosure = closure
        if let result = result, case .failure(let err) = result {
            print(#function+"-> go into closure")
            closure(err)
        }
        return self
    }
    
    /// Cancel download.
    public func cancelDownload() {
        print(#function)
        SessionManager.shared.cancelDownload(self)
    }
    
    
}

extension HLSData: Equatable {}

public func == (lhs: HLSData, rhs: HLSData) -> Bool {
    return (lhs.name == rhs.name) && (lhs.urlAsset == rhs.urlAsset)
}

extension HLSData: CustomStringConvertible {
    
    public var description: String {
        return "\(name), \(urlAsset.url)"
    }
}
