//
//  Alert.swift
//  BRGamebookEngine
//
//  Created by Bradley Root on 9/18/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func createCancelableAlert(
        title: String?,
        message: String?,
        primaryActionTitle: String?,
        handler: ((UIAlertAction) -> Void)? = nil
    ) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let primaryAction = UIAlertAction(title: primaryActionTitle ?? "OK", style: .default, handler: handler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(primaryAction)
        alert.addAction(cancelAction)

        return alert
    }
}
