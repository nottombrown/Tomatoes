//
//  MoviesViewController.swift
//  Tomatoes
//
//  Created by Tom Brown on 2/2/16.
//  Copyright © 2016 nottombrown. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import DGElasticPullToRefresh
import BFRadialWaveHUD

// Checking this into git because it can't do any damage
let API_KEY = "098829b5ff75eb5a772d899969c444e5"


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var endpoint: String?
    var titleString: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        fetchMovies()
        
        // Fancy pull to refresh
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = highlightColor
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
                self?.fetchMovies()
                self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(darkColor)
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
    }
    
    func fetchMovies() {
        if let endpoint = self.endpoint {
            let hud = createHUD()
            hud.show()
            Alamofire.request(.GET, "https://api.themoviedb.org/3/movie/\(endpoint)", parameters: ["api_key": API_KEY])
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        if let JSON = response.result.value {
                            self.movies = JSON["results"] as? [NSDictionary]
                            self.tableView.reloadData()
                            hud.hidden = true

                        }
                    case .Failure(_):
                        hud.showErrorWithMessage("Network Error")
                    }
            }
        }
    }
    
    // What's the swifty way of doing this? Maybe save it as a variable in an initializer?
    // Maybe turn it into a memoized computed property?
    func createHUD() -> BFRadialWaveHUD {
        // https://github.com/bfeher/BFRadialWaveHUD
        let hud = BFRadialWaveHUD(view: self.view,
            fullScreen: false,
            circles:BFRadialWaveHUD_DefaultNumberOfCircles,
            circleColor:nil,
            mode:.Default,
            strokeWidth:BFRadialWaveHUD_DefaultCircleStrokeWidth
        )
        hud.tapToDismiss = true

        return hud
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] {
            let imageUrl = NSURL(string: "\(baseUrl)\(posterPath)")
            cell.posterView.af_setImageWithURL(imageUrl!)
        }
        
        cell.titleLabel!.text = title
        cell.overviewLabel!.text = overview
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movies![indexPath!.row]
    }

    
}
