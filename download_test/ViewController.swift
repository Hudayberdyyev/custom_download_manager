//
//  ViewController.swift
//  download_test
//
//  Created by Ahmet on 09.02.2022.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - Properties
    var sources = [HLSData]()

    
    //MARK: - UIControl elements

    lazy private var startDownloadButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(K.Buttons.startDownloadButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(startDownloadButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy private var cancelDownloadButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(K.Buttons.cancelDownloadButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(cancelDownloadButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy private var percentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "percentage"
        return label
    }()
    
    //MARK: - Initializers and deinitializers
    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    //MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        view.backgroundColor = .systemBlue
        setupViews()
        
        sources.append(HLSData(
                        url: URL(
                            string: "https://video.film.belet.me/45505/480/ff27c84a-6a13-4429-b830-02385592698b.m3u8")!, name: "social_network"))
        
        print(SessionManager.shared.homeDirectoryURL)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
    }
    
    @objc func willEnterForeground() {
        print(#function)
        
        guard sources.count > 0,
              let downloadTask = SessionManager.shared.getDownloadTask(sources[0]),
              let hlsData = SessionManager.shared.downloadingMap[downloadTask] else {return}
        
        print("\(#function) -> safely retrieve completed")
        
        hlsData.progress { percentage in
            DispatchQueue.main.async {
                self.percentLabel.text = "\(percentage)"
                print(percentage)
            }
        }
        
    }
}

//MARK: - Gestures

extension ViewController {
    @objc func startDownloadButtonTapped() {
        print(#function)
        let hlsData = sources[0]
        switch hlsData.state {
        case .notDownloaded:
            hlsData.download { (percent) in
                DispatchQueue.main.async {
                    print("percent = \(percent)")
                    self.percentLabel.text = "\(percent)"
                }
            }.finish { (relativePath) in
                DispatchQueue.main.async {
                    print("download completed relative path = \(relativePath)")
                }
            }.onError { (error) in
                print("Error finish. \(error)")
            }
        case .downloading:
            print("State is downloading")
            break
        case .downloaded:
            print(hlsData.localUrl ?? "localURL is nil")
        }
    }
    
    @objc func cancelDownloadButtonTapped() {
        print(#function)
        let hlsData = sources[0]
        hlsData.cancelDownload()
    }
}


//MARK: - UIControls constraints
extension ViewController {
    private func setupViews() {
        print(#function)
        setupStartDownloadButton()
        setupCancelDownloadButton()
        setupPercentLabel()
    }
    
    private func setupStartDownloadButton() {
        print(#function)
        self.view.addSubview(startDownloadButton)
        startDownloadButton.backgroundColor = .systemOrange
        NSLayoutConstraint.activate([
            startDownloadButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            startDownloadButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            startDownloadButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20),
            startDownloadButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupCancelDownloadButton() {
        print(#function)
        self.view.addSubview(cancelDownloadButton)
        cancelDownloadButton.backgroundColor = .systemPink
        NSLayoutConstraint.activate([
            cancelDownloadButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            cancelDownloadButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            cancelDownloadButton.topAnchor.constraint(equalTo: self.startDownloadButton.bottomAnchor, constant: 20),
            cancelDownloadButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupPercentLabel() {
        print(#function)
        self.view.addSubview(percentLabel)
        percentLabel.backgroundColor = .gray
        NSLayoutConstraint.activate([
            percentLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            percentLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            percentLabel.topAnchor.constraint(equalTo: self.cancelDownloadButton.bottomAnchor, constant: 20),
            percentLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

