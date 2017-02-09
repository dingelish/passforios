//
//  BasicTableViewController.swift
//  pass
//
//  Created by Mingshen Sun on 9/2/2017.
//  Copyright © 2017 Bob Sun. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI


enum CellDataType {
    case link, segue, empty
}

enum CellDataKey {
    case type, title, link, footer, accessoryType, detailDisclosureAction, detailDisclosureData
}

class BasicStaticTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    var tableData = [[Dictionary<CellDataKey, Any>]]()
    var navigationItemTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navigationItemTitle
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let cellData = tableData[indexPath.section][indexPath.row]
        cell.textLabel?.text = cellData[CellDataKey.title] as? String
        if let accessoryType = cellData[CellDataKey.accessoryType] as? UITableViewCellAccessoryType {
            cell.accessoryType = accessoryType
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let cellData = tableData[indexPath.section][indexPath.row]
        let selector = cellData[CellDataKey.detailDisclosureAction] as? Selector
        perform(selector, with: cellData[CellDataKey.detailDisclosureData])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellData = tableData[indexPath.section][indexPath.row]
        let cellDataType = cellData[CellDataKey.type] as? CellDataType
        switch cellDataType! {
        case .segue:
            let link = cellData[CellDataKey.link] as? String
            performSegue(withIdentifier: link!, sender: self)
        case .link:
            let link = cellData[CellDataKey.link] as! String
            let url = URL(string: link)!
            switch url.scheme! {
            case "mailto":
                sendEmail(toRecipients: [URLComponents(string: link)?.path ?? ""])
            case "http", "https":
                let svc = SFSafariViewController(url: URL(string: link)!, entersReaderIfAvailable: false)
                    self.present(svc, animated: true, completion: nil)
            default:
                break
            }
        default:
            break
        }
    }
    
    func sendEmail(toRecipients recipients: [String]) {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients(recipients)
        mailVC.setSubject("Subject for email")
        mailVC.setMessageBody("Email message string", isHTML: false)
        self.present(mailVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
