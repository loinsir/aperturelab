//
//  ViewController.swift
//  cheap
//
//  Created by 김인환 on 2022/01/14.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
//        searchBar.searchTextField
        let searchToken = UISearchToken(icon: UIImage(), text: "HI")
        searchToken.representedObject = "hello?"
        searchBar.searchTextField.tokens = [searchToken]
//        searchBar.searchTextField.allowsDeletingTokens = false
    }
    
    

}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchBar.searchTextField.tokens)
//        searchBar.searchTextField.tokens.remove
    }
}

