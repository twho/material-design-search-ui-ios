//
//  SearchResultsView.swift
//  MaterialDesignSearchbar
//
//  Created by Ho, Tsung Wei on 7/12/19.
//  Copyright © 2019 Ho, Tsungwei. All rights reserved.
//

import UIKit
import CoreLocation

/**
 The state of the tableView used in SearchResultsView.
 */
enum State {
    /// When the table is loading.
    case loading
    /// When the loading is done, show data.
    /// - placemarks shown in the tableView.
    case populated([CLPlacemark])
    /// When there's no results to show.
    case empty
    /// When the table is loading.
    /// - The error object with error messages.
    case error(Error)
    /**
     The stored placemark data.
     */
    var placemarks: [CLPlacemark] {
        switch self {
        case .populated(let placemarks):
            return placemarks
        default:
            return []
        }
    }
}

class SearchResultsView: UIView {
    // MARK: - UI widgets
    private var tableView: UITableView!
    private var activityIndicator: MaterialLoadingIndicator!
    private var loadingView: UIView!
    private var emptyView: UIView!
    private var noResultLabel: UILabel!
    private var errorView: UIView!
    private var errorLabel: UILabel!
    // MARK: - Private properties
    private var cellId = "ResultCell"
    private var didSelectAction: DidSelectLocation?
    // MARK: - Public properties
    public var rowHeight: CGFloat = 60.0
    public var isScrolling = false
    /**
     The current state of the tableView. Reload the tableView every time the state is changed.
     */
    var state = State.loading {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.setFooterView()
                // Reload table with animations
                let range = NSMakeRange(0, self.tableView.numberOfSections)
                let sections = NSIndexSet(indexesIn: range)
                self.tableView.reloadSections(sections as IndexSet, with: .automatic)
            }
        }
    }
    // Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    /**
     Convenience initializer for app use.
     
     - Parameter didSelectAction: Handle when user select an item in the search results view.
     */
    convenience init(didSelectAction: DidSelectLocation) {
        self.init()
        self.didSelectAction = didSelectAction
    }
    /**
     Init UI.
     */
    private func initUI() {
        self.setCornerBorder()
        prepareTableView()
        // Set up loading view
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.rowHeight))
        activityIndicator = MaterialLoadingIndicator()
        loadingView.addSubViews([activityIndicator])
        // Set up empty view
        emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.rowHeight))
        noResultLabel = UILabel(title: "No results! Try searching for something else.", size: 17.0, color: .gray, lines: 3, aligment: .center)
        emptyView.addSubViews([noResultLabel])
        // Set up error view
        errorView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.rowHeight))
        errorLabel = UILabel(title: "There is an error.", size: 17.0, color: .gray, lines: 3, aligment: .center)
        errorView.addSubViews([errorLabel])
    }
    // layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        loadingView.centerSubView(activityIndicator)
        errorLabel.leftAnchor.constraint(equalTo: errorView.leftAnchor).isActive = true
        errorLabel.rightAnchor.constraint(equalTo: errorView.rightAnchor).isActive = true
        errorView.centerSubView(errorLabel)
        noResultLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor).isActive = true
        noResultLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor).isActive = true
        emptyView.centerSubView(noResultLabel)
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    /**
     Set up tableView and add to parent view.
     */
    private func prepareTableView() {
        tableView = UITableView()
        (tableView.delegate, tableView.dataSource, tableView.separatorStyle, tableView.keyboardDismissMode) = (self, self, .none, .onDrag)
        tableView.register(ResultCell.self, forCellReuseIdentifier: cellId)
        tableView.isUserInteractionEnabled = true
        tableView.canCancelContentTouches = false
        self.addSubViews([tableView])
    }
    /**
     Update current data source.
     
     - Parameter newPlacemarks: New data source.
     - Parameter error:         Error occurred while fetching data.
     */
    func update(newPlacemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            state = .error(error)
            return
        }
        guard let newPlacemarks = newPlacemarks, !newPlacemarks.isEmpty else {
            state = .empty
            return
        }
        state = .populated(newPlacemarks)
    }
    /**
     Change footer view based on current state.
     */
    func setFooterView() {
        switch state {
        case .error(let error):
            errorLabel.text = error.localizedDescription
            tableView.tableFooterView = errorView
        case .loading:
            activityIndicator.startAnimating()
            tableView.tableFooterView = loadingView
        case .empty:
            tableView.tableFooterView = emptyView
        case .populated:
            tableView.tableFooterView = nil
        }
    }
    // Required init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
