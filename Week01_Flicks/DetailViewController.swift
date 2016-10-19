 //
//  DetailViewController.swift
//  Week01_Flicks
//
//  Created by Tran Khanh Trung on 10/16/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    var movie: NSDictionary!
    @IBOutlet weak var infoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        scrollView.contentSize = CGSize(
            width: scrollView.frame.width,
            height: infoView.frame.origin.y + infoView.frame.size.height )
        
        
        let title = movie["title"] as? String
        titleLabel.text = title
        
        let overview = movie["overview"] as? String
        overviewLabel.text = overview
        overviewLabel.sizeToFit() 
        //infoView.sizeToFit()
        
        if let posterPath = movie["poster_path"] as? String{
            
            // MARK: - cell.posterView.setImageWith (Fade in Effect)
            let baseURL = "https://image.tmdb.org/t/p/w130"
            let imageURL = URL(string: baseURL + posterPath)!
            //posterImageView.setImageWith(imageURL as! URL)
            let imageRequest = NSURLRequest(url: imageURL)
            
            posterImageView.setImageWith(
                imageRequest as URLRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) in
                    // imageResponse will be nil if the image is cached
                    //if imageResponse != nil {
                    
                        //print("Image was NOT cached, fade in image")
                        self.posterImageView.alpha = 0.0
                        self.posterImageView.image = image
                        UIView.animate(withDuration: 0.3,
                                       animations: { () -> Void in self.posterImageView.alpha = 1.0 },
                                       completion: { (success) in
                                        
                                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                                        // per ImageView. This code must be in the completion block.
                                        let bigImageURL = URL(string: "https://image.tmdb.org/t/p/w500" + posterPath)!
                                        let bigImageRequest = NSURLRequest(url: bigImageURL)
                                        
                                        self.posterImageView.setImageWith(
                                            bigImageRequest as URLRequest,
                                            placeholderImage: nil,
                                            success: { (bigImageRequest, bigImageResponse, bigImage) in
                                                if bigImageResponse != nil {
                                                    
                                                    // success get hi res image
                                                    self.posterImageView.image = bigImage
                                                }
                                            }, failure: { (imageRequest, imageResponse, error) in
                                                // do something for the failure condition
                                        })
                        })
                    
//                    } else {
//                        //print("Image was cached so just update the image")
//                        self.posterImageView.image = image
//                    }
                },
                failure: { (imageRequest, imageResponse, error) in
                    // do something for the failure condition
            })
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
