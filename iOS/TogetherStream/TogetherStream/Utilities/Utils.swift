//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import UIKit
import Google

class Utils: NSObject {

    /**
     Method gets a key from a plist, both specified in parameters

     - parameter plist: String
     - parameter key:   String

     - returns: String
     */
    class func getStringValueWithKeyFromPlist(_ plist: String, key: String) -> String? {
        if let path: String = Bundle.main.path(forResource: plist, ofType: "plist"),
            let keyList = NSDictionary(contentsOfFile: path),
            let key = keyList.object(forKey: key) as? String {
            return key
        }
        return nil
    }
    
    /**
     Method gets a key from a plist, both specified in parameters
     
     - parameter plist: String
     - parameter key:   String
     
     - returns: Int
     */
    class func getIntValueWithKeyFromPlist(_ plist: String, key: String) -> Int? {
        if let path: String = Bundle.main.path(forResource: plist, ofType: "plist"),
            let keyList = NSDictionary(contentsOfFile: path),
            let key = keyList.object(forKey: key) as? Int {
            return key
        }
        return nil
    }

    /**
    Method returns an instance of the storyboard defined by the storyboardName String parameter

    - parameter storyboardName: UString

    - returns: UIStoryboard
    */
    class func storyboardBoardWithName(_ storyboardName: String) -> UIStoryboard {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        return storyboard
    }

    /**
    Method returns an instance of the view controller defined by the vcName paramter from the storyboard defined by the storyboardName parameter

    - parameter identifier:     String
    - parameter storyboardName: String

    - returns: UIViewController?
    */
    class func instantiateViewController(withIdentifier identifier: String, fromStoryboardNamed storyboardName: String) -> UIViewController? {
        let storyboard = storyboardBoardWithName(storyboardName)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }

    /// Creates and sends a Google Analytics event with the given parameters.
    ///
    /// - Parameters:
    ///   - category: The event category.
    ///   - action: The event action.
    ///   - label: The event label.
    ///   - value: The event value.
    class func sendGoogleAnalyticsEvent(withCategory category: String, action: String? = nil, label: String? = nil, value: NSNumber? = nil) {
        #if !DEBUG
        guard
            let event = GAIDictionaryBuilder.createEvent(
                withCategory: category,
                action: action,
                label: label,
                value: value)
                .build() as NSDictionary as? [AnyHashable: Any] else { return}
        GAI.sharedInstance().defaultTracker.send(event)
        #endif
    }
    
    /// Logs out of all systems in the app.
    ///
    /// - Parameter callback: Closure called on completion. Nil error means
    /// it was successful.
    class func logout(callback: ((Error?) -> Void)? = nil) {
        FacebookDataManager.sharedInstance.logOut()
        // Delete server cookie
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                if AccountDataManager.sharedInstance.serverAddress.contains(cookie.domain) {
                    HTTPCookieStorage.shared.deleteCookie(cookie)
                    break
                }
            }
        }
        // Unauthenticates from CSync
        CSyncDataManager.sharedInstance.unauthenticate {error in
            callback?(error)
        }
    }
}
