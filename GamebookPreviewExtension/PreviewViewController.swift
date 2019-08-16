//
//  PreviewViewController.swift
//  GamebookPreviewExtension
//
//  Created by Brad Root on 9/14/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import QuickLook
import UIKit

class PreviewViewController: UIViewController, QLPreviewingController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var synopsisLabel: UILabel!
    @IBOutlet var totalPagesLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        _ = url.startAccessingSecurityScopedResource()
        guard let jsonData = try? Data(contentsOf: url) else { handler(nil)
            return
        }
        _ = url.stopAccessingSecurityScopedResource()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        if let gameStruct = try? decoder.decode(GameStruct.self, from: jsonData) {
            titleLabel.text = gameStruct.name
            authorLabel.text = gameStruct.author ?? "Anonymous"
            synopsisLabel.text = gameStruct.about
            totalPagesLabel.text = "\(gameStruct.pages.count)"
        }

        handler(nil)
    }
}
