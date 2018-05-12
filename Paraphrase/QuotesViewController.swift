//
//  QuotesViewController.swift
//  Paraphrase
//
//  Created by Paul Hudson on 05/05/2018.
//  Copyright © 2018 Hacking with Swift. All rights reserved.
//

import GameplayKit
import SwiftyBeaver
import UIKit

class QuotesViewController: UITableViewController {
    // all the quotes to be shown in our table
    var model = QuotesModel()

    // whichever row was selected; used when adjusting the data source after editing
    var selectedRow: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Paraphrase"
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addQuote))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Random", style: .plain, target: self, action: #selector(showRandomQuote))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // format the quote neatly
        let quote = model.quote(at: indexPath.row).singleLine
        cell.textLabel?.text = quote

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show the quote fullscreen
        guard let showQuote = storyboard?.instantiateViewController(withIdentifier: "ShowQuoteViewController") as? ShowQuoteViewController else {
            SwiftyBeaver.error("Unable to load ShowQuoteViewController")
            fatalError("Unable to load ShowQuoteViewController")
        }

        let selectedQuote = model.quote(at: indexPath.row)
        showQuote.quote = selectedQuote

        navigationController?.pushViewController(showQuote, animated: true)
    }

    @objc func addQuote() {
        // add an empty quote and mark it as selected
        let quote = Quote(author: "", text: "")
        model.add(quote)
        selectedRow = model.count - 1

        // now trigger editing that quote
        guard let editQuote = storyboard?.instantiateViewController(withIdentifier: "EditQuoteViewController") as? EditQuoteViewController else {
            SwiftyBeaver.error("Unable to load EditQuoteViewController")
            fatalError("Unable to load EditQuoteViewController")
        }

        editQuote.quotesViewController = self
        editQuote.editingQuote = quote
        navigationController?.pushViewController(editQuote, animated: true)
    }

    @objc func showRandomQuote() {
        guard let selectedQuote = model.random() else { return }

        guard let showQuote = storyboard?.instantiateViewController(withIdentifier: "ShowQuoteViewController") as? ShowQuoteViewController else {
            SwiftyBeaver.error("Unable to load ShowQuoteViewController")
            fatalError("Unable to load ShowQuoteViewController")
        }

        showQuote.quote = selectedQuote

        navigationController?.pushViewController(showQuote, animated: true)
    }

    func finishedEditing(_ quote: Quote) {
        // make sure we have a selected row
        guard let selected = selectedRow else { return }

        model.replace(index: selected, with: quote)
        tableView.reloadData()
        selectedRow = nil
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] (_, indexPath) in
            SwiftyBeaver.info("Deleting quote at index \(indexPath.row)")
            self.model.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }

        let edit = UITableViewRowAction(style: .normal, title: "Edit") { [unowned self] (_, indexPath) in
            let quote = self.model.quote(at: indexPath.row)
            self.selectedRow = indexPath.row

            guard let editQuote = self.storyboard?.instantiateViewController(withIdentifier: "EditQuoteViewController") as? EditQuoteViewController else {
                SwiftyBeaver.error("Unable to load EditQuoteViewController")
                fatalError("Unable to load EditQuoteViewController")
            }

            editQuote.quotesViewController = self
            editQuote.editingQuote = quote
            self.navigationController?.pushViewController(editQuote, animated: true)
        }

        edit.backgroundColor = UIColor(red: 0, green: 0.4, blue: 0.6, alpha: 1)

        return [delete, edit]
    }
}
