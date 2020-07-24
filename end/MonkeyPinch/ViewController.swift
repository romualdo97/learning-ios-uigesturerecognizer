/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import AVFoundation

class ViewController: UIViewController {
  @IBOutlet var bananaPan: UIPanGestureRecognizer!
  @IBOutlet var monkeyPan: UIPanGestureRecognizer!
  private var chompPlayer: AVAudioPlayer?
  private var laughPlayer: AVAudioPlayer?

  func createPlayer(from filename: String) -> AVAudioPlayer? {
    guard let url = Bundle.main.url(
      forResource: filename,
      withExtension: "caf"
      ) else {
        return nil
    }
    var player = AVAudioPlayer()

    do {
      try player = AVAudioPlayer(contentsOf: url)
      player.prepareToPlay()
    } catch {
      print("Error loading \(url.absoluteString): \(error)")
    }

    return player
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()

    // 1
    let imageViews = view.subviews.filter {
      $0 is UIImageView
    }

    // 2
    for imageView in imageViews {
      // 3
      let tapGesture = UITapGestureRecognizer(
        target: self,
        action: #selector(handleTap)
      )

      // 4
      tapGesture.delegate = self
      imageView.addGestureRecognizer(tapGesture)

      tapGesture.require(toFail: monkeyPan)
      tapGesture.require(toFail: bananaPan)

      let tickleGesture = TickleGestureRecognizer(
        target: self,
        action: #selector(handleTickle)
      )
      tickleGesture.delegate = self
      imageView.addGestureRecognizer(tickleGesture)
    }

    chompPlayer = createPlayer(from: "chomp")
    laughPlayer = createPlayer(from: "laugh")
  }

  @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
    // 1
    let translation = gesture.translation(in: view)

    // 2
    guard let gestureView = gesture.view else {
      return
    }

    gestureView.center = CGPoint(
      x: gestureView.center.x + translation.x,
      y: gestureView.center.y + translation.y
    )

    // 3
    gesture.setTranslation(.zero, in: view)

    guard gesture.state == .ended else {
      return
    }

    // 4
    let velocity = gesture.velocity(in: view)
    let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
    let slideMultiplier = magnitude / 200

    // 5
    let slideFactor = 0.1 * slideMultiplier
    // 6
    var finalPoint = CGPoint(
      x: gestureView.center.x + (velocity.x * slideFactor),
      y: gestureView.center.y + (velocity.y * slideFactor)
    )

    // 7
    finalPoint.x = min(max(finalPoint.x, 0), view.bounds.width)
    finalPoint.y = min(max(finalPoint.y, 0), view.bounds.height)

    // 8
    UIView.animate(
      withDuration: Double(slideFactor * 2),
      delay: 0,
      // 9
      options: .curveEaseOut,
      animations: {
        gestureView.center = finalPoint
    })
  }
    
  @IBAction func handlePinch(_ gesture: UIPinchGestureRecognizer) {
    guard let gestureView = gesture.view else {
      return
    }

    gestureView.transform = gestureView.transform.scaledBy(
      x: gesture.scale,
      y: gesture.scale
    )
    gesture.scale = 1
  }
  
  @IBAction func handleRotate(_ gesture: UIRotationGestureRecognizer) {
    guard let gestureView = gesture.view else {
      return
    }

    gestureView.transform = gestureView.transform.rotated(
      by: gesture.rotation
    )
    gesture.rotation = 0
  }
  
  @objc func handleTap(_ gesture: UITapGestureRecognizer) {
    chompPlayer?.play()
  }

  @objc func handleTickle(_ gesture: TickleGestureRecognizer) {
    laughPlayer?.play()
  }
}

extension ViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    return true
  }
}
