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

// Checking this into git because it can't do any damage
let API_KEY = "098829b5ff75eb5a772d899969c444e5"


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var endpoint: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if let endpoint = self.endpoint {
            Alamofire.request(.GET, "https://api.themoviedb.org/3/movie/\(endpoint)", parameters: ["api_key": API_KEY])
                .responseJSON { response in
                    if let JSON = response.result.value {
                        self.movies = JSON["results"] as? [NSDictionary]
                        self.tableView.reloadData()
                    }
            }
        }
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
