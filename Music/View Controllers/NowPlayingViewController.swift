//
//  songViewController.swift
//  Music
//
//  Created by Lucas Alward on 3/10/22.
//

import UIKit
import AVKit

class NowPlayingViewController: UIViewController {

    var sliderManiuplatingPlaybackTimeLabels = false
    
    @IBOutlet weak var moreBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var dismissBarButtonItem: UIBarButtonItem!
    
    @IBAction func dismissBarButtonItemPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBOutlet weak var baseSongImageView: UIImageView!
    //@IBOutlet weak var songImageView: UIImageView!
    var songImageViews: [(String, UIImageView)] = []
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var songPlaybackTimeSlider: UISlider!
    @IBOutlet weak var songPlaybackTimeElapsedLabel: UILabel!
    @IBOutlet weak var songPlaybackTimeRemainingLabel: UILabel!
    
    @IBOutlet weak var songPlaybackTimeElapsedLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var songPlaybackTimeRemainingLabelConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var songPreviousTrackButton: UIButton!
    @IBOutlet weak var songBack15Button: UIButton!
    @IBOutlet weak var songPauseButton: UIButton!
    @IBOutlet weak var songPlayButton: UIButton!
    @IBOutlet weak var songForward15Button: UIButton!
    @IBOutlet weak var songNextTrackButton: UIButton!
    
    @IBAction func songPreviousTrackButtonPressed(_ sender: Any) {
        var previousSongImageViewIndex = songImageViews.firstIndex(where: { $0.0 == "previous" })
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 30, delay: 0) {
            print("ABS:", self.view.constraints.filter({ constraint in
                if let firstItem = constraint.firstItem as? UIView, firstItem == self.songImageViews[previousSongImageViewIndex!].1 {
                    return true
                }
                if let secondItem = constraint.secondItem as? UIView, secondItem == self.songImageViews[previousSongImageViewIndex!].1 {
                    return true
                }
                return false
            }))
            NSLayoutConstraint.deactivate(self.view.constraints.filter({ constraint in
                if let firstItem = constraint.firstItem as? UIView, firstItem == self.songImageViews[previousSongImageViewIndex!].1 {
                    return true
                }
                if let secondItem = constraint.secondItem as? UIView, secondItem == self.songImageViews[previousSongImageViewIndex!].1 {
                    return true
                }
                return false
            }))
            print("ABS:", self.view.constraints.filter({ constraint in
                if let firstItem = constraint.firstItem as? UIView, firstItem == self.songImageViews[previousSongImageViewIndex!].1 {
                    return true
                }
                if let secondItem = constraint.secondItem as? UIView, secondItem == self.songImageViews[previousSongImageViewIndex!].1 {
                    return true
                }
                return false
            }))
            self.songImageViews[previousSongImageViewIndex!].1.translatesAutoresizingMaskIntoConstraints = false
            self.songImageViews[previousSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[previousSongImageViewIndex!].1.heightAnchor).isActive = true
            self.songImageViews[previousSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor).isActive = true
            self.songImageViews[previousSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor).isActive = true
            self.songImageViews[previousSongImageViewIndex!].1.leadingAnchor.constraint(equalTo: self.baseSongImageView.leadingAnchor).isActive = true
            self.songImageViews[previousSongImageViewIndex!].1.trailingAnchor.constraint(equalTo: self.baseSongImageView.trailingAnchor).isActive = true
            self.view.layoutIfNeeded()
        }
        
