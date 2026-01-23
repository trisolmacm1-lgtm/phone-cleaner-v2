// NativeAdViewFactory.swift

import Foundation
import GoogleMobileAds
import Flutter
import UIKit
import google_mobile_ads

enum AdScaleType {
    case small
    case medium
    case large
}

class NativeAdViewFactory: NSObject, FLTNativeAdFactory {
    private let adScaleType: AdScaleType

    init(adScaleType: AdScaleType) {
        self.adScaleType = adScaleType
    }

    func createNativeAd(
        _ nativeAd: NativeAd,
        customOptions: [AnyHashable: Any]? = nil
    ) -> NativeAdView {
        let nibName: String
        switch adScaleType {
        case .small:
            nibName = "NativeAdSmall"
        case .medium:
            nibName = "NativeAdMedium"
        case .large:
            nibName = "NativeAdLarge"
        }

        guard let nibObjects = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil),
              let adView = nibObjects.first as? NativeAdView else {
            fatalError("Could not load nib file: \(nibName)")
        }

        // Styling (gradients, rounded corners) is now handled by custom classes (GradientButton, GradientLabel)
        // and properties set in the XIB files. No manual styling is needed here.

        populate(adView: adView, with: nativeAd)
        return adView
    }

    private func populate(adView: NativeAdView, with nativeAd: NativeAd) {
        adView.nativeAd = nativeAd

        (adView.headlineView as? UILabel)?.text = nativeAd.headline
        adView.headlineView?.isHidden = nativeAd.headline == nil

        (adView.bodyView as? UILabel)?.text = nativeAd.body
        adView.bodyView?.isHidden = nativeAd.body == nil

        (adView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        adView.callToActionView?.isHidden = nativeAd.callToAction == nil
        adView.callToActionView?.isUserInteractionEnabled = false


        if let iconView = adView.iconView as? UIImageView, let icon = nativeAd.icon {
            iconView.image = icon.image
            iconView.isHidden = false
        } else {
            adView.iconView?.isHidden = true
        }

        if let mediaView = adView.mediaView {
            mediaView.mediaContent = nativeAd.mediaContent
            mediaView.isHidden = nativeAd.mediaContent == nil
        }

        if let starRatingView = adView.starRatingView as? UIImageView, let starRating = nativeAd.starRating {
            let ratingValue = Int(starRating.doubleValue.rounded())
            var starImage: UIImage?
            switch ratingValue {
            case 1:
                starImage = UIImage(named: "start_1")
            case 2:
                starImage = UIImage(named: "start_2")
            case 3:
                starImage = UIImage(named: "start_3")
            case 4:
                starImage = UIImage(named: "start_4")
            case 5:
                starImage = UIImage(named: "start_5")
            default:
                break // No image for other ratings
            }
            starRatingView.image = starImage
            starRatingView.isHidden = starImage == nil
        } else {
            adView.starRatingView?.isHidden = true
        }
    }
}
