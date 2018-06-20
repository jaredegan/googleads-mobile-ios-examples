//
//  Copyright (C) 2015 Google, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import GoogleMobileAds
import UIKit
import AdSupport
import CoreLocation

class ViewController: UIViewController, GADRewardBasedVideoAdDelegate {

  /// The DFP banner view.
  @IBOutlet weak var bannerView: DFPBannerView!
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Google Mobile Ads SDK version: \(DFPRequest.sdkVersion())")

        // Simulate what our app does
        startVideoAds()

        // Make banner ad request
        bannerView.adUnitID = "/1025479/Mobile_iPhone_Home_Screen_Anchor_P"
        // adUnitId from sample app: "/6499/example/banner"
        bannerView.rootViewController = self

        let request = DFPRequest()
        let extras = GADExtras()
        extras.additionalParameters = [
            "dfp_latitude": 42.361145,
            "dfp_longitude": -71.057083,
            "dfp_ad_id": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
            "dfp_dnt": !ASIdentifierManager.shared().isAdvertisingTrackingEnabled
        ]
        request.register(extras)

        bannerView.load(request)

    }

    private func startVideoAds() {
        GADRewardBasedVideoAd.sharedInstance().delegate = self
    }

    // MARK: - GADRewardBasedVideoAdDelegate
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {

    }

    @IBAction
    private func enablePushNotifications() {
        IssueReproduction.instance.askForNotificationPermission()
    }

    @IBAction
    private func enableLocationPermission() {
        IssueReproduction.instance.askForLocationPermission()
    }

    @IBAction
    private func updateLogTextField() {
        textView.text = IssueReproduction.instance.logMessage
    }
}
