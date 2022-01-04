//
//  ViewController.swift
//  calendartest
//
//  Created by 김인환 on 2022/01/05.
//

import UIKit
import FSCalendar

class ViewController: UIViewController {
    
    var calendar: FSCalendar!
    var monthLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setCalendar()
        setMonthLabel()
    }
    
    private func setCalendar() {
        calendar = FSCalendar(frame: CGRect(x: 0.0, y: 40.0, width: self.view.frame.size.width, height: 300.0))
        calendar.scrollDirection = .vertical
        calendar.scope = .month
        calendar.delegate = self
        self.view.addSubview(calendar)
    }
    
    private func setMonthLabel() {
        monthLabel = UILabel()
        
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(monthLabel)
        
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: calendar.bottomAnchor, constant: 30),
            monthLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }


}



extension ViewController: FSCalendarDelegate {
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let currentTimeData = calendar.currentPage.formatted()
        monthLabel.text = String(currentTimeData[0])
    }
}

extension String {
    subscript(_ index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }

}
