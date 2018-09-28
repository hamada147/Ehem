//
//  MainViewController.swift
//  Lalamove
//
//  Created by Ahmed Moussa on 9/16/18.
//  Copyright © 2018 Moussa Tech. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, CAAnimationDelegate, UITableViewDelegate, UITableViewDataSource, ItemsReceivedDelegate {
    
    // MARK:- Class Variables
    var ItemsToDeliver: Array<DeliveryItem> = []
    var presenter: MainViewPresenter? = nil
    var LoadingView: UIView = UIView()
    var TableView: UITableView = UITableView()
    var showLoading: Bool = true
    
    // MARK:- Items Received Delegate
    func itemsDidReceive(items: Array<DeliveryItem>) {
        if (items.count > 0) {
            self.ItemsToDeliver.removeAll()
            self.ItemsToDeliver = items
            self.TableView.refreshControl?.endRefreshing()
            self.TableView.reloadData()
            self.showLoading = false
        } else {
            do {
                try self.getData()
            } catch {
                print(error)
            }
        }
    }
    
    func itemsFaildToRetrieve(errorMessage: String) {
        let alert: UIAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let ok: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel, handler: { action in
            self.showLoading = false
            self.TableView.refreshControl?.endRefreshing()
        })
        let retry: UIAlertAction = UIAlertAction(title: "Retry", style: .default, handler: { action in
            do {
                try self.getData()
            } catch let error {
                print(error)
            }
        })
        alert.addAction(ok)
        alert.addAction(retry)
        present(alert, animated: true, completion: nil)
    }
    
    func itemsEmpty() {
        let alert: UIAlertController = UIAlertController(title: "Info", message: "There is no items to deliver at the moment please try again in a few moments", preferredStyle: .alert)
        let ok: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel, handler: { action in
            self.showLoading = false
        })
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK:- Table View Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ItemsToDeliver.count
    }
    
    // on row select
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewController: DeliveryDetails = DeliveryDetails()
        viewController.ItelmDetails = self.ItemsToDeliver[indexPath.row]
        // self.navigationController?.pushViewController(viewController, animated: true)
        present(viewController, animated: true, completion: nil)
    }
    
    // MARK:- Table View Datasource Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryItem") as? DeliveryItemTableViewCell else {
            fatalError("Couldn't init DeliveryItem cell")
        }
        let currItem = self.ItemsToDeliver[indexPath.row]
        
        cell.imageView?.image = UIImage(data: currItem.image!)
        cell.textLabel?.text = currItem.itemDescription
        cell.accessoryType = currItem.itemDelivered ? .checkmark : .none
        
        return cell
    }
    
    // MARK:- App Life Cycle
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Things To Deliver"
        self.presenter = self.getPresenterController()
        self.createLoadingScreen()
        self.createTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTable), name: .DeliveryItemImageDownloaded, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.TableView.isHidden = true
        self.LoadingView.isHidden = false
        self.view.bringSubviewToFront(self.LoadingView)
        self.ItemsToDeliver.removeAll()
        self.TableView.reloadData()
        self.runLoadingViewAnimation()
        self.presenter?.getSavedData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK:- Notification handlers
    @objc private func reloadTable() {
        DispatchQueue.main.async {
            self.TableView.reloadData()
        }
    }
    
    // MARK:- Network
    private func getData() throws {
        guard let presenter = self.presenter else {
            throw "presenter wasn't initialized"
        }
        presenter.getData()
    }
    
    // MARK:- Create Views
    private func createTableView() {
        // set table frame
        self.TableView = UITableView(frame: self.view.frame)
        self.TableView.translatesAutoresizingMaskIntoConstraints = false
        self.TableView.delegate = self
        self.TableView.dataSource = self
        self.TableView.isHidden = true
        self.view.addSubview(self.TableView)
        // set table view constraints
        self.TableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.TableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.TableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.TableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        // register it's cells
        self.TableView.register(DeliveryItemTableViewCell.self, forCellReuseIdentifier: "DeliveryItem")
        // set cell row height
        self.TableView.rowHeight = 54
        // hide cell separator
        self.TableView.separatorStyle = .none
        // set Refresh Control
        self.TableView.refreshControl = UIRefreshControl()
        self.TableView.refreshControl?.addTarget(self, action: #selector(self.tablePullRefresh), for: .valueChanged)
        self.TableView.refreshControl?.tintColor = UIColor(red: 248/255, green: 160/255, blue: 27/255, alpha: 1)
        self.TableView.refreshControl?.attributedTitle = NSAttributedString(string: "Fetching new delivery Items")
    }
    
    private func createLoadingScreen() {
        self.LoadingView = UIView()
        self.view.bringSubviewToFront(self.LoadingView)
        // enable auto layout
        self.LoadingView.translatesAutoresizingMaskIntoConstraints = false
        // add it to the view
        self.view.addSubview(self.LoadingView)
        // set the view radius
        self.LoadingView.layer.cornerRadius = 25.0
        // set the wanted constraint
        let LoadingScreenSize: CGFloat = 64
        // set width and height constraint
        self.LoadingView.widthAnchor.constraint(equalToConstant: LoadingScreenSize).isActive = true
        self.LoadingView.heightAnchor.constraint(equalToConstant: LoadingScreenSize).isActive = true
        // center the view in the middle of the main view
        self.LoadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.LoadingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        let loadingImage = UIImageView(frame: CGRect(x: 0, y: 0, width: LoadingScreenSize, height: LoadingScreenSize))
        self.LoadingView.addSubview(loadingImage)
        loadingImage.translatesAutoresizingMaskIntoConstraints = false
        // set image view constraint
        loadingImage.widthAnchor.constraint(equalToConstant: LoadingScreenSize).isActive = true
        loadingImage.heightAnchor.constraint(equalToConstant: LoadingScreenSize).isActive = true
        loadingImage.leadingAnchor.constraint(equalTo: self.LoadingView.leadingAnchor).isActive = true
        loadingImage.topAnchor.constraint(equalTo: self.LoadingView.topAnchor).isActive = true
        // set image inside the image view
        let image: UIImage = UIImage(imageLiteralResourceName: "Lalamove")
        image.withRenderingMode(.alwaysTemplate)
        loadingImage.image = image
        loadingImage.tintColor = UIColor(red: 248/255, green: 160/255, blue: 27/255, alpha: 1)
    }
    
    // MARK:- Table Pull Refresh Event
    @objc private func tablePullRefresh() {
        do {
            try self.getData()
        } catch {
            print(error)
            self.TableView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK:- Animations
    private func runLoadingViewAnimation() {
        CATransaction.begin()
        let rotationAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = 45 * (Double.pi / 180)
        rotationAnimation.duration = 0.5
        rotationAnimation.isCumulative = true
        rotationAnimation.fillMode = CAMediaTimingFillMode.forwards
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.delegate = self
        self.LoadingView.layer.add(rotationAnimation, forKey: "rotationAnimation")
        CATransaction.commit()
    }
    
    private func resetLoadingAnimation() {
        self.LoadingView.transform = .identity
        self.LoadingView.layer.removeAllAnimations()
    }
    
    // MARK:- CA Animation Delegate
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if (anim == self.LoadingView.layer.animation(forKey: "rotationAnimation")) {
            if (flag == true) {
                let repeatedAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
                repeatedAnimation.toValue = 20 * (Double.pi / 180)
                repeatedAnimation.duration = 0.3
                repeatedAnimation.isCumulative = false
                repeatedAnimation.fillMode = CAMediaTimingFillMode.removed
                repeatedAnimation.isRemovedOnCompletion = false
                repeatedAnimation.delegate = self
                repeatedAnimation.autoreverses = true
                repeatedAnimation.repeatCount = 3
                self.LoadingView.layer.add(repeatedAnimation, forKey: "repeatedAnimation")
            }
        } else if (anim == self.LoadingView.layer.animation(forKey: "repeatedAnimation")) {
            if (flag == true) {
                if (self.showLoading == false) {
                    let moveingAnimation: CABasicAnimation = CABasicAnimation(keyPath: "position")
                    moveingAnimation.toValue = [self.view.frame.width + self.LoadingView.frame.width, self.LoadingView.frame.origin.y + (self.LoadingView.frame.height / 2)]
                    moveingAnimation.duration = 0.3
                    moveingAnimation.isCumulative = true
                    moveingAnimation.fillMode = CAMediaTimingFillMode.forwards
                    moveingAnimation.isRemovedOnCompletion = false
                    moveingAnimation.delegate = self
                    self.LoadingView.layer.add(moveingAnimation, forKey: "moveingAnimation")
                } else {
                    self.LoadingView.layer.removeAnimation(forKey: "repeatedAnimation")
                    let repeatedAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
                    repeatedAnimation.toValue = 20 * (Double.pi / 180)
                    repeatedAnimation.duration = 0.3
                    repeatedAnimation.isCumulative = false
                    repeatedAnimation.fillMode = CAMediaTimingFillMode.removed
                    repeatedAnimation.isRemovedOnCompletion = false
                    repeatedAnimation.delegate = self
                    repeatedAnimation.autoreverses = true
                    repeatedAnimation.repeatCount = 3
                    self.LoadingView.layer.add(repeatedAnimation, forKey: "repeatedAnimation")
                }
            }
        } else if (anim == self.LoadingView.layer.animation(forKey: "moveingAnimation")) {
            if (flag == true) {
                self.LoadingView.isHidden = true
                self.resetLoadingAnimation()
                self.TableView.reloadData()
                self.TableView.isHidden = false
            }
        }
    }
    
    // MARK:- Presenter
    private func getPresenterController() -> MainViewPresenter {
        return MainViewPresenter(viewController: self)
    }
    
}
