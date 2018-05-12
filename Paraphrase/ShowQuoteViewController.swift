//
//  ShowQuoteViewController.swift
//  Paraphrase
//
//  Created by Paul Hudson on 05/05/2018.
//  Copyright © 2018 Hacking with Swift. All rights reserved.
//

import SwiftyBeaver
import UIKit

class ShowQuoteViewController: UIViewController {
    @IBOutlet var quoteLabel: UILabel!

    var quote: Quote?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let quote = quote else {
            navigationController?.popToRootViewController(animated: true)
            return
        }

        title = quote.author
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareQuote))

        // format the text and author of this quote
        quoteLabel.attributedText = quote.attributedString
    }

    @objc func shareQuote() {
        guard let quote = quote else {
            return
        }

        // format the quote neatly and share it
        let fullText = quote.multiLine
        let activity = UIActivityViewController(activityItems: [fullText], applicationActivities: nil)
        present(activity, animated: true)

        SwiftyBeaver.info("Sharing quote \(fullText)")
    }
}
