//
//  Searchbar.swift
//  MaterialDesignSearchbar
//
//  Created by Ho, Tsungwei on 7/11/19.
//  Copyright © 2019 Ho, Tsungwei. All rights reserved.
//

import UIKit

class Searchbar: UIView, UITextFieldDelegate {
    // MARK: - UI widgets
    open var btnLeft: MaterialButton!
    open var btnRight: MaterialButton!
    open var textInput: MaterialTextField!
    // Delegation
    open weak var delegate: SearchbarDelegate?
    // MARK: - Public properties
    public var inputTimeout = 0.5
    public var cornerRadius: CGFloat = 10.0
    public var borderWidth: CGFloat = 1.0
    public var borderColor: UIColor = .lightGray
    public var searchbarHint = "Enter destination"
    public var foregroundColor: UIColor = .darkGray
    public var imgLeftBtn: UIImage = #imageLiteral(resourceName: "ic_search")
    // MARK: - Private properties
    private var stackView: UIStackView!
    private var onStartSearch: ((Bool) -> Void)?
    private var onClearInput: BtnAction?
    private var startSearch: DispatchWorkItem?
    private let animHplr = AnimHelper.shared
    // Init
    private override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        btnLeft.addTarget(self, action: #selector(tapLeftBtn), for: .touchUpInside)
        btnRight.addTarget(self, action: #selector(tapRightBtn), for: .touchUpInside)
        textInput.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
    }
    /**
     Convenience initializer.
     
     - Parameter onTapLeft:
     - Parameter onTapRight:
     - Parameter delegate:
     */
    public convenience init(onStartSearch: ((Bool) -> Void)?, onClearInput: BtnAction?, delegate: SearchbarDelegate) {
        // We use zero here since the size of the view is handled by AutoLayout.
        self.init(frame: .zero)
        self.delegate = delegate
        self.onStartSearch = onStartSearch
        self.onClearInput = onClearInput
    }
    /**
     Init UI.
     */
    private func initUI() {
        self.backgroundColor = .white
        // Set corner border
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        // Set up textField
        textInput = MaterialTextField(hint: searchbarHint, textColor: foregroundColor, font: ResManager.Font.regular(16.0), bgColor: self.backgroundColor ?? .white, delegate: self)
        textInput.autocorrectionType = .no
        textInput.returnKeyType = .search
        textInput.enablesReturnKeyAutomatically = true
        // Set up buttons
        btnLeft = MaterialButton(icon: imgLeftBtn.colored(foregroundColor), bgColor: self.backgroundColor ?? .white)
        btnRight = MaterialButton(icon: #imageLiteral(resourceName: "ic_clear").colored(foregroundColor), bgColor: self.backgroundColor ?? .white)
        stackView = UIStackView(arrangedSubviews: [btnLeft, textInput, btnRight], axis: .horizontal, distribution: .fillProportionally, spacing: 0.0)
        self.addSubViews([stackView])
        setBtnStates(hasInput: false, isSearching: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        btnLeft.widthAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.8).isActive = true
        btnRight.widthAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.8).isActive = true
    }
    
    @objc private func tapLeftBtn() {
        if textInput.isFirstResponder {
            textInput.resignFirstResponder()
            onStartSearch?(false)
        } else {
            textInput.becomeFirstResponder()
            onStartSearch?(true)
        }
    }
    
    @objc private func tapRightBtn() {
        textInput.text = ""
        btnRight.isHidden = true
        onClearInput?()
    }
    // MARK: UITextFieldDelegate
    @objc private func textFieldDidChange(_ textField: UITextField) {
        startSearch?.cancel()
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces).count == 0 ? "" : textField.text
        setBtnStates(hasInput: textField.text?.count != 0, isSearching: true)
        startSearch = DispatchWorkItem { [weak self] in
            guard let self = self, let startSearch = self.startSearch, !startSearch.isCancelled else { return }
            self.delegate?.searchbarTextDidChange(textField)
        }
        guard let search = self.startSearch else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + inputTimeout, execute: search)
    }
    // textFieldDidBeginEditing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces).count == 0 ? "" : textField.text
        setBtnStates(hasInput: textField.text?.count != 0, isSearching: true)
        delegate?.textFieldDidBeginEditing(textField)
    }
    // textFieldDidEndEditing
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces).count == 0 ? "" : textField.text
        delegate?.textFieldDidEndEditing(textField)
    }
    // textFieldShouldReturn
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces).count == 0 ? "" : textField.text
        setBtnStates(hasInput: textField.text?.count != 0, isSearching: false)
        return delegate?.searchbarTextShouldReturn(textField) ?? true
    }
    // Required init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /**
     Change button icons in search bar based on current state.
     
     - Parameter hasInput:    The flag indicates if the search bar has text input.
     - Parameter isSearching: The flag indicates if the search bar is in search state.
     */
    open func setBtnStates(hasInput: Bool, isSearching: Bool) {
        btnRight.isHidden = !hasInput
        switchLeftBtn(isSearching)
    }
    /**
     Change the left button state and animate the button icon.
     
     - Parameter isSearching: The flag to indicate that if the search bar is in searching state.
     */
    private func switchLeftBtn(_ isSearching: Bool) {
        guard btnLeft.tag != (isSearching ? 1 : 0) else { return }
        btnLeft.tag = isSearching ? 1 : 0
        btnLeft.setImage(isSearching ? #imageLiteral(resourceName: "ic_back").colored(.darkGray)! : imgLeftBtn.colored(.darkGray)!)
        isSearching
            ? animHplr.moveUpViews([btnLeft], show: true) : animHplr.moveDownViews([btnLeft], show: true)
        if !isSearching {
            textInput.resignFirstResponder()
        }
    }
    // deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
        textInput.removeTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        btnRight.removeTarget(self, action: #selector(tapRightBtn), for: .touchUpInside)
    }
}
// MARK: - SearchbarDelegate
protocol SearchbarDelegate: UITextFieldDelegate {
    func searchbarTextDidChange(_ textField: UITextField)
    func textFieldDidBeginEditing(_ textField: UITextField)
    func textFieldDidEndEditing(_ textField: UITextField)
    func searchbarTextShouldReturn(_ textField: UITextField) -> Bool
}
