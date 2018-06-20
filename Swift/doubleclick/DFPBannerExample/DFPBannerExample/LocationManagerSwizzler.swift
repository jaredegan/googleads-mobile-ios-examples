//
//  LocationManagerSwizzler.swift
//  DFPBannerExample
//
//  Created by Jared Egan on 6/20/18.
//  Copyright © 2018 Google. All rights reserved.
//

import UIKit
import CoreLocation

public extension DispatchQueue {
    private static var _onceTracker = [String]()

    public class func once(file: String = #file, function: String = #function, line: Int = #line, block:(Void)->Void) {
        let token = file + ":" + function + ":" + String(line)
        once(token: token, block: block)
    }

    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.

     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block:(Void)->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }


        if _onceTracker.contains(token) {
            return
        }

        _onceTracker.append(token)
        block()
    }
}


extension CLLocationManager {
    open override class func initialize() {
//        struct Static {
//            static var token: dispatch_once_t = 0
//        }

        // make sure this isn't a subclass
        if self !== CLLocationManager.self {
            return
        }

        DispatchQueue.once {
            // Start updating

                let originalSelector = #selector(CLLocationManager.startUpdatingLocation)
                let swizzledSelector = #selector(CLLocationManager.test_startUpdatingLocation)

                let originalMethod = class_getInstanceMethod(self, originalSelector)
                let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

                let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

                if didAddMethod {
                    class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
                } else {
                    method_exchangeImplementations(originalMethod, swizzledMethod)
                }


            // Stop updating

            let originalSelector_stop = #selector(CLLocationManager.stopUpdatingLocation)
            let swizzledSelector_stop = #selector(CLLocationManager.test_stopUpdatingLocation)

            let originalMethod_stop = class_getInstanceMethod(self, originalSelector_stop)
            let swizzledMethod_stop = class_getInstanceMethod(self, swizzledSelector_stop)

            let didAddMethod_stop = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod_stop), method_getTypeEncoding(swizzledMethod_stop))

            if didAddMethod_stop {
                class_replaceMethod(self, swizzledSelector_stop, method_getImplementation(originalMethod_stop), method_getTypeEncoding(originalMethod_stop))
            } else {
                method_exchangeImplementations(originalMethod_stop, swizzledMethod_stop)
            }

        }
    }

    // MARK: - Swizzled methods

    func test_startUpdatingLocation() {
        self.test_startUpdatingLocation()

        let stackString = Thread.callStackSymbols.joined(separator: "\n")
        print("Start updating happened")
        if stackString.contains("IssueReproduction") {
            print("- From test app")
            IssueReproduction.instance.fireNotification(title: "Start Updating",
                                                        body: "Test app")
        } else {
            print("- not from test app!")
            print(stackString)
            IssueReproduction.instance.fireNotification(title: "Start Updating",
                                                        body: "Google?")

            IssueReproduction.instance.log("- startUpdatingLocation\n\(stackString)")
        }
    }

    func test_stopUpdatingLocation() {
        self.test_stopUpdatingLocation()

        let stackString = Thread.callStackSymbols.joined(separator: "\n")
        print("Stop updating happened")
        if stackString.contains("IssueReproduction") {
            print("- From test app")
            IssueReproduction.instance.fireNotification(title: "Stop Updating",
                                                        body: "Test app")
        } else {
            print("- not from test app!")
            print(stackString)

            IssueReproduction.instance.fireNotification(title: "Stop Updating",
                                                        body: "Google?")
//            IssueReproduction.instance.log("- stopUpdatingLocation\n\(stackString)")
        }
    }
}
