//
//  ViewController.swift
//  Costs
//
//  Created by Valera on 2.06.21.
//  Copyright © 2021 Valera. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    let realm = try! Realm()
    var spendingArray: Results<Spending>!
    private var stillTyping = false
    private var categoryName = ""
    private var displayValue: Int = 0
    
    @IBOutlet var limitLabel: UILabel!
    @IBOutlet var howManyCanSpend: UILabel!
    @IBOutlet var spendByCheck: UILabel!
    @IBOutlet var numberFromKeyboard: [UIButton]! {
        didSet {
            for button in numberFromKeyboard {
                button.layer.cornerRadius = 11
            }
        }
    }
    @IBOutlet var tableView: UITableView!
    @IBOutlet var displayLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spendingArray = realm.objects(Spending.self)
        leftLabels()
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        guard let number = sender.currentTitle else { return }
        guard let displayText = displayLabel.text else { return }
        
        if stillTyping {
            if displayText.count < 15 {
                displayLabel.text = displayText + number
            }
        } else {
            if sender.currentTitle == "0" {
                return
            } else {
                displayLabel.text = number
                stillTyping = true
            }
        }
    }
    
    @IBAction func resetButtton(_ sender: UIButton) {
        displayLabel.text = "0"
        stillTyping = false
    }
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        categoryName = sender.currentTitle!
        displayValue = Int(displayLabel.text!) ?? 0 
        displayLabel.text = "0"
        stillTyping = false
        let value = Spending(value: ["\(categoryName)", displayValue])
        try! realm.write {
            realm.add(value)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
            self.tableView.endUpdates()
        }
        tableView.reloadData()
    }
    @IBAction func limitPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Установить лимит", message: "Введите сумму и количество дней" , preferredStyle: .alert)
        let actionAdd = UIAlertAction(title: "Установить", style: .default) { action in
            let tfSum = alert.textFields?[0].text
            self.limitLabel.text = tfSum
            
            let tfDay = alert.textFields?[1].text
            guard tfDay != "" else { return }
            if let day = tfDay {
                let dateNow = Date()
                let lastDay: Date = dateNow.addingTimeInterval(60*60*24*Double(day)!)
                
                let limit = self.realm.objects(Limit.self)
                if limit.isEmpty == true {
                    let value = Limit(value: [self.limitLabel.text!, dateNow, lastDay])
                    try! self.realm.write {
                        self.realm.add(value)
                    }
                } else {
                    try! self.realm.write {
                        limit[0].limitSum = self.limitLabel.text!
                        limit[0].limitDate = dateNow as NSDate
                        limit[0].limitLastDay = lastDay as NSDate 
                    }
                }
                
                
            }
        }
        alert.addTextField { money in
            money.placeholder = "Сумма"
            money.keyboardType = .asciiCapableNumberPad
        }
        
        alert.addTextField { day in
            day.placeholder = "Количество дней"
            day.keyboardType = .asciiCapableNumberPad
        }

        let actionCancel = UIAlertAction(title: "Отмена", style: .default) { _ in }
        
        alert.addAction(actionCancel)
        alert.addAction(actionAdd)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func leftLabels() {
        let limit = self.realm.objects(Limit.self)
        
        limitLabel.text = limit[0].limitSum
        
        let calendar = Calendar.current
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let firstDay = limit[0].limitDate as Date
        let lastDay = limit[0].limitLastDay as Date
        let firstComponents = calendar.dateComponents([.year, .month, .day], from: firstDay)
        let lastComponents = calendar.dateComponents([.year, .month, .day], from: lastDay)
        
        let startDate = formatter.date(from: "\(firstComponents.year!)/\(firstComponents.month!)/\(firstComponents.day!) 00:00")!
        let endDate = formatter.date(from: "\(lastComponents.year!)/\(lastComponents.month!)/\(lastComponents.day!) 23:59")
//
        let filtredLimit: Int = realm.objects(Spending.self).filter("self.data >= %@ && self.data <= %@", startDate, endDate!).sum(ofProperty: "cost")
        
        spendByCheck.text = "\(filtredLimit)"
        
        let a = Int(limitLabel.text!)!
        let b = Int(spendByCheck.text!)!
        let c = a - b
        
        howManyCanSpend.text = "\(c)"
    }
    
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spendingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let spending =  spendingArray[indexPath.row]
        cell.recordCategory.text = spending.category
        cell.recordCost.text = String(spending.cost)
        switch spending.category {
        case "Еда": cell.recordImage.image = #imageLiteral(resourceName: "Category_Еда")
        case "Одежда": cell.recordImage.image = #imageLiteral(resourceName: "Category_Одежда")
        case "Связь": cell.recordImage.image = #imageLiteral(resourceName: "Category_Связь")
        case "Досуг": cell.recordImage.image = #imageLiteral(resourceName: "Category_Досуг")
        case "Красота": cell.recordImage.image = #imageLiteral(resourceName: "Category_Красота")
        case "Авто": cell.recordImage.image = #imageLiteral(resourceName: "Category_Авто")
        default:
            cell.recordImage.image = UIImage(named: "folder")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let configurationDelete = UISwipeActionsConfiguration(actions: [UIContextualAction(style: .destructive, title: "Delete", handler: { [weak self] (action, view, completionHandler) in
            guard let editingRow = self?.spendingArray[indexPath.row] else { return }
            try! self?.realm.write {
                self?.realm.delete(editingRow)
                tableView.reloadData()
            }
            completionHandler(true)
        })])
        return configurationDelete
    }
    
}

