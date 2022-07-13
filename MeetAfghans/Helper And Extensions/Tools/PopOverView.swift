//
//  PopOverView.swift
//  Sama Contact Lens
//
//  Created by Convergent Infoware on 27/10/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import Foundation
import UIKit


// Popover with tableView
class PopoverView: NSObject, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, UISearchBarDelegate{
    enum Mode {
        case withImage
        case textOnly
    }
    private var parentView: UIViewController?
    private var delegate: PopoverViewDelegate?
    private var pickerView = UITableViewController()
    private var items: [Countries]?
    private var searchItems: [Countries]?
    private var stringItems: [String]?
    private var searchStringItems: [String]?
    private var indexPath: IndexPath?
    private var sender: UIView?
    private var showName: Bool?
    private var mode: Mode = .textOnly
    private var headerText: String?
    private var isSearchOn = false
    public var needSearch : Bool = true
    private lazy var searchBar:UISearchBar = UISearchBar()
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .textOnly:
            return isSearchOn ? searchStringItems?.count ?? 0 : stringItems?.count ?? 0
        case .withImage:
            return isSearchOn ? searchItems?.count ?? 0 : items?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch mode {
        case .textOnly:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            if isSearchOn{
                cell.textLabel?.text = searchStringItems?[indexPath.row]
            }else{
                cell.textLabel?.text = stringItems?[indexPath.row]
            }
            cell.selectionStyle = .none
            return cell
        case .withImage:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            let data = isSearchOn ? self.searchItems?[indexPath.row] : self.items?[indexPath.row]
            cell.textLabel?.text = showName ?? false ? "\(data?.name ?? "")" : "+\(data?.phonecode?.description ?? "91")"
            cell.imageView?.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            cell.imageView?.getImage(withUrl: "\("")\(data?.sortname?.lowercased() ?? "").png", placeHolder: UIImage(named: "flag-placeholder"), imgContentMode : .scaleAspectFit)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pickerView.dismiss(animated: true, completion: {
            if self.isSearchOn {
                if self.mode == .textOnly{
                    if let index = self.stringItems?.firstIndex(where: {$0 == self.searchStringItems?[indexPath.row]}){
                        self.delegate?.getvalue(index: index, indexPath: self.indexPath ?? IndexPath(), sender: self.sender ?? UIView())
                    }
                }else{
                    if let index = self.items?.firstIndex(where: {$0.sortname == self.searchItems?[indexPath.row].sortname}){
                        self.delegate?.getvalue(index: index, indexPath: self.indexPath ?? IndexPath(), sender: self.sender ?? UIView())
                    }
                }
            }else{
                self.delegate?.getvalue(index: indexPath.row, indexPath: self.indexPath ?? IndexPath(), sender: self.sender ?? UIView())
            }
        })
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if headerText != nil {
            let view = UIViewX(frame: CGRect(x: 10, y: 0, width: tableView.bounds.width - 20, height: 45))
            view.firstColor = CommonColor.ButtonGradientFirst
            view.secondColor = CommonColor.ButtonGradientSecond
            view.horizontalGradient = true
            let label = UILabel(frame: view.frame)
            label.text = headerText
            label.font = UIFont(name: "Cairo-Bold", size: 16) ?? .boldSystemFont(ofSize: 16.0)
            label.textColor = .white
            label.font = UIFont(name: "Cairo-Bold", size: 18)
            view.addSubview(label)
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if headerText != nil {
            return 45
        }
        return 0
    }
    
    init(parentView: UIViewController, delegate: PopoverViewDelegate) {
        self.parentView = parentView
        self.delegate = delegate
    }
    
    func show(with items: [String], sender: UIView, needSearch : Bool,showDirection: UIPopoverArrowDirection = .up, indexPath: IndexPath = IndexPath(), header: String? = nil, width: CGFloat = 150) {
        mode = .textOnly
        self.stringItems = items
        self.indexPath = indexPath
        self.sender = sender
        self.needSearch = needSearch
        showName = false
        headerText = header
        pickerView.tableView.separatorStyle = .none
        pickerView.tableView.showsVerticalScrollIndicator = false
        pickerView.tableView.bounces = false
        createPopoverView(showDirection: showDirection, width: width)
    }
    
    func show(with items: [Countries], sender: UIView, needSearch : Bool, showDirection: UIPopoverArrowDirection = .up, indexPath: IndexPath = IndexPath()) {
        mode = .withImage
        self.items = items
        self.indexPath = indexPath
        self.sender = sender
        self.needSearch = needSearch
        self.isSearchOn = false
        showName = false
        createPopoverView(showDirection: showDirection)
    }
    
    func showNames(with items: [Countries], sender: UIView, needSearch : Bool, showDirection: UIPopoverArrowDirection = .up, width: CGFloat = 150, indexPath: IndexPath = IndexPath()) {
        mode = .withImage
        self.items = items
        self.isSearchOn = false
        self.indexPath = indexPath
        self.sender = sender
        self.needSearch = needSearch
        showName = true
        createPopoverView(showDirection: showDirection, width: width)
    }
    
    private func createPopoverView(showDirection: UIPopoverArrowDirection = .up, width: CGFloat = 150) {
        pickerView.tableView.delegate = self
        pickerView.tableView.dataSource = self
        pickerView.tableView.reloadData()
        pickerView.tableView.tableFooterView = UIView()
        pickerView.tableView.keyboardDismissMode = .onDrag
        pickerView.modalPresentationStyle = .popover
        pickerView.preferredContentSize = CGSize(width: width, height: pickerView.tableView.contentSize.height)
        if needSearch {
            let nav = UINavigationController(rootViewController: pickerView)
            parentView?.present(nav, animated: true, completion: {
                self.searchBar.searchBarStyle = .prominent
                self.searchBar.text = ""
                self.searchBar.placeholder = "Search here..."
                self.searchBar.sizeToFit()
                self.searchBar.keyboardType = self.showName ?? false ? .default : .phonePad
                self.searchBar.isTranslucent = false
                self.searchBar.backgroundImage = UIImage()
                self.searchBar.delegate = self
                self.pickerView.navigationItem.titleView = self.searchBar
                self.pickerView.navigationItem.setRightBarButton(UIBarButtonItem(title: "Cancel".localizedWithLanguage,style : .done, target: self, action: #selector(self.btnClose)), animated: true)
            })
        }else{
            let popOverVC = pickerView.popoverPresentationController
            popOverVC?.containerView?.layer.shadowColor = UIColor.black.cgColor;
            popOverVC?.permittedArrowDirections = showDirection
            popOverVC?.containerView?.layer.shadowOpacity = 0.4;
            popOverVC?.containerView?.layer.shadowOffset = CGSize(width: 0.0, height: 0.0);
            popOverVC?.containerView?.layer.shadowRadius = 10.0;
            popOverVC?.delegate = self
            popOverVC?.sourceView = sender
            parentView?.present(pickerView, animated: true, completion: nil)
        }
    }
    
    @objc private func btnClose(_ from : UIBarButtonItem){
        pickerView.dismiss(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.trim().count == 0{
            self.isSearchOn = false
        }else{
            switch mode{
            case .textOnly :
                self.isSearchOn = true
                self.searchStringItems = stringItems?.filter({($0.localizedCaseInsensitiveContains(searchText))})
                break
            case .withImage :
                self.isSearchOn = true
                if showName ?? false{
                    self.searchItems = items?.filter({($0.name?.localizedCaseInsensitiveContains(searchText) ?? false)})
                }else{
                    self.searchItems = items?.filter({("+\($0.phonecode?.description ?? "")".localizedCaseInsensitiveContains(searchText))})
                }
                break
            }
        }
        pickerView.tableView.reloadData()
    }
}

protocol PopoverViewDelegate {
    func getvalue(index: Int, indexPath: IndexPath, sender: UIView)
}
