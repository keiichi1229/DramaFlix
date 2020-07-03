//
//  MasterViewController.swift
//  DramaDemo
//
//  Created by Raymondting on 2020/6/30.
//  Copyright © 2020 Raymondting. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import GSMessages
import Toast_Swift

let DEFAULT_INDICATOR_WIDTH_RATIO: CGFloat = 0.10
let DEFAULT_INDICATOR_HEIGHT_RATIO: CGFloat = 0.10

class DramaListViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate
{
    var _activityIndicatorView: NVActivityIndicatorView? = nil
    var _refreshControl: UIRefreshControl?
    var _searchBarControl: UISearchController?
    
    let _dropdownImagView = UIImageView()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupSearchBar()
        
        var style = ToastStyle()
        style.backgroundColor = .gray
        ToastManager.shared.isTapToDismissEnabled = true
        ToastManager.shared.style = style
        
        _dropdownImagView.image = UIImage(named: "dropdown")
        _dropdownImagView.contentMode = .scaleAspectFit
        _dropdownImagView.frame = CGRect.zero
        _dropdownImagView.isHidden = true
        
        self.tableView.addSubview(_dropdownImagView)
        
        _refreshControl = UIRefreshControl()
        _refreshControl?.tintColor = UIColor.white
        _refreshControl?.backgroundColor = UIColor.black
        _refreshControl?.addTarget(self, action: #selector(refreshDramaList), for: UIControl.Event.valueChanged)
        
        self.tableView.refreshControl = _refreshControl
        
        DramaDataMgr.shared.updateUIHandler = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self._refreshControl?.endRefreshing()
                self.stopLoadingIndicator()
                self._dropdownImagView.isHidden = true
                self.view.hideToast()
                self.displaySearchBar(display: true)
            }
        }
        
        DramaDataMgr.shared.statusHandler = {(status) in
            DispatchQueue.main.async {
                self._refreshControl?.endRefreshing()
                
                switch status
                {
                case .NetworkFail:
                    self.stopLoadingIndicator()
                    self.showMessage("You are not connect a network.", type: .error, options: [.autoHide(false), .position(.bottom)])
                case .NetworkResume:
                    self.hideMessage()
                case .FailedToLoadData:
                    self.stopLoadingIndicator()
                    self.showAlert(message: "Remote Data Load Failed!\nPlease Drop down to refresh data again.")
                    if DramaDataMgr.shared.countOfDramas() == 0
                    {
                        self._dropdownImagView.isHidden = false
                    }
                    
                    break
                }
            }
        }
        
        self.startLoadingIndicator()
        DramaDataMgr.shared.loadDramaData()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func viewWillLayoutSubviews()
    {
        _dropdownImagView.center = self.view.center
        _dropdownImagView.frame = CGRect(x: _dropdownImagView.frame.origin.x, y: 10, width: 30, height: 30)
    }

    
    @objc func refreshDramaList()
    {
        self.displaySearchBar(display: false)
        DramaDataMgr.shared.refreshDramaData()
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showDetail"
        {
            if let indexPath = tableView.indexPathForSelectedRow
            {
                let dramaItem = DramaDataMgr.shared.getDramaItem(withIdex: indexPath.row)
                if let controller = (segue.destination as? UINavigationController)?.topViewController as? DramaViewController
                {
                    controller.dramaItem = dramaItem
                    controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                    controller.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        }
    }

    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return DramaDataMgr.shared.countOfDramas()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dramaCell", for: indexPath) as! DramaTableViewCell
        
        guard let dramaItem = DramaDataMgr.shared.getDramaItem(withIdex: indexPath.row) else
        {
            return cell
        }
        
        cell.dramaName.text = dramaItem.dramaName
        cell.dramaDate.text = dramaItem.dramaCreateDate
        cell.ratingView.rating = dramaItem.dramaRating ?? 0
        cell.ratingView.text = String(format: "%.1f", dramaItem.dramaRating ?? 0)
        cell.dramaImg.image = DramaDataMgr.shared.getDramaImage(link: dramaItem.dramaImgURL)
        
        return cell
    }
    
    // MARK: - SearchBar
    func setupSearchBar()
    {
        _searchBarControl = UISearchController(searchResultsController: nil)
        _searchBarControl?.searchResultsUpdater = self
        _searchBarControl?.searchBar.placeholder = "Search your drama"
        _searchBarControl?.searchBar.delegate = self
        _searchBarControl?.searchBar.tintColor = .red
        navigationItem.searchController = _searchBarControl
        // default is hidden
        displaySearchBar(display: false)
    }
    
    func displaySearchBar(display: Bool)
    {
        self._searchBarControl?.searchBar.isHidden = !display
    }
    
    func updateSearchResults(for searchController: UISearchController)
    {
        let searchString = searchController.searchBar.text!
        DramaDataMgr.shared.startSearching(withText: searchString)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        DramaDataMgr.shared.stopSearching()
    }
    
    func startLoadingIndicator()
    {
        // block UI when start animation
        self.tableView.isUserInteractionEnabled = false
        
        if _activityIndicatorView != nil
        {
            _activityIndicatorView?.removeFromSuperview()
            _activityIndicatorView = nil
        }
        
        _activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width * DEFAULT_INDICATOR_WIDTH_RATIO, height: self.tableView.frame.height * DEFAULT_INDICATOR_HEIGHT_RATIO), type: .ballPulseSync, color: UIColor.white, padding: 0)
        _activityIndicatorView!.center = self.tableView.center
        self.tableView.addSubview(_activityIndicatorView!)
        _activityIndicatorView!.startAnimating()
    }
    
    func stopLoadingIndicator()
    {
        // block UI when start animation
        self.tableView.isUserInteractionEnabled = true
        
        if _activityIndicatorView != nil
        {
            _activityIndicatorView!.startAnimating()
            _activityIndicatorView?.removeFromSuperview()
            _activityIndicatorView = nil
        }
    }
    
    func showAlert(message: String)
    {
        self.view.hideToast()
        self.view.makeToast(message, duration: 300.0, position: .center)
    }
}

