//
//  ViewController.swift
//  MaterialDesignSearchbar
//
//  Created by Ho, Tsungwei on 7/11/19.
//  Copyright © 2019 Ho, Tsungwei. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController {
    // MARK: - UI widgets
    private var searchbar: Searchbar!
    private var maskView: UIView!
    private var searchResultsView: SearchResultsView!
    // MARK: - Private properties
    private var dim: CGSize = .zero
    private let animHplr = AnimHelper.shared
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        dim = self.view.frame.size
        initUI()
        requestPermission()
    }
    /**
     Init UI.
     */
    private func initUI() {
        self.view.backgroundColor = ResManager.Colors.sand
        maskView = UIView()
        maskView.backgroundColor = .white
        searchbar = Searchbar(
            onStartSearch: { [weak self] (isSearching) in
                guard let self = self else { return }
                self.showSearchResultsView(isSearching)
            },
            onClearInput: { [weak self] in
                guard let self = self else { return }
                self.searchResultsView.state = .populated([])
            },
            delegate: self
        )
        searchResultsView = SearchResultsView()
        showSearchResultsView(false)
        self.view.addSubViews([maskView, searchResultsView, searchbar])
    }
    
    private func requestPermission() {
        appDelegate.locationMgr.desiredAccuracy = kCLLocationAccuracyBest
        appDelegate.locationMgr.requestAlwaysAuthorization()
    }
    
    private func showSearchResultsView(_ show: Bool) {
        if show {
            guard maskView.alpha == 0.0 else { return }
            animHplr.moveUpViews([maskView, searchResultsView], show: true)
        } else {
            animHplr.moveDownViews([maskView, searchResultsView], show: false)
        }
    }
    // viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        maskView.setConstraintsToView(top: self.view, bottom: self.view, left: self.view, right: self.view)
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
                               multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: searchResultsView as Any, attribute: .centerX,
                               relatedBy: .equal,
                               toItem: searchbar, attribute: .centerX,
                               multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: searchResultsView as Any, attribute: .bottom,
                               relatedBy: .equal,
                               toItem: maskView, attribute: .bottom,
                               multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: searchResultsView as Any, attribute: .top,
                               relatedBy: .equal,
                               toItem: searchbar, attribute: .bottom,
                               multiplier: 1.0, constant: 0.02*dim.height)
            ])
        searchResultsView.setConstraintsToView(left: searchbar, right: searchbar)
        self.view.layoutIfNeeded()
    }
}

extension MainViewController: SearchbarDelegate {
    
    func searchbarTextDidChange(_ textField: UITextField) {
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showSearchResultsView(true)
        lookUpCurrentLocation { (placemark) in
            guard let placemark = placemark else { return }
            DispatchQueue.main.async {
                self.searchResultsView.update(newPlacemarks: [placemark], error: nil)
            }
        }
    }
    /**
     For testing searchResultsView purpose. Will remove in final application.
     */
    private func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void ) {
        if let lastLocation = appDelegate.locationMgr.location {
            DispatchQueue.global(qos: .userInteractive).async {
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(
                    lastLocation,
                    completionHandler: { (placemarks, error) in
                        if error == nil {
                            let location = placemarks?[0]
                            completionHandler(location)
                        } else {
                            completionHandler(nil)
                        }
                })
            }
        } else {
            completionHandler(nil)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func searchbarTextShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
