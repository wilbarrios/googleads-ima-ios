import AVFoundation
import UIKit

class ViewController: UIViewController {

  static let testAppContentURL = "https://storage.googleapis.com/gvabox/media/samples/stock.mp4"

  static let testAppAdTagURL =
    "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/"
    + "single_ad_samples&sz=640x480&cust_params=sample_ct%3Dlinear&ciu_szs=300x250%2C728x90&"
    + "gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator="

  @IBOutlet private weak var playButton: UIButton!
  @IBOutlet private weak var videoView: UIView!
  private var contentPlayer: AVPlayer?
  private var playerLayer: AVPlayerLayer?
  private var videoAdsProvider: AssemblyVideoAdProvider!

  // MARK: - View controller lifecycle methods

  override func viewDidLoad() {
    super.viewDidLoad()

    playButton.layer.zPosition = CGFloat.greatestFiniteMagnitude

    setUpContentPlayer()
      
    videoAdsProvider = AssemblyGoogleIMAAdapter(avPlayer: contentPlayer!, videoView: videoView, viewController: self)
  }

  override func viewDidAppear(_ animated: Bool) {
    playerLayer?.frame = self.videoView.layer.bounds
  }

  // MARK: Button Actions
  @IBAction func onPlayButtonTouch(_ sender: AnyObject) {
    requestAds()
    playButton.isHidden = true
  }

  // MARK: Content player methods

  private func setUpContentPlayer() {
    // Load AVPlayer with path to our content.
    guard let contentURL = URL(string: ViewController.testAppContentURL) else {
      print("ERROR: use a valid URL for the content URL")
      return
    }
    self.contentPlayer = AVPlayer(url: contentURL)
    guard let contentPlayer = self.contentPlayer else { return }

    // Create a player layer for the player.
    self.playerLayer = AVPlayerLayer(player: contentPlayer)
    guard let playerLayer = self.playerLayer else { return }

    // Size, position, and display the AVPlayer.
    playerLayer.frame = videoView.layer.bounds
    videoView.layer.addSublayer(playerLayer)
  }

  // MARK: IMA integration methods

  private func requestAds() {
    videoAdsProvider.requestAds(adTagUrl: Self.testAppAdTagURL)
  }
}
