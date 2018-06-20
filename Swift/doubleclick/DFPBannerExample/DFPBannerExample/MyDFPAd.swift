//
//  MyDFPAd.swift
//  DFPBannerExample
//
//  Created by Jared Egan on 6/20/18.
//  Copyright © 2018 Google. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MyDFPAd: NSObject, GADBannerViewDelegate, GADAdSizeDelegate {
    var bannerView: DFPBannerView = DFPBannerView(adSize: kGADAdSizeFluid)

    // MARK: - Init
    // ...

    // MARK: - GADAdSizeDelegate
    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {

    }

    // MARK: - GADBannerViewDelegate

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("hooray")
    }

}
