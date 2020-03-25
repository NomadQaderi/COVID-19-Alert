//
//  DetailViewController.swift
//  Covid-19
//
//  Created by NOMAD on 3/19/20.
//  Copyright © 2020 NOMAD. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var lastupdateLabel: UILabel!
    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var country : String?
    var caseNumbers: String?
    var deathNumbers: String?
    var recoveredNumbers: String?
    var numberofAlives: Int?
    var countryImg: String?
    var lastupdate: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        //Navigation bar customizing:
        title = country
        navigationItem.largeTitleDisplayMode = .never

        countryName.text = country
        countryImage.image = UIImage(named: countryImg!)
        lastupdateLabel.text = lastupdate ?? "0"
        
        //Add a button to the navigation bar:
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButton))
        
    }
    

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailTableViewCell
        
        let caseNums = Int(caseNumbers!)!
        let deathNums = Int(deathNumbers!)!
        let recoversNums = Int(recoveredNumbers!) ?? 0
        
        
        cell.backgroundColor = .clear
        cell.CellBackgroundColor.layer.cornerRadius = 15
        
        if indexPath.row == 0 {
            
            //Singular and plular words:
            if caseNums > 1 {
                cell.detailLabel.text = "\(caseNums) Were Infected."

            } else {
                cell.detailLabel.text = "\(caseNums) Was Infected."
            }
            
            //Customize label and view:
            cell.detailLabel.textColor = .white
            cell.CellBackgroundColor.backgroundColor = UIColor(cgColor: #colorLiteral(red: 0.8392156863, green: 0.2039215686, blue: 0.2784313725, alpha: 1))
            
        } else if indexPath.row == 1 {
            
            //Singular and plular words:
            if deathNums > 1 {
                cell.detailLabel.text = "\(deathNums) Were Died."
            } else {
                cell.detailLabel.text = "\(deathNums) Was Died."
            }
            
            //Customize label and view:
            cell.detailLabel.textColor = .white
            cell.CellBackgroundColor.backgroundColor = UIColor(cgColor: #colorLiteral(red: 0.1529411765, green: 0.1529411765, blue: 0.1529411765, alpha: 1))
            
        } else if indexPath.row == 2 {
            
            //Singular and plular words:
            if recoversNums > 1 {
                cell.detailLabel.text = "\(recoversNums) Were Recovered."
            } else {
                cell.detailLabel.text = "\(recoversNums) Was Recovered."
            }

            //Customize label and view:
            cell.CellBackgroundColor.backgroundColor = UIColor(cgColor: #colorLiteral(red: 0.3137254902, green: 0.8470588235, blue: 0.5647058824, alpha: 1))
            
            
            
        } else {
            
            //Singular and plular words:
            if numberofAlives! > 1 {
                cell.detailLabel.text = "\(numberofAlives!) Active Cases."
            } else {
                cell.detailLabel.text = "\(numberofAlives!) Active Case."
            }
            
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        65
    }
    
    //Share button on navigation bar:
    @objc func shareButton() {
        
        let texts = "COVID-19 recorded cases in \(country ?? "Not Available"):\nTotal Cases: \(caseNumbers ?? "Not Available").\nDeaths: \(deathNumbers ?? "Not Available").\nRecovers: \(recoveredNumbers ?? "Not Available").\nActive Cases: \(numberofAlives ?? 0).\n\(lastupdate ?? "Not Available")."
        
        let ac = UIActivityViewController(activityItems: [texts], applicationActivities: [])
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(ac, animated: true)
        
    }
    
    
}
