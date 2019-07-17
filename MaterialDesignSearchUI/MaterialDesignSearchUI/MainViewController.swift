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
    private var mapView: MKMapView!
    private var btnLocate: MaterialButton!
    // MARK: - Private properties
    private var dim: CGSize = .zero
    private let animHplr = AnimHelper.shared
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        dim = self.view.frame.size
        initUI()
        requestPermission()
        btnLocate.addTarget(self, action: #selector(tapLocate), for: .touchUpInside)
    }
    /**
     Init UI.
     */
    private func initUI() {
        self.view.backgroundColor = ResManager.Colors.sand
        maskView = UIView()
        maskView.backgroundColor = .white
        // Configure searchbar
        searchbar = Searchbar(
            onStartSearch: { [weak self] (isSearching) in
                guard let self = self else { return }
                self.showSearchResultsView(isSearching)
            },
            onClearInput: { [weak self] in
                guard let self = self else { return }
                self.searchResultsView.state = .populated([])
                self.mapView.removeAnnotations(self.mapView.annotations)
            },
            delegate: self
        )
        // Configure searchResultsView
        searchResultsView = SearchResultsView(didSelectAction: { [weak self] (placemark) in
            guard let self = self else { return }
            self.didSelectPlacemark(placemark)
        })
        showSearchResultsView(false)
        // Set up mapView
        mapView = MKMapView()
        mapView.delegate = self
        btnLocate = MaterialButton(
            icon: #imageLiteral(resourceName: "ic_locate").colored(.darkGray),
            bgColor: .white,
            cornerRadius: 0.15*dim.width/2,
            withShadow: true
        )
        self.view.addSubViews([mapView, btnLocate, maskView, searchResultsView, searchbar])
    }
    
    private func requestPermission() {
        appDelegate.locationMgr.desiredAccuracy = kCLLocationAccuracyBest
        appDelegate.locationMgr.requestAlwaysAuthorization()
    }
    
    @objc private func tapLocate() {
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    private func didSelectPlacemark(_ placemark: CLPlacemark) {
        guard let loc = placemark.location else { return }
        // Set search bar
        self.searchbar.textInput.text = placemark.name
        self.searchbar.textFieldDidEndEditing(self.searchbar.textInput)
        // Dismiss search results view
        self.showSearchResultsView(false)
        // Add annotation
        let annotation = MKPointAnnotation()
        annotation.title = placemark.name
        annotation.coordinate = loc.coordinate
        self.mapView.showAnnotations([annotation], animated: true)
    }
    
    private func showSearchResultsView(_ show: Bool) {
        if show {
            guard maskView.alpha == 0.0 else { return }
            animHplr.moveUpViews([maskView, searchResultsView], show: true)
        } else {
            animHplr.moveDownViews([maskView, searchResultsView], show: false)
            searchResultsView.isScrolling = false
        }
    }
    // viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        maskView.setConstraintsToView(top: self.view, bottom: self.view, left: self.view, right: self.view)
        mapView.setConstraintsToView(top: self.view, bottom: self.view, left: self.view, right: self.view)
        btnLocate.setConstraintsToView(bottom: self.view, bConst: -0.05*dim.height, right: searchbar)
        self.view.addConstraints([
            NSLayoutConstraint(item: searchbar as Any, attribute: .top,
                               relatedBy: .equal,
                               toItem: self.view, attribute: .top,
                               multiplier: 1.0, constant: 0.1*self.dim.height),
            NSLayoutConstraint(item: searchbar as Any, attribute: .centerX,
                               relatedBy: .equal,
                               toItem: self.view, attribute: .centerX,
                               multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: searchResultsView as Any, attribute: .centerX,
                               relatedBy: .equal,
                               toItem: searchbar, attribute: .centerX,
                               multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: searchResultsView as Any, attribute: .top,
                               relatedBy: .equal,
                               toItem: searchbar, attribute: .bottom,
                               multiplier: 1.0, constant: 0.02*dim.height)
            ])
        searchResultsView.setConstraintsToView(bottom: maskView, left: searchbar, right: searchbar)
        searchbar.setHeightConstraint(0.07*dim.height)
        searchbar.setWidthConstraint(0.9*dim.width)
        // Set the corner radius to be half of the button height to make it circular.
        btnLocate.setHeightConstraint(0.15*dim.width)
        btnLocate.setWidthConstraint(0.15*dim.width)
        self.view.layoutIfNeeded()
    }
    // viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        (mapView.isZoomEnabled, mapView.showsUserLocation) = (true, true)
        mapView.setUserTrackingMode(.follow, animated: true)
    }
}
// MARK: - SearchbarDelegate
extension MainViewController: SearchbarDelegate {
    
    func searchbarTextDidChange(_ textField: UITextField) {
        guard let keyword = isTextInputValid(textField) else { return }
        searchResultsView.state = .loading
        searchLocations(keyword)
    }
    
    private func isTextInputValid(_ textField: UITextField) -> String? {
        if let keyword = textField.text, !keyword.isEmpty { return keyword }
        return nil
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showSearchResultsView(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard !searchResultsView.isScrolling else { return }
        showSearchResultsView(false)
        searchbar.setBtnStates(hasInput: textField.text?.count != 0, isSearching: false)
    }
    
    func searchbarTextShouldReturn(_ textField: UITextField) -> Bool {
        guard let keyword = isTextInputValid(textField) else { return false }
        searchLocations(keyword, completion: { [weak self] (placemarks, error) in
            guard let self = self, let first = placemarks.first else { return }
            self.didSelectPlacemark(first)
        })
        return true
    }
    /**
     Search locations by keyword entered in search bar.
     
     - Parameter keyword:    The keyword as the input to search locations.
     - Parameter completion: The completion handler after showing search results.
     */
    private func searchLocations(_ keyword: String, completion: (([CLPlacemark], Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = keyword
            request.region = self.mapView.region
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                var placemarks = [CLPlacemark]()
                if let response = response {
                    for item in response.mapItems {
                        placemarks.append(item.placemark)
                    }
                }
                DispatchQueue.main.async {
                    self.searchResultsView.update(newPlacemarks: placemarks, error: error)
                    completion?(placemarks, error)
                }
            }
        }
    }
}
// MARK: - MKMapViewDelegate
extension MainViewController: MKMapViewDelegate {
    // viewForAnnotation
    // Refer to https://hackingwithswift.com
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }
}