// MARK: - UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate
extension SearchResultsView: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(state.placemarks.count, 10)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? ResultCell else {
            return UITableViewCell()
        }
        cell.configure(state.placemarks[indexPath.row])
        return cell
    }
    // didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let onSelect = self.didSelectAction, indexPath.row < state.placemarks.count {
            onSelect!(state.placemarks[indexPath.row])
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
    }
}

class ResultCell: MaterialTableViewCell {
    // MARK: - UI widgets
    private var icon: UIImageView!
    private var caption: UILabel!
    private var title: UILabel!
    private var subTitle: UILabel!
    private var rightStack: UIStackView!
    private var leftStack: UIStackView!
    // Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setCornerBorder()
        icon = UIImageView(image: #imageLiteral(resourceName: "ic_location").colored(.gray))
        title = UILabel(title: "", size: 16.0, color: .gray, lines: 1, aligment: .left)
        subTitle = UILabel(title: "", size: 14.0, color: .gray, lines: 1, aligment: .left)
        caption = UILabel(title: "", size: 12.0, color: .gray, lines: 1, aligment: .left)
        caption.adjustsFontSizeToFitWidth = true
        rightStack = UIStackView(arrangedSubviews: [title, subTitle], axis: .vertical, distribution: .fillProportionally, spacing: 0.0)
        leftStack = UIStackView(arrangedSubviews: [icon, caption], axis: .vertical, distribution: .fillProportionally, spacing: 0.0)
        leftStack.alignment = .center
        self.addSubViews([leftStack, rightStack])
    }
    /**
     Set the content of the cell.
     
     - Parameter currentPlacemark: The data object that contains the data to be displayed.
     */
    func configure(_ currentPlacemark: CLPlacemark) {
        title.text = currentPlacemark.name
        subTitle.text = parseAddress(currentPlacemark)
        // Will be used in until point of interest category information is released in iOS 13
        // icon.image = ResManager.placemarkIcon(currentPlacemark.areasOfInterest).colored(.gray)
        guard
            let userLoc = appDelegate.latestLocation,
            let placemarkLocation = currentPlacemark.location
        else {
            return
        }
        let distance = round(userLoc.distance(from: placemarkLocation) / 1600.0 * 10) / 10
        self.caption.text = "\(distance) mi"
    }
    /**
     Parse the address from placemark.
     Refer to https://www.thorntech.com/2016/01/how-to-search-for-location-using-apples-mapkit/
     
     - Parameter placemark: The placemark data object.
     
     - Returns: A string represents the address of the placemark.
     */
    private func parseAddress(_ placemark: CLPlacemark) -> String {
        let firstSpace = (placemark.subThoroughfare != nil && placemark.thoroughfare != nil) ? " " : ""
        let comma = (placemark.subThoroughfare != nil || placemark.thoroughfare != nil) && (placemark.subAdministrativeArea != nil || placemark.administrativeArea != nil) ? ", " : ""
        let secondSpace = (placemark.subAdministrativeArea != nil && placemark.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            placemark.subThoroughfare ?? "",
            firstSpace,
            // street name
            placemark.thoroughfare ?? "",
            comma,
            // city
            placemark.locality ?? "",
            secondSpace,
            // state
            placemark.administrativeArea ?? ""
        )
        return addressLine
    }
    // layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        // Set up layouts
        leftStack.setConstraintsToView(left: self, lConst: 0.02 * self.frame.width)
        rightStack.setConstraintsToView(right: self)
        self.addConstraints([
            NSLayoutConstraint(item: leftStack as Any, attribute: .centerY,
                               relatedBy: .equal,
                               toItem: self, attribute: .centerY,
                               multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: rightStack as Any, attribute: .centerY,
                               relatedBy: .equal,
                               toItem: self, attribute: .centerY,
                               multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: rightStack as Any, attribute: .left,
                               relatedBy: .equal,
                               toItem: leftStack, attribute: .right,
                               multiplier: 1.0, constant: 0.03*self.frame.width)
            ])
        leftStack.setWidthConstraint(self.frame.height)
        icon.setWidthConstraint(0.4*self.frame.height)
        self.layoutIfNeeded()
    }
    // Required init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