        /*if MusicAPI.shared.canGoPreviousTrack() {
            MusicAPI.shared.previousTrack()
        }*/
    }
    @IBAction func songBack15ButtonPressed(_ sender: Any) {
        MusicAPI.shared.seek(to: MusicAPI.shared.getPlaybackTimeSeconds() - 15)
    }
    @IBAction func songPauseButtonPressed(_ sender: Any) {
        if !MusicAPI.shared.isPaused() {
            MusicAPI.shared.pause()
        }
    }
    @IBAction func songPlayButtonPressed(_ sender: Any) {
        if MusicAPI.shared.isPaused() {
            MusicAPI.shared.play()
        }
    }
    @IBAction func songForward15ButtonPressed(_ sender: Any) {
        MusicAPI.shared.seek(to: MusicAPI.shared.getPlaybackTimeSeconds() + 15)
    }
    @IBAction func songNextTrackButtonPressed(_ sender: Any) {
        if MusicAPI.shared.canGoNextTrack() {
            MusicAPI.shared.nextTrack()
        }
    }
    
    @IBAction func songPlaybackTimeSliderChanged(_ sender: Any) {
        sliderManiuplatingPlaybackTimeLabels = true
        movePlaybackTimeLabelsIfNeeded()
        self.songPlaybackTimeElapsedLabel.text = MusicAPI.shared.simulatePlaybackTimeString(for: Double(self.songPlaybackTimeSlider.value))
        self.songPlaybackTimeRemainingLabel.text = "-" + MusicAPI.shared.simulatePlaybackTimeRemainingString(for: Double(self.songPlaybackTimeSlider.value))
    }
    @IBAction func songPlaybackTimeSliderReleased(_ sender: Any) {
        sliderManiuplatingPlaybackTimeLabels = false
        movePlaybackTimeLabelsIfNeeded()
        MusicAPI.shared.seek(to: Double(self.songPlaybackTimeSlider.value))
    }
    @IBAction func songPlaybackTimeSliderReleasedOutside(_ sender: Any) {
        songPlaybackTimeSliderReleased(sender)
    }
    
    @IBOutlet weak var upNextTitleLabel: UILabel!
    @IBOutlet weak var upNextArtistLabel: UILabel!
    @IBOutlet weak var upNextHeaderLabel: UILabel!
    
    @IBOutlet weak var outputPickerView: UIView!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var addToPlaylistButton: UIButton!
    @IBOutlet weak var lyricsButton: UIButton!
    @IBOutlet weak var upNextButton: UIButton!
    
    @IBAction func dislikeButtonPressed(_ sender: Any) {
        MusicAPI.shared.dislike { state in
            DispatchQueue.main.async {
                self.updateRateButtons(with: state)
            }
        }
    }
    @IBAction func likeButtonPressed(_ sender: Any) {
        MusicAPI.shared.like { state in
            DispatchQueue.main.async {
                self.updateRateButtons(with: state)
            }
        }
    }
    
    var routePickerView: AVRoutePickerView?
    var foregroundColor: UIColor?
    
    func updateRateButtons(with state: MusicAPI.Like) {
        switch state.status {
        case .like:
            self.dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
            self.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        case .dislike:
            self.dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
            self.likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        case .indifferent:
            self.dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
            self.likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        }
    }
    
    func movePlaybackTimeLabelsIfNeeded() {
        if songPlaybackTimeSlider.value <= 0.075 * songPlaybackTimeSlider.maximumValue {
            if songPlaybackTimeElapsedLabelConstraint.constant != 11 {
                songPlaybackTimeElapsedLabelConstraint.constant = 11
                songPlaybackTimeElapsedLabel.layoutIfNeeded()
            }
        } else {
            if songPlaybackTimeElapsedLabelConstraint.constant != 5 {
                songPlaybackTimeElapsedLabelConstraint.constant = 5
                songPlaybackTimeElapsedLabel.layoutIfNeeded()
            }
        }
        
        if songPlaybackTimeSlider.value >= 0.925 * songPlaybackTimeSlider.maximumValue {
            if songPlaybackTimeRemainingLabelConstraint.constant != 11 {
                songPlaybackTimeRemainingLabelConstraint.constant = 11
                songPlaybackTimeRemainingLabel.layoutIfNeeded()
            }
        } else {
            if songPlaybackTimeRemainingLabelConstraint.constant != 5 {
                songPlaybackTimeRemainingLabelConstraint.constant = 5
                songPlaybackTimeRemainingLabel.layoutIfNeeded()
            }
        }
    }
    
    func updateColors(for image: UIImage) {
        guard !animatingTrackPan else { return }
        DispatchQueue.main.async {
            guard let averageColor = image.averageColor else { return }

            UIView.animate(withDuration: 0.25) {
                self.view.backgroundColor = averageColor
            }
            
            self.foregroundColor = averageColor.isDarkColor ? UIColor(named: "lightNowPlayingForeground") : .init(named: "darkNowPlayingForeground")//UIColor.white : .black
            let secondaryColor = averageColor.isDarkColor ? UIColor(named: "lightNowPlayingSecondary") : .init(named: "darkNowPlayingSecondary")
            
            self.songTitleLabel.textColor = self.foregroundColor
            self.songArtistLabel.textColor = self.foregroundColor
            self.songPlaybackTimeSlider.minimumTrackTintColor = self.foregroundColor
            self.songPlaybackTimeSlider.thumbTintColor = self.foregroundColor
            self.songPlaybackTimeElapsedLabel.textColor = self.foregroundColor
            self.songPreviousTrackButton.tintColor = self.foregroundColor
            self.songNextTrackButton.tintColor = self.foregroundColor
            self.songBack15Button.tintColor = self.foregroundColor
            self.songForward15Button.tintColor = self.foregroundColor
            self.songPauseButton.tintColor = self.foregroundColor
            self.songPlayButton.tintColor = self.foregroundColor
            
            self.upNextTitleLabel.textColor = self.foregroundColor
            self.upNextArtistLabel.textColor = self.foregroundColor
            
            self.routePickerView?.tintColor = self.foregroundColor
            self.dislikeButton.tintColor = self.foregroundColor
            self.likeButton.tintColor = self.foregroundColor
            self.addToPlaylistButton.tintColor = self.foregroundColor
            self.lyricsButton.tintColor = self.foregroundColor
            self.upNextButton.tintColor = self.foregroundColor
            
            self.dismissBarButtonItem.tintColor = secondaryColor
            self.moreBarButtonItem.tintColor = secondaryColor
            self.navigationController?.navigationBar.titleTextAttributes?[.foregroundColor] = secondaryColor
            
            self.upNextHeaderLabel.textColor = secondaryColor
            
            self.songPlaybackTimeSlider.maximumTrackTintColor = secondaryColor
            self.songPlaybackTimeRemainingLabel.textColor = secondaryColor
        }
    }
    
    func updateColors(for averageColor: UIColor) {
        self.view.backgroundColor = averageColor
        /*
        self.foregroundColor = averageColor.isDarkColor ? UIColor(named: "lightNowPlayingForeground") : .init(named: "darkNowPlayingForeground")//UIColor.white : .black
        let secondaryColor = averageColor.isDarkColor ? UIColor(named: "lightNowPlayingSecondary") : .init(named: "darkNowPlayingSecondary")
        
        self.songTitleLabel.textColor = self.foregroundColor
        self.songArtistLabel.textColor = self.foregroundColor
        self.songPlaybackTimeSlider.minimumTrackTintColor = self.foregroundColor
        self.songPlaybackTimeSlider.thumbTintColor = self.foregroundColor
        self.songPlaybackTimeElapsedLabel.textColor = self.foregroundColor
        self.songPreviousTrackButton.tintColor = self.foregroundColor
        self.songNextTrackButton.tintColor = self.foregroundColor
        self.songBack15Button.tintColor = self.foregroundColor
        self.songForward15Button.tintColor = self.foregroundColor
        self.songPauseButton.tintColor = self.foregroundColor
        self.songPlayButton.tintColor = self.foregroundColor
        
        self.upNextTitleLabel.textColor = self.foregroundColor
        self.upNextArtistLabel.textColor = self.foregroundColor
        
        self.routePickerView?.tintColor = self.foregroundColor
        self.dislikeButton.tintColor = self.foregroundColor
        self.likeButton.tintColor = self.foregroundColor
        self.addToPlaylistButton.tintColor = self.foregroundColor
        self.lyricsButton.tintColor = self.foregroundColor
        self.upNextButton.tintColor = self.foregroundColor
        
        self.dismissBarButtonItem.tintColor = secondaryColor
        self.moreBarButtonItem.tintColor = secondaryColor
        self.navigationController?.navigationBar.titleTextAttributes?[.foregroundColor] = secondaryColor
        
        self.upNextHeaderLabel.textColor = secondaryColor
        
        self.songPlaybackTimeSlider.maximumTrackTintColor = secondaryColor
        self.songPlaybackTimeRemainingLabel.textColor = secondaryColor*/
    }
    
    func setupSongImageViews(previous: MusicAPI.Song?, current: MusicAPI.Song?, next: MusicAPI.Song?) {
        var previousSongImageViewIndex = songImageViews.firstIndex(where: { $0.0 == "previous" })
        if previousSongImageViewIndex == nil {
            let previousSongImageView = UIImageView()
            previousSongImageView.layer.cornerRadius = 10
            previousSongImageView.layer.masksToBounds = true
            view.addSubview(previousSongImageView)
            previousSongImageView.translatesAutoresizingMaskIntoConstraints = false
            previousSongImageView.widthAnchor.constraint(equalTo: previousSongImageView.heightAnchor).isActive = true
            previousSongImageView.topAnchor.constraint(equalTo: baseSongImageView.topAnchor, constant: 40).isActive = true
            previousSongImageView.bottomAnchor.constraint(equalTo: baseSongImageView.bottomAnchor, constant: -40).isActive = true
            previousSongImageView.trailingAnchor.constraint(equalTo: baseSongImageView.leadingAnchor, constant: -40).isActive = true
            previousSongImageViewIndex = songImageViews.count
            songImageViews.append(("previous", previousSongImageView))
        }
        
        if let previous = previous {
            songImageViews[previousSongImageViewIndex!].1.sd_setImage(with: URL(string: previous.image.url), placeholderImage: UIImage(named: "musicCoverImagePlaceholder"))
        } else {
            songImageViews[previousSongImageViewIndex!].1.image = UIImage(named: "musicCoverImagePlaceholder")
        }
        
        var currentSongImageViewIndex = songImageViews.firstIndex(where: { $0.0 == "current" })
        if currentSongImageViewIndex == nil {
            let currentSongImageView = UIImageView()
            currentSongImageView.layer.cornerRadius = 10
            currentSongImageView.layer.masksToBounds = true
            view.addSubview(currentSongImageView)
            currentSongImageView.translatesAutoresizingMaskIntoConstraints = false
            currentSongImageView.widthAnchor.constraint(equalTo: currentSongImageView.heightAnchor).isActive = true
            currentSongImageView.topAnchor.constraint(equalTo: baseSongImageView.topAnchor).isActive = true
            currentSongImageView.bottomAnchor.constraint(equalTo: baseSongImageView.bottomAnchor).isActive = true
            currentSongImageView.leadingAnchor.constraint(equalTo: baseSongImageView.leadingAnchor).isActive = true
            currentSongImageView.trailingAnchor.constraint(equalTo: baseSongImageView.trailingAnchor).isActive = true
            currentSongImageViewIndex = songImageViews.count
            songImageViews.append(("current", currentSongImageView))
        }
        
        if let current = current {
            songImageViews[currentSongImageViewIndex!].1.sd_setImage(with: URL(string: current.image.url), placeholderImage: UIImage(named: "musicCoverImagePlaceholder")) { image, _, _, _ in
                if let image = image {
                    self.updateColors(for: image)
                }
            }
        } else {
            songImageViews[currentSongImageViewIndex!].1.image = UIImage(named: "musicCoverImagePlaceholder")
        }
        
        var nextSongImageViewIndex = songImageViews.firstIndex(where: { $0.0 == "next" })
        if nextSongImageViewIndex == nil {
            let nextSongImageView = UIImageView()
            nextSongImageView.layer.cornerRadius = 10
            nextSongImageView.layer.masksToBounds = true
            view.addSubview(nextSongImageView)
            nextSongImageView.translatesAutoresizingMaskIntoConstraints = false
            nextSongImageView.widthAnchor.constraint(equalTo: nextSongImageView.heightAnchor).isActive = true
            nextSongImageView.topAnchor.constraint(equalTo: baseSongImageView.topAnchor, constant: 40).isActive = true
            nextSongImageView.bottomAnchor.constraint(equalTo: baseSongImageView.bottomAnchor, constant: -40).isActive = true
            nextSongImageView.leadingAnchor.constraint(equalTo: baseSongImageView.trailingAnchor, constant: 40).isActive = true
            nextSongImageViewIndex = songImageViews.count
            songImageViews.append(("next", nextSongImageView))
        }
        
        if let next = next {
            songImageViews[nextSongImageViewIndex!].1.sd_setImage(with: URL(string: next.image.url), placeholderImage: UIImage(named: "musicCoverImagePlaceholder"))
        } else {
            songImageViews[nextSongImageViewIndex!].1.image = UIImage(named: "musicCoverImagePlaceholder")
        }
    }
    
    var trackPanGestureRecognizer: UIPanGestureRecognizer!
    
    var previousTrackAnimator: UIViewPropertyAnimator!
    var nextTrackAnimator: UIViewPropertyAnimator!
    
    var animatingTrackPan = false
    
    func setupTrackPanning() {
        trackPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(trackPan(_:)))
        
        view.addGestureRecognizer(trackPanGestureRecognizer)
    }
        
    @objc func trackPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view!)
        
        if sender.state == .began {
            animatingTrackPan = true
            previousTrackAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1.0)
            nextTrackAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1.0)
            
            let previousSongImageViewIndex = self.songImageViews.firstIndex(where: { $0.0 == "previous" })
            let currentSongImageViewIndex = self.songImageViews.firstIndex(where: { $0.0 == "current" })
            let nextSongImageViewIndex = self.songImageViews.firstIndex(where: { $0.0 == "next" })
            
            let previousSongImageViewAverageColor = self.songImageViews[previousSongImageViewIndex!].1.image!.averageColor!
            
            previousTrackAnimator.addAnimations {
                NSLayoutConstraint.deactivate(self.view.constraints.filter({ constraint in
                    if
                        let firstItem = constraint.firstItem as? UIView,
                        [
                            self.songImageViews[previousSongImageViewIndex!].1,
                            self.songImageViews[currentSongImageViewIndex!].1,
                            self.songImageViews[nextSongImageViewIndex!].1
                        ].contains(firstItem)
                    {
                        return true
                    }
                    if
                        let secondItem = constraint.secondItem as? UIView,
                        [
                            self.songImageViews[previousSongImageViewIndex!].1,
                            self.songImageViews[currentSongImageViewIndex!].1,
                            self.songImageViews[nextSongImageViewIndex!].1
                        ].contains(secondItem)
                    {
                        return true
                    }
                    return false
                }))
                
                self.songImageViews[previousSongImageViewIndex!].1.translatesAutoresizingMaskIntoConstraints = false
                self.songImageViews[previousSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[previousSongImageViewIndex!].1.heightAnchor).isActive = true
                self.songImageViews[previousSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor).isActive = true
                self.songImageViews[previousSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor).isActive = true
                self.songImageViews[previousSongImageViewIndex!].1.leadingAnchor.constraint(equalTo: self.baseSongImageView.leadingAnchor).isActive = true
                self.songImageViews[previousSongImageViewIndex!].1.trailingAnchor.constraint(equalTo: self.baseSongImageView.trailingAnchor).isActive = true
                
                self.updateColors(for: previousSongImageViewAverageColor)
                
                self.songImageViews[currentSongImageViewIndex!].1.translatesAutoresizingMaskIntoConstraints = false
                self.songImageViews[currentSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[currentSongImageViewIndex!].1.heightAnchor).isActive = true
                self.songImageViews[currentSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor, constant: 40).isActive = true
                self.songImageViews[currentSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor, constant: -40).isActive = true
                self.songImageViews[currentSongImageViewIndex!].1.leadingAnchor.constraint(equalTo: self.baseSongImageView.trailingAnchor, constant: 40).isActive = true
                
                self.songImageViews[nextSongImageViewIndex!].1.translatesAutoresizingMaskIntoConstraints = false
                self.songImageViews[nextSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[nextSongImageViewIndex!].1.heightAnchor).isActive = true
                self.songImageViews[nextSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor, constant: 80).isActive = true
                self.songImageViews[nextSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor, constant: -80).isActive = true
                self.songImageViews[nextSongImageViewIndex!].1.leadingAnchor.constraint(equalTo: self.baseSongImageView.trailingAnchor, constant: 80).isActive = true
                
                self.view.layoutIfNeeded()
            }
            
            previousTrackAnimator.addCompletion { _ in
                let previousSongImageViewIndex = self.songImageViews.firstIndex(where: { $0.0 == "previous" })
                let currentSongImageViewIndex = self.songImageViews.firstIndex(where: { $0.0 == "current" })
                let nextSongImageViewIndex = self.songImageViews.firstIndex(where: { $0.0 == "next" })
                
                NSLayoutConstraint.deactivate(self.view.constraints.filter({ constraint in
                    if
                        let firstItem = constraint.firstItem as? UIView,
                        [
                            self.songImageViews[previousSongImageViewIndex!].1,
                            self.songImageViews[currentSongImageViewIndex!].1,
                            self.songImageViews[nextSongImageViewIndex!].1
                        ].contains(firstItem)
                    {
                        return true
                    }
                    if
                        let secondItem = constraint.secondItem as? UIView,
                        [
                            self.songImageViews[previousSongImageViewIndex!].1,
                            self.songImageViews[currentSongImageViewIndex!].1,
                            self.songImageViews[nextSongImageViewIndex!].1
                        ].contains(secondItem)
                    {
                        return true
                    }
                    return false
                }))
                
                self.songImageViews[previousSongImageViewIndex!].1.translatesAutoresizingMaskIntoConstraints = false
                self.songImageViews[currentSongImageViewIndex!].1.translatesAutoresizingMaskIntoConstraints = false
                self.songImageViews[nextSongImageViewIndex!].1.translatesAutoresizingMaskIntoConstraints = false
                
                if !self.previousTrackAnimator.isReversed {
                    self.songImageViews[previousSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[previousSongImageViewIndex!].1.heightAnchor).isActive = true
                    self.songImageViews[previousSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor).isActive = true
                    self.songImageViews[previousSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor).isActive = true
                    self.songImageViews[previousSongImageViewIndex!].1.leadingAnchor.constraint(equalTo: self.baseSongImageView.leadingAnchor).isActive = true
                    self.songImageViews[previousSongImageViewIndex!].1.trailingAnchor.constraint(equalTo: self.baseSongImageView.trailingAnchor).isActive = true
                    
                    self.updateColors(for: self.songImageViews[previousSongImageViewIndex!].1.image!)
                    
                    self.songImageViews[currentSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[currentSongImageViewIndex!].1.heightAnchor).isActive = true
                    self.songImageViews[currentSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor, constant: 40).isActive = true
                    self.songImageViews[currentSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor, constant: -40).isActive = true
                    self.songImageViews[currentSongImageViewIndex!].1.leadingAnchor.constraint(equalTo: self.baseSongImageView.trailingAnchor, constant: 40).isActive = true
                    
                    self.songImageViews[nextSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[nextSongImageViewIndex!].1.heightAnchor).isActive = true
                    self.songImageViews[nextSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor, constant: 80).isActive = true
                    self.songImageViews[nextSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor, constant: -80).isActive = true
                    self.songImageViews[nextSongImageViewIndex!].1.leadingAnchor.constraint(equalTo: self.baseSongImageView.trailingAnchor, constant: 80).isActive = true
                } else {
                    self.songImageViews[previousSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[previousSongImageViewIndex!].1.heightAnchor).isActive = true
                    self.songImageViews[previousSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor, constant: 40).isActive = true
                    self.songImageViews[previousSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor, constant: -40).isActive = true
                    self.songImageViews[previousSongImageViewIndex!].1.trailingAnchor.constraint(equalTo: self.baseSongImageView.leadingAnchor, constant: -40).isActive = true
                    
                    self.songImageViews[currentSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[currentSongImageViewIndex!].1.heightAnchor).isActive = true
                    self.songImageViews[currentSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor).isActive = true
                    self.songImageViews[currentSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor).isActive = true
                    self.songImageViews[currentSongImageViewIndex!].1.leadingAnchor.constraint(equalTo: self.baseSongImageView.leadingAnchor).isActive = true
                    self.songImageViews[currentSongImageViewIndex!].1.trailingAnchor.constraint(equalTo: self.baseSongImageView.trailingAnchor).isActive = true
                    
                    self.updateColors(for: self.songImageViews[currentSongImageViewIndex!].1.image!)
                    
                    self.songImageViews[nextSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[nextSongImageViewIndex!].1.heightAnchor).isActive = true
                    self.songImageViews[nextSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor, constant: 40).isActive = true
                    self.songImageViews[nextSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor, constant: -40).isActive = true
                    self.songImageViews[nextSongImageViewIndex!].1.leadingAnchor.constraint(equalTo: self.baseSongImageView.trailingAnchor, constant: 40).isActive = true
                }
                
                self.view.layoutIfNeeded()
            }
            
            let nextSongImageViewAverageColor = self.songImageViews[nextSongImageViewIndex!].1.image!.averageColor!
            
            nextTrackAnimator.addAnimations {
                NSLayoutConstraint.deactivate(self.view.constraints.filter({ constraint in
                    if
                        let firstItem = constraint.firstItem as? UIView,
                        [
                            self.songImageViews[previousSongImageViewIndex!].1,
                            self.songImageViews[currentSongImageViewIndex!].1,
                            self.songImageViews[nextSongImageViewIndex!].1
                        ].contains(firstItem)
                    {
                        return true
                    }
                    if
                        let secondItem = constraint.secondItem as? UIView,
                        [
                            self.songImageViews[previousSongImageViewIndex!].1,
                            self.songImageViews[currentSongImageViewIndex!].1,
                            self.songImageViews[nextSongImageViewIndex!].1
                        ].contains(secondItem)
                    {
                        return true
                    }
                    return false
                }))
                
                self.songImageViews[nextSongImageViewIndex!].1.translatesAutoresizingMaskIntoConstraints = false
                self.songImageViews[nextSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[nextSongImageViewIndex!].1.heightAnchor).isActive = true
                self.songImageViews[nextSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor).isActive = true
                self.songImageViews[nextSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor).isActive = true
                self.songImageViews[nextSongImageViewIndex!].1.leadingAnchor.constraint(equalTo: self.baseSongImageView.leadingAnchor).isActive = true
                self.songImageViews[nextSongImageViewIndex!].1.trailingAnchor.constraint(equalTo: self.baseSongImageView.trailingAnchor).isActive = true
                
                self.updateColors(for: nextSongImageViewAverageColor)
                
                self.songImageViews[currentSongImageViewIndex!].1.translatesAutoresizingMaskIntoConstraints = false
                self.songImageViews[currentSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[currentSongImageViewIndex!].1.heightAnchor).isActive = true
                self.songImageViews[currentSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor, constant: 40).isActive = true
                self.songImageViews[currentSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor, constant: -40).isActive = true
                self.songImageViews[currentSongImageViewIndex!].1.trailingAnchor.constraint(equalTo: self.baseSongImageView.leadingAnchor, constant: -40).isActive = true
                
                self.songImageViews[previousSongImageViewIndex!].1.translatesAutoresizingMaskIntoConstraints = false
                self.songImageViews[previousSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[previousSongImageViewIndex!].1.heightAnchor).isActive = true
                self.songImageViews[previousSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor, constant: 80).isActive = true
                self.songImageViews[previousSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor, constant: -80).isActive = true
                self.songImageViews[previousSongImageViewIndex!].1.trailingAnchor.constraint(equalTo: self.baseSongImageView.leadingAnchor, constant: -80).isActive = true
                
                self.view.layoutIfNeeded()
            }
            
            nextTrackAnimator.addCompletion { _ in
                let previousSongImageViewIndex = self.songImageViews.firstIndex(where: { $0.0 == "previous" })
                let currentSongImageViewIndex = self.songImageViews.firstIndex(where: { $0.0 == "current" })
                let nextSongImageViewIndex = self.songImageViews.firstIndex(where: { $0.0 == "next" })
                
                NSLayoutConstraint.deactivate(self.view.constraints.filter({ constraint in
                    if
                        let firstItem = constraint.firstItem as? UIView,
                        [
                            self.songImageViews[previousSongImageViewIndex!].1,
                            self.songImageViews[currentSongImageViewIndex!].1,
                            self.songImageViews[nextSongImageViewIndex!].1
                        ].contains(firstItem)
                    {
                        return true
                    }
                    if
                        let secondItem = constraint.secondItem as? UIView,
                        [
                            self.songImageViews[previousSongImageViewIndex!].1,
                            self.songImageViews[currentSongImageViewIndex!].1,
                            self.songImageViews[nextSongImageViewIndex!].1
                        ].contains(secondItem)
                    {
                        return true
                    }
                    return false
                }))
                
                self.songImageViews[previousSongImageViewIndex!].1.translatesAutoresizingMaskIntoConstraints = false
                self.songImageViews[currentSongImageViewIndex!].1.translatesAutoresizingMaskIntoConstraints = false
                self.songImageViews[nextSongImageViewIndex!].1.translatesAutoresizingMaskIntoConstraints = false
                
                if !self.nextTrackAnimator.isReversed {
                    self.songImageViews[nextSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[nextSongImageViewIndex!].1.heightAnchor).isActive = true
                    self.songImageViews[nextSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor).isActive = true
                    self.songImageViews[nextSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor).isActive = true
                    self.songImageViews[nextSongImageViewIndex!].1.leadingAnchor.constraint(equalTo: self.baseSongImageView.leadingAnchor).isActive = true
                    self.songImageViews[nextSongImageViewIndex!].1.trailingAnchor.constraint(equalTo: self.baseSongImageView.trailingAnchor).isActive = true
                    
                    self.updateColors(for: nextSongImageViewAverageColor)
                    
                    self.songImageViews[currentSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[currentSongImageViewIndex!].1.heightAnchor).isActive = true
                    self.songImageViews[currentSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor, constant: 40).isActive = true
                    self.songImageViews[currentSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor, constant: -40).isActive = true
                    self.songImageViews[currentSongImageViewIndex!].1.trailingAnchor.constraint(equalTo: self.baseSongImageView.leadingAnchor, constant: -40).isActive = true
                    
                    self.songImageViews[previousSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[previousSongImageViewIndex!].1.heightAnchor).isActive = true
                    self.songImageViews[previousSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor, constant: 80).isActive = true
                    self.songImageViews[previousSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor, constant: -80).isActive = true
                    self.songImageViews[previousSongImageViewIndex!].1.trailingAnchor.constraint(equalTo: self.baseSongImageView.leadingAnchor, constant: -80).isActive = true
                } else {
                    self.songImageViews[previousSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[previousSongImageViewIndex!].1.heightAnchor).isActive = true
                    self.songImageViews[previousSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor, constant: 40).isActive = true
                    self.songImageViews[previousSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor, constant: -40).isActive = true
                    self.songImageViews[previousSongImageViewIndex!].1.trailingAnchor.constraint(equalTo: self.baseSongImageView.leadingAnchor, constant: -40).isActive = true
                    
                    self.songImageViews[currentSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[currentSongImageViewIndex!].1.heightAnchor).isActive = true
                    self.songImageViews[currentSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor).isActive = true
                    self.songImageViews[currentSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor).isActive = true
                    self.songImageViews[currentSongImageViewIndex!].1.leadingAnchor.constraint(equalTo: self.baseSongImageView.leadingAnchor).isActive = true
                    self.songImageViews[currentSongImageViewIndex!].1.trailingAnchor.constraint(equalTo: self.baseSongImageView.trailingAnchor).isActive = true
                    
                    self.updateColors(for: self.songImageViews[currentSongImageViewIndex!].1.image!)
                    
                    self.songImageViews[nextSongImageViewIndex!].1.widthAnchor.constraint(equalTo: self.songImageViews[nextSongImageViewIndex!].1.heightAnchor).isActive = true
                    self.songImageViews[nextSongImageViewIndex!].1.topAnchor.constraint(equalTo: self.baseSongImageView.topAnchor, constant: 40).isActive = true
                    self.songImageViews[nextSongImageViewIndex!].1.bottomAnchor.constraint(equalTo: self.baseSongImageView.bottomAnchor, constant: -40).isActive = true
                    self.songImageViews[nextSongImageViewIndex!].1.leadingAnchor.constraint(equalTo: self.baseSongImageView.trailingAnchor, constant: 40).isActive = true
                }
                
                self.view.layoutIfNeeded()
            }
        }
        
        if translation.x < 0 {
            if previousTrackAnimator.isRunning {
                previousTrackAnimator.fractionComplete = 0
                previousTrackAnimator.pauseAnimation()
            }
            nextTrackAnimator.fractionComplete = min(max(0, translation.x * -1 / 300), 1)
        } else if translation.x > 0 {
            if nextTrackAnimator.isRunning {
                nextTrackAnimator.fractionComplete = 0
                nextTrackAnimator.pauseAnimation()
            }
            previousTrackAnimator.fractionComplete = min(max(0, translation.x / 300), 1)
        } else {
            if nextTrackAnimator.isRunning {
                nextTrackAnimator.fractionComplete = 0
                nextTrackAnimator.pauseAnimation()
            }
            if previousTrackAnimator.isRunning {
                previousTrackAnimator.fractionComplete = 0
                previousTrackAnimator.pauseAnimation()
            }
        }
        
        if sender.state == .ended {
            animatingTrackPan = false
            if translation.x < -150 {
                previousTrackAnimator.stopAnimation(true)
                nextTrackAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            } else if translation.x > 150 {
                nextTrackAnimator.stopAnimation(true)
                previousTrackAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            } else {
                nextTrackAnimator.isReversed = true
                nextTrackAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                previousTrackAnimator.isReversed = true
                previousTrackAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            }
        } else if sender.state == .cancelled {
            animatingTrackPan = false
            nextTrackAnimator.isReversed = true
            nextTrackAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            previousTrackAnimator.isReversed = true
            previousTrackAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTrackPanning()
        setupSongImageViews(previous: nil, current: nil, next: nil)
        
        routePickerView = AVRoutePickerView(frame: outputPickerView.frame)
        routePickerView?.tintColor = .label
        routePickerView?.activeTintColor = .init(named: "AccentColor")
        outputPickerView.addSubview(routePickerView!)
        routePickerView?.leadingAnchor.constraint(equalTo: outputPickerView.leadingAnchor).isActive = true
        routePickerView?.trailingAnchor.constraint(equalTo: outputPickerView.trailingAnchor).isActive = true
        routePickerView?.topAnchor.constraint(equalTo: outputPickerView.topAnchor).isActive = true
        routePickerView?.bottomAnchor.constraint(equalTo: outputPickerView.bottomAnchor).isActive = true
        
        if #available(iOS 14.0, *) {
            self.moreBarButtonItem.menu = UIMenu(title: "", children: [
                UIAction(title: "Download Song", image: UIImage(systemName: "square.and.arrow.down"), handler: { _ in
                    MusicAPI.shared.download { message in
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            self.present(alert, animated: true)
                        }
                    }
                }),
                UIAction(title: "Stop Playing", image: UIImage(systemName: "stop"), attributes: .destructive, handler: { _ in
                    MusicAPI.shared.stop()
                })
            ])
        } else {
            // TODO: Implement UIAlertController
        }
        
        MusicAPI.shared.register(for: .songState) {
            guard let song = MusicAPI.shared.currentlyPlayingSong() else {
                self.songTitleLabel.text = "Not Playing"
                self.songArtistLabel.text = ""
                self.setupSongImageViews(previous: nil, current: nil, next: nil)
//                self.songImageView.image = UIImage(named: "musicCoverImagePlaceholder")
                
                self.updateColors(for: UIImage(named: "musicCoverImagePlaceholder")!)
                
                self.songPreviousTrackButton.isHidden = true
                self.songBack15Button.isHidden = true
                self.songForward15Button.isHidden = true
                self.songNextTrackButton.isHidden = true
                self.songPauseButton.isHidden = true
                self.songPlayButton.isHidden = false
                self.songPlayButton.isEnabled = false
                
                self.songPlaybackTimeSlider.minimumValue = 0
                self.songPlaybackTimeSlider.maximumValue = 1
                self.songPlaybackTimeSlider.value = 0
                self.songPlaybackTimeSlider.isEnabled = false
                
                self.songPlaybackTimeElapsedLabel.isHidden = true
                self.songPlaybackTimeRemainingLabel.isHidden = true
                
                self.upNextTitleLabel.text = "Not Playing"
                self.upNextArtistLabel.text = ""
                
                self.updateRateButtons(with: MusicAPI.Like(status: .indifferent))
                
                return
            }
            
            self.songTitleLabel.text = song.title
            self.songArtistLabel.text = song.artists.joined(separator: ", ")
            
            self.setupSongImageViews(previous: MusicAPI.shared.previousSong(), current: song, next: MusicAPI.shared.upNextSong())
//            self.songImageView.sd_setImage(with: URL(string: song.image.url), placeholderImage: UIImage(named: "musicCoverImagePlaceholder")) { image, _, _, _ in
//                if let image = image {
//                    self.updateColors(for: image)
//                }
//            }
            
            self.songPauseButton.isEnabled = true
            self.songPlayButton.isEnabled = true
            self.songPauseButton.isHidden = MusicAPI.shared.isPaused()
            self.songPlayButton.isHidden = !MusicAPI.shared.isPaused()
            
            self.songPreviousTrackButton.isHidden = false
            self.songBack15Button.isHidden = false
            self.songForward15Button.isHidden = false
            self.songNextTrackButton.isHidden = false
            
            self.songPreviousTrackButton.isEnabled = MusicAPI.shared.canGoPreviousTrack()
            self.songNextTrackButton.isEnabled = MusicAPI.shared.canGoNextTrack()
            
            self.songPlaybackTimeSlider.minimumValue = 0
            self.songPlaybackTimeSlider.maximumValue = Float(MusicAPI.shared.getDurationSeconds())
            if !self.sliderManiuplatingPlaybackTimeLabels {
                self.songPlaybackTimeSlider.value = Float(MusicAPI.shared.getPlaybackTimeSeconds())
            }
            self.songPlaybackTimeSlider.isEnabled = true
            
            self.songPlaybackTimeElapsedLabel.isHidden = false
            self.songPlaybackTimeRemainingLabel.isHidden = false
            
            if !self.sliderManiuplatingPlaybackTimeLabels {
                self.songPlaybackTimeElapsedLabel.text = MusicAPI.shared.getPlaybackTimeString()
                self.songPlaybackTimeRemainingLabel.text = "-" + MusicAPI.shared.getPlaybackTimeRemainingString()
            }
            
            if let upNextSong = MusicAPI.shared.upNextSong() {
                self.upNextTitleLabel.text = upNextSong.title
                self.upNextArtistLabel.text = upNextSong.artists.joined(separator: ", ")
            } else {
                self.upNextTitleLabel.text = "None"
                self.upNextArtistLabel.text = ""
            }
            
            self.updateRateButtons(with: song.likeStatus)
            
            if MusicAPI.shared.getDurationSeconds() == 0 {
                self.songPauseButton.isHidden = true
                self.songPlayButton.isHidden = false
                self.songPlayButton.isEnabled = false
                
                self.songPlaybackTimeSlider.minimumValue = 0
                self.songPlaybackTimeSlider.maximumValue = 1
                self.songPlaybackTimeSlider.value = 0
                self.songPlaybackTimeSlider.isEnabled = false
                
                self.songPlaybackTimeElapsedLabel.isHidden = true
                self.songPlaybackTimeRemainingLabel.isHidden = true
            }
        }
        
        MusicAPI.shared.register(for: .playbackTime) {
            self.songPlaybackTimeSlider.minimumValue = 0
            self.songPlaybackTimeSlider.maximumValue = Float(MusicAPI.shared.getDurationSeconds())
            if !self.sliderManiuplatingPlaybackTimeLabels {
                self.songPlaybackTimeSlider.value = Float(MusicAPI.shared.getPlaybackTimeSeconds())
            }
            
            if !self.sliderManiuplatingPlaybackTimeLabels {
                self.songPlaybackTimeElapsedLabel.text = MusicAPI.shared.getPlaybackTimeString()
                self.songPlaybackTimeRemainingLabel.text = "-" + MusicAPI.shared.getPlaybackTimeRemainingString()
            }
            
            self.songPreviousTrackButton.isEnabled = MusicAPI.shared.canGoPreviousTrack()
            self.songNextTrackButton.isEnabled = MusicAPI.shared.canGoNextTrack()
            
            self.movePlaybackTimeLabelsIfNeeded()
            
            if MusicAPI.shared.getDurationSeconds() == 0 {
                self.songPauseButton.isHidden = true
                self.songPlayButton.isHidden = false
                self.songPlayButton.isEnabled = false
                
                self.songPlaybackTimeSlider.minimumValue = 0
                self.songPlaybackTimeSlider.maximumValue = 1
                self.songPlaybackTimeSlider.value = 0
                self.songPlaybackTimeSlider.isEnabled = false
                
                self.songPlaybackTimeElapsedLabel.isHidden = true
                self.songPlaybackTimeRemainingLabel.isHidden = true
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
