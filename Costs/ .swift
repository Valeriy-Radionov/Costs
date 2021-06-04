//
//  ViewController.swift
//  Costs
//
//  Created by Valera on 2.06.21.
//  Copyright © 2021 Valera. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var numberFromKeyboard: [UIButton]! {
        didSet {
            for button in numberFromKeyboard {
                button.layer.cornerRadius = 11
            }
        }
    }
    @IBOutlet var tableView: UITableView!
    @IBOutlet var displayLabel: UILabel!
    
    var stillTyping = false
    var categoryName = ""
    var displayValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        displayValue = displayLabel.text!
        displayLabel.text = "0"
        stillTyping = false
        print("\(categoryName), \(displayValue)")
         
    }
}

// MARK: TableViewDataSourse
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
         
        return cell
    }
    
    
}

// MARK: TableViewDelegate
extension ViewController: UITableViewDelegate {
    
}
