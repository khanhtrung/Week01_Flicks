//
//  MoviesViewController.swift
//  Week01_Flicks
//
//  Created by Tran Khanh Trung on 10/15/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import Reachability

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate  {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!
    var movies: [NSDictionary]?
    var endpoint: String!
    var refreshControl: UIRefreshControl!
    var reachability: Reachability?
    
    override func viewWillAppear(_ animated: Bool) {
        setupReachability()
        setErrorViewHidden()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSearchBar()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(requestNetwork), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        requestNetwork()//refreshControl: refreshControl)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - REQUEST NETWORK
    func requestNetwork(){//refreshControl: UIRefreshControl){
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        /*let request = URLRequest(
            url: url!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)*/
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        // Display HUD before make request
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask =
            session.dataTask(with: request,
                             completionHandler: { (dataOrNil, response, errorOrNil) in
                                
                                /*if let requestErr = errorOrNil{
                                    //
                                } else*/
                                    if let data = dataOrNil {
                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                        with: data, options:[]) as? NSDictionary {
                                        //print("response: \(responseDictionary)")
                                        
                                        self.movies = responseDictionary["results"] as? [NSDictionary]
                                        self.tableView.reloadData()
                                    }
                                } else {
                                    print("There was a network error.")
                                }

                                // Hide HUD when data sent back from request
                                MBProgressHUD.hide(for: self.view, animated: true)
                                self.refreshControl.endRefreshing()
            })
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let movies = movies{
             return movies.count
        } else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as? String
        cell.titleLabel.text = title
        
        let overview = movie["overview"] as? String
        cell.overviewLabel.text = overview
        
        if let posterPath = movie["poster_path"] as? String{
            let baseURL = "https://image.tmdb.org/t/p/w500"
            
            // MARK: - cell.posterView.setImageWith (Fade in Effect)
            let imageURL = NSURL(string: baseURL + posterPath)
            //cell.posterView.setImageWith(imageURL as! URL)
            
            let imageRequest = NSURLRequest(url: imageURL as! URL)
            cell.posterView.setImageWith(
                imageRequest as URLRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) in
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        //print("Image was NOT cached, fade in image")
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        //print("Image was cached so just update the image")
                        cell.posterView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) in
                    // do something for the failure condition
            })
            
            //cell = loadMoviePoster(imageURL: imageURL!,cell: cell)
        }
        
        return cell
    }
    
    /*
    func loadMoviePoster(imageURL: NSURL, cell: MovieCell) -> MovieCell{
        let imageRequest = NSURLRequest(url: imageURL as URL)
        cell.posterView.setImageWith(
            imageRequest as URLRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) in
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    //print("Image was NOT cached, fade in image")
                    cell.posterView.alpha = 0.0
                    cell.posterView.image = image
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        cell.posterView.alpha = 1.0
                    })
                } else {
                    //print("Image was cached so just update the image")
                    cell.posterView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) in
                // do something for the failure condition
        })
        return cell
    }
    */
    
    
    func createSearchBar(){
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search movies"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        searchBar.becomeFirstResponder()
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        //searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        
        print(searchBar.text!)
        searchMovie(movieSearchString: searchBar.text!)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        
        requestNetwork()//refreshControl: self.refreshControl)
    }
    
    // MARK: - SEARCH
    func searchMovie(movieSearchString: String!){
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(movieSearchString!)")
        let request = URLRequest(url: url!)
        
        
        print(url)
        
        /*let request = URLRequest(
         url: url!,
         cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
         timeoutInterval: 10)*/
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        // Display HUD before make request
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask =
            session.dataTask(with: request,
                             completionHandler: { (dataOrNil, response, errorOrNil) in
                                
                                /*if let requestErr = errorOrNil{
                                 //
                                 } else*/
                                if let data = dataOrNil {
                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                        with: data, options:[]) as? NSDictionary {
                                        //print("response: \(responseDictionary)")
                                        
                                        self.movies = responseDictionary["results"] as? [NSDictionary]
                                        self.tableView.reloadData()
                                    }
                                } else {
                                    print("There was a network error.")
                                }
                                
                                // Hide HUD when data sent back from request
                                MBProgressHUD.hide(for: self.view, animated: true)
                                self.refreshControl.endRefreshing()
            })
        task.resume()
    }
    
    // MARK: - Reachability Setup
    func setupReachability(){
        // Allocate a reachability object
        self.reachability = Reachability.forInternetConnection()
        
        // Tell the reachability that we DON'T want to be reachable on 3G/EDGE/CDMA
        self.reachability!.reachableOnWWAN = false
        
        // Here we set up a NSNotification observer. The Reachability that caused the notification
        // is passed in the object parameter
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged),
                                               name: NSNotification.Name.reachabilityChanged,
                                               object: nil)
        
        self.reachability!.startNotifier()
    }
    
    func reachabilityChanged(notification: NSNotification) {
        setErrorViewHidden()
    }
    
    func setErrorViewHidden(){
        if self.reachability!.isReachableViaWiFi() || self.reachability!.isReachableViaWWAN() {
            print("Service avalaible!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            self.networkErrorView.isHidden = true
        } else {
            print("No service avalaible!!!!!!!!!!!!!!!!!!!!!!!!!")
            self.networkErrorView.isHidden = false
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let cell = sender as! UITableViewCell
        let indexpath = tableView.indexPath(for: cell)
        let movie = movies?[(indexpath?.row)!]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
