//
//  FolioReaderContainer.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 15/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import FontBlaster

/// Reader container
open class FolioReaderContainer: UIViewController {
    var shouldHideStatusBar = true
    var shouldRemoveEpub = true
    
    // Mark those property as public so they can accessed from other classes/subclasses.
    public var epubPath: String
	public var unzipPath: String?
    public var book: FRBook
    
    public var centerNavigationController: UINavigationController?
    public var centerViewController: FolioReaderCenter?
    public var audioPlayer: FolioReaderAudioPlayer?
    
    public var readerConfig: FolioReaderConfig
    public var folioReader: FolioReader

    // MARK: - Init

    /// Init a Folio Reader Container
    ///
    /// - Parameters:
    ///   - config: Current Folio Reader configuration
    ///   - folioReader: Current instance of the FolioReader kit.
    ///   - path: The ePub path on system. Must not be nil nor empty string.
	///   - unzipPath: Path to unzip the compressed epub.
    ///   - removeEpub: Should delete the original file after unzip? Default to `true` so the ePub will be unziped only once.
    public init(withConfig config: FolioReaderConfig, folioReader: FolioReader, epubPath path: String, unzipPath: String? = nil, removeEpub: Bool = true) {
        self.readerConfig = config
        self.folioReader = folioReader
        self.epubPath = path
		self.unzipPath = unzipPath
        self.shouldRemoveEpub = removeEpub
        self.book = FRBook()

        super.init(nibName: nil, bundle: Bundle.frameworkBundle())

        // Configure the folio reader.
        self.folioReader.readerContainer = self

        // Initialize the default reader options.
        if self.epubPath != "" {
            self.initialization()
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        // When a FolioReaderContainer object is instantiated from the storyboard this function is called before.
        // At this moment, we need to initialize all non-optional objects with default values.
        // The function `setupConfig(config:epubPath:removeEpub:)` MUST be called afterward.
        // See the ExampleFolioReaderContainer.swift for more information?
        self.readerConfig = FolioReaderConfig()
        self.folioReader = FolioReader()
        self.epubPath = ""
        self.shouldRemoveEpub = false
        self.book = FRBook()

        super.init(coder: aDecoder)

        // Configure the folio reader.
        self.folioReader.readerContainer = self
    }

    /// Common Initialization
    fileprivate func initialization() {
        // Register custom fonts
        FontBlaster.blast(bundle: Bundle.frameworkBundle())

        // Register initial defaults
        self.folioReader.register(defaults: [
            kCurrentFontFamily: FolioReaderFont.andada.rawValue,
            kNightMode: false,
            kCurrentFontSize: 2,
            kCurrentAudioRate: 1,
            kCurrentHighlightStyle: 0,
            kCurrentTOCMenu: 0,
            kCurrentMediaOverlayStyle: MediaOverlayStyle.default.rawValue,
            kCurrentScrollDirection: FolioReaderScrollDirection.defaultVertical.rawValue
            ])
    }

    /// Set the `FolioReaderConfig` and epubPath.
    ///
    /// - Parameters:
    ///   - config: Current Folio Reader configuration
    ///   - path: The ePub path on system. Must not be nil nor empty string.
	///   - unzipPath: Path to unzip the compressed epub.
    ///   - removeEpub: Should delete the original file after unzip? Default to `true` so the ePub will be unziped only once.
    open func setupConfig(_ config: FolioReaderConfig, epubPath path: String, unzipPath: String? = nil, removeEpub: Bool = true) {
        self.readerConfig = config
        self.folioReader = FolioReader()
        self.folioReader.readerContainer = self
        self.epubPath = path
		self.unzipPath = unzipPath
        self.shouldRemoveEpub = removeEpub
    }

    // MARK: - View life cicle

    override open func viewDidLoad() {
        super.viewDidLoad()

        let canChangeScrollDirection = self.readerConfig.canChangeScrollDirection
        self.readerConfig.canChangeScrollDirection = self.readerConfig.isDirection(canChangeScrollDirection, canChangeScrollDirection, false)

        // If user can change scroll direction use the last saved
        if self.readerConfig.canChangeScrollDirection == true {
            var scrollDirection = FolioReaderScrollDirection(rawValue: self.folioReader.currentScrollDirection) ?? .vertical
            if (scrollDirection == .defaultVertical && self.readerConfig.scrollDirection != .defaultVertical) {
                scrollDirection = self.readerConfig.scrollDirection
            }

            self.readerConfig.scrollDirection = scrollDirection
        }

        let hideBars = readerConfig.hideBars
        self.readerConfig.shouldHideNavigationOnTap = ((hideBars == true) ? true : self.readerConfig.shouldHideNavigationOnTap)

        self.centerViewController = FolioReaderCenter(withContainer: self)

        if let rootViewController = self.centerViewController {
            self.centerNavigationController = UINavigationController(rootViewController: rootViewController)
        }

        centerNavigationController?.setNavigationBarHidden(readerConfig.shouldHideNavigationOnTap, animated: false)
        if let _centerNavigationController = self.centerNavigationController {
            self.view.addSubview(_centerNavigationController.view)
            self.addChild(_centerNavigationController)
        }
        self.centerNavigationController?.didMove(toParent: self)

        if (self.readerConfig.hideBars == true) {
            self.readerConfig.shouldHideNavigationOnTap = false
            self.navigationController?.navigationBar.isHidden = true
            self.centerViewController?.pageIndicatorHeight = 0
        }

        // Read async book
        guard (self.epubPath.isEmpty == false) else {
            print("Epub path is nil.")
            self.folioReader.delegate?.folioReader?(self.folioReader, error: NSError(domain:"Epub path is nil.", code:1, userInfo:nil))
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let weakSelf = self else { return }
            do {
                let parsedBook = try FREpubParser().readEpub(epubPath: weakSelf.epubPath, removeEpub: weakSelf.shouldRemoveEpub, unzipPath: weakSelf.unzipPath)
                weakSelf.book = parsedBook
                weakSelf.folioReader.isReaderOpen = true

                // Reload data
                DispatchQueue.main.async { [weak self] in
                    guard let weakSelf = self else { return }
                    // Add audio player if needed
                    if weakSelf.book.hasAudio || weakSelf.readerConfig.enableTTS {
                        weakSelf.addAudioPlayer()
                    }
                    weakSelf.centerViewController?.reloadData()
                    weakSelf.folioReader.isReaderReady = true
                    weakSelf.folioReader.delegate?.folioReader?(weakSelf.folioReader, didFinishedLoading: weakSelf.book)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    weakSelf.folioReader.delegate?.folioReader?(weakSelf.folioReader, error: error)
                }
            }
        }
    }

    /**
     Initialize the media player
     */
    func addAudioPlayer() {
        self.audioPlayer = FolioReaderAudioPlayer(withFolioReader: self.folioReader, book: self.book)
        self.folioReader.readerAudioPlayer = audioPlayer
    }

    // MARK: - Status Bar

    override open var prefersStatusBarHidden: Bool {
        return (self.readerConfig.shouldHideNavigationOnTap == false ? false : self.shouldHideStatusBar)
    }

    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return self.folioReader.isNight(.lightContent, .default)
    }
}
