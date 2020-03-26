//
//  ViewController.swift
//  Covid-19
//
//  Created by NOMAD on 3/15/20.
//  Copyright © 2020 NOMAD. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var updateLabel: UILabel!
    
    var details = [Country]()
    var searchFilter = [Country]()
    var date : String?
    
    
    var isSearching = false
    
    //Sorting proccess:
    enum Sort {
        case mostCase
        case leastCase
        case mostDeath
        case leastDeath
        case mostRecover
        case leastRecover
        case name
    }
    

    var sorting = Sort.mostCase
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isHidden = true
        
        fetchData()
        
        //Navigation bar buttons:
        let refreshBtn = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButton))
        let sortBtn = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down.circle"), landscapeImagePhone: UIImage(systemName: "arrow.up.arrow.down.circle"), style: .plain, target: self, action: #selector(sortButton))
        let aboutBtn = UIBarButtonItem(image: UIImage(systemName: "info.circle"), landscapeImagePhone: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(infoButton))
                
        navigationItem.rightBarButtonItems = [refreshBtn, sortBtn]
        navigationItem.leftBarButtonItems = [aboutBtn]
        
        
        
        //Navigation bar customizing:
        title = "COVID-19 Alert"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        //Add search bar to navigation bar:
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.clearButtonMode = .whileEditing
        navigationItem.searchController = searchController
    
    }
    
    //This function load Coronavirus data and and parse the JSON data
    func fetchData() {
        
        guard let url = URL(string:"https://interactive-static.scmp.com/sheet/wuhan/viruscases.json") else {return }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let data = data {
                
                if let response = try? JSONDecoder().decode(Sheet.self, from: data) {
                    DispatchQueue.main.async {
                        self.details = response.entries
                        self.searchFilter = response.entries
                                            
                        self.date = response.last_updated
                        
                        self.isSearching = false
                        
                        self.tableView.reloadData()
                        self.tableView.isHidden = false

                    }
                }
            
                self.details = []
                
            } else {
                DispatchQueue.main.async {
                    let ac = UIAlertController(title: "Error while loading data", message: "We couldn't get the data due to internet connection interrupt. Please check your connection and tab the Refresh button.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Refresh", style: .default, handler: { (action) in
                        self.fetchData()
                        
                    }))
                    self.present(ac, animated: true)
                }
            }
            
        }.resume()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //This is the first cell on the table view (apologize for identifier name):
        guard let cell1 = tableView.dequeueReusableCell(withIdentifier: "SecondCell") as? SecondTableViewCell else {fatalError("second cell error")}
        
        //This is the second cell on the table view (apologize for identifier name):
        guard let cell2 = tableView.dequeueReusableCell(withIdentifier: "Cell") as? HomeTableViewCell else {fatalError("first cell error")}
        
        //Put the search results in the second cell:
        if isSearching {
            
            cell2.countryLabel.text = searchFilter[indexPath.row].details.country
            cell2.caseNums.text = searchFilter[indexPath.row].cases
            cell2.deathNums.text = searchFilter[indexPath.row].deaths
            cell2.recoveryNums.text = searchFilter[indexPath.row].recovered
            cell2.countryImage.image = UIImage(named: searchFilter[indexPath.row].country)
            
            cell1.isHidden = true
            
        } else {
            if indexPath.section == 0 {
                let totalCases = details.map({$0.details.cases}).reduce(0, +)
                let totalDeaths = details.map({$0.details.deaths}).reduce(0, +)
                let totalRecovered = details.map({$0.details.recovered}).reduce(0, +)
                
                cell1.countryLabel.text = "WorldWide"
                cell1.caseNums.text = "\(totalCases)"
                cell1.deathNums.text = "\(totalDeaths)"
                cell1.recoveryNums.text = "\(totalRecovered)"
                cell1.countryImage.image = UIImage(named: "Overall")

                //Labels background customize:
                cell1.caseBC.layer.cornerRadius = 7
                cell1.deathBC.layer.cornerRadius = 7
                cell1.recoveryBC.layer.cornerRadius = 7
                
                return cell1
                
            } else {
                
                cell2.countryLabel.text = details[indexPath.row].details.country 
                cell2.caseNums.text = details[indexPath.row].cases
                cell2.deathNums.text = details[indexPath.row].deaths
                cell2.recoveryNums.text = details[indexPath.row].recovered.replacingOccurrences(of: ",", with: "")
                
                tableView.rowHeight = UITableView.automaticDimension
                tableView.estimatedRowHeight = UITableView.automaticDimension
            }
            
            //Singular and plular words:
            if details[indexPath.row].cases == "0" || details[indexPath.row].cases == "1" {
                cell2.caseLabel.text = "Case"
            } else {
                cell2.caseLabel.text = "Cases"
            }
            
            if details[indexPath.row].deaths == "0" || details[indexPath.row].deaths == "1" {
                cell2.deathLabel.text = "Death"
            } else {
                cell2.deathLabel.text = "Deaths"
            }
            
            if details[indexPath.row].recovered == "0" || details[indexPath.row].recovered == "1" {
                cell2.recoverLabel.text = "Recovered"
            } else {
                cell2.recoverLabel.text = "Recovered"
            }
            

            //Labels background customize:
            cell2.caseBC.layer.cornerRadius = 7
            cell2.deathBC.layer.cornerRadius = 7
            cell2.recoveryBC.layer.cornerRadius = 7
            
            //Put the country flag currectly:
            let imageName = cell2.countryLabel.text
            cell2.countryImage.image = UIImage(named: imageName!)
            
            return cell2
        }

        return cell2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if isSearching {
            return searchFilter.count
        } else {
            if section == 0 {
                return 1
            } else {
                
                switch sorting {
                case .name:
                    details.sort {$0.details.cases > $1.details.cases}
                case .leastCase:
                    details.sort {$0.details.cases < $1.details.cases}
                case .mostDeath:
                    details.sort {$0.details.deaths > $1.details.deaths}
                case .leastDeath:
                    details.sort {$0.details.deaths < $1.details.deaths}
                case .mostRecover:
                    details.sort {$0.details.recovered > $1.details.recovered}
                case .leastRecover:
                    details.sort {$0.details.recovered < $1.details.recovered}
                default:
                    details.sort()
                }
                
                return details.count
            }
        }
            
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching {
            return 1
        } else {
            return 2
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? SecondViewController {
            
            //In case of not searching for anything:
            let detail = details[indexPath.row]
            let caseNumber = Int(details[indexPath.row].cases)
            let deathNumber = Int(details[indexPath.row].deaths)
            
            //In case of searching for something:
            let detailFilter = searchFilter[indexPath.row]
            let caseNumberFilter = Int(searchFilter[indexPath.row].cases)
            let deathNumberFilter = Int(searchFilter[indexPath.row].deaths)
            
            if isSearching {
                
                vc.countryImg = detailFilter.details.country
                vc.country = detailFilter.details.country
                vc.caseNumbers = detailFilter.cases
                vc.deathNumbers = detailFilter.deaths
                vc.recoveredNumbers = detailFilter.recovered
                vc.numberofAlives = caseNumberFilter! - deathNumberFilter!
                
                 vc.lastupdate = "Last Update: \(date?.replacingMultipleOccurrences(using: (of: "T", with: " "), (of: "Z", with: " UTC +0")) ?? "Last Update: Not available.")"
                
            } else {
                if indexPath.section == 0 {
                    
                    let totalCases = details.map({$0.details.cases}).reduce(0, +)
                    let totalDeaths = details.map({$0.details.deaths}).reduce(0, +)
                    let totalRecovered = details.map({$0.details.recovered}).reduce(0, +)
                    
                    vc.countryImg = "Overall"
                    vc.country = "WorldWide"
                    vc.caseNumbers = "\(totalCases)"
                    vc.deathNumbers = "\(totalDeaths)"
                    vc.recoveredNumbers = "\(totalRecovered)"
                    vc.numberofAlives = totalCases - totalDeaths
                    
                    vc.lastupdate = "Last Update: \(date?.replacingMultipleOccurrences(using: (of: "T", with: " "), (of: "Z", with: " UTC +0")) ?? "Last Update: Not available.")"
                    
                } else {
                    vc.countryImg = detail.details.country
                    vc.country = detail.details.country
                    vc.caseNumbers = detail.cases
                    vc.deathNumbers = detail.deaths
                    vc.recoveredNumbers = detail.recovered.replacingOccurrences(of: ",", with: "")
//                  guard vc.numberofAlives == caseNumber! - deathNumber! else {return }
//                  vc.numberofAlives = caseNumber! - deathNumber!
                    vc.numberofAlives = caseNumber! - deathNumber!
                    
                    vc.lastupdate = "Last Update: \(date?.replacingMultipleOccurrences(using: (of: "T", with: " "), (of: "Z", with: " UTC +0")) ?? "Last Update: Not available.")"
                    
                }
            }
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //Put the Last Update detail on the second section:
        if section == 1 {
            return "Last Update: \(date?.replacingMultipleOccurrences(using: (of: "T", with: " "), (of: "Z", with: " UTC +0")) ?? "Last Update: Not available.")"
        }
        
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableView.automaticDimension
    }
    
    //About button on navigation:
    @objc func infoButton() {
    
        let ac = UIAlertController(title: "About", message: "Stay Up-To-Date on Coronavirus (COVID-19) information with this free App. This App is updated with daily data from https://interactive-static.scmp.com\n Designed and Developed by Nomad.", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "View Github Repo", style: .default, handler: { (action) in
            if let url = URL(string: "https://github.com/NomadQaderi") {
              if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
              } else {
                UIApplication.shared.openURL(url)
              }
            }
        }))
        
        ac.addAction(UIAlertAction(title: "Contact the Developer", style: .default, handler: { (action) in
             let appURL = URL(string: "twitter://user?screen_name=813078582")!
                   let webURL = URL(string: "https://twitter.com/NomadQaderi")!
                   
                  if UIApplication.shared.canOpenURL(appURL as URL) {
                       if #available(iOS 10.0, *) {
                           UIApplication.shared.open(appURL)
                       } else {
                           UIApplication.shared.openURL(appURL)
                       }
                   } else {
                       //redirect to safari because the user doesn't have Instagram
                       if #available(iOS 10.0, *) {
                           UIApplication.shared.open(webURL)
                       } else {
                           UIApplication.shared.openURL(webURL)
                       }
                   }
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    //Refresh button on navigation:
    @objc func refreshButton() {
        fetchData()
        
        alertFunction()
     
    }
    
    //Sort button on navigation:
    @objc func sortButton() {
        
        
        let ac = UIAlertController(title: "Sort", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Sort by Most Case Records", style: .default, handler: { (action) in
            self.sorting = Sort.mostCase
            self.tableView.reloadData()
        }))
        ac.addAction(UIAlertAction(title: "Sort by Least Case Records", style: .default, handler: { (action) in
            self.sorting = Sort.leastCase
            self.tableView.reloadData()
        }))
        ac.addAction(UIAlertAction(title: "Sort by Name", style: .default, handler: { (action) in
            self.sorting = Sort.name
            self.tableView.reloadData()
        }))
        ac.addAction(UIAlertAction(title: "Sort by Most Death Records", style: .default, handler: { (action) in
            self.sorting = Sort.mostDeath
            self.tableView.reloadData()
        }))
        ac.addAction(UIAlertAction(title: "Sort by Least Death Records", style: .default, handler: { (action) in
            self.sorting = Sort.leastDeath
            self.tableView.reloadData()
        }))
        ac.addAction(UIAlertAction(title: "Sort by Most Recover Records", style: .default, handler: { (action) in
            self.sorting = Sort.mostRecover
            self.tableView.reloadData()
        }))
        ac.addAction(UIAlertAction(title: "Sort by Least Recover Records", style: .default, handler: { (action) in
            self.sorting = Sort.leastRecover
            self.tableView.reloadData()
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty && searchText != " " && searchText != "  " else {searchFilter = details; return}
        
        searchFilter = details.filter ({ user -> Bool in
            return user.country.contains(searchText)
        })
        
        isSearching = true
        tableView.reloadData()
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isSearching = false
        searchFilter = details
        tableView.reloadData()
    }

    
    
//    This function let the user know that the data has been updated.
    
           func alertFunction() {
              let alert = UIAlertController(title: "Coronavirus", message: "App updated with new data", preferredStyle: .alert)
              let subAlert = UIAlertAction(title: "OK", style: .default, handler: nil)
              alert.addAction(subAlert)
              self.present(alert, animated: true, completion: nil)
              
              
          }
    
}
