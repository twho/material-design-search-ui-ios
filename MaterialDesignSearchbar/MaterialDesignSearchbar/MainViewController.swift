//
//  ViewController.swift
//  MaterialDesignSearchbar
//
//  Created by Ho, Tsungwei on 7/11/19.
//  Copyright © 2019 Ho, Tsungwei. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    private var searchbar: Searchbar!
    private var dim: CGSize = .zero

    override func viewDidLoad() {
        super.viewDidLoad()
        dim = self.view.frame.size
        initUI()
    }
    
    private func initUI() {
        self.view.backgroundColor = .white
        searchbar = Searchbar(
            onTapLeft: { [weak self] in
                guard let self = self else { return }
            
            },
            onTapRight: { [weak self] in
                guard let self = self else { return }
            
            },
            delegate: self
        )
        self.view.addSubview(searchbar)
        searchbar.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.addConstraints([
            NSLayoutConstraint(item: searchbar as Any, attribute: .top,
                               relatedBy: .equal,
                               toItem: self.view, attribute: .top,
                               multiplier: 1.0, constant: 0.1*self.dim.height),
            NSLayoutConstraint(item: searchbar as Any, attribute: .width,
                               relatedBy: .equal,
                               toItem: self.view, attribute: .width,
                               multiplier: 0.9, constant: 0.0),
            NSLayoutConstraint(item: searchbar as Any, attribute: .height,
                               relatedBy: .equal,
                               toItem: self.view, attribute: .height,
                               multiplier: 0.07, constant: 0.0),
            NSLayoutConstraint(item: searchbar as Any, attribute: .centerX,
                               relatedBy: .equal,
                               toItem: self.view, attribute: .centerX,
                               multiplier: 1.0, constant: 0.0)
            ])
        self.view.layoutIfNeeded()
    }
}

extension MainViewController: SearchbarDelegate {
    
    func searchbarTextDidChange(_ textField: UITextField) {
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func searchbarTextShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
