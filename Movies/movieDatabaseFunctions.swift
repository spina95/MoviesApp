//
//  movieDatabaseFunctions.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 21/03/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import  Kingfisher

func alamoRequest(url: String, completion: @escaping ([String: Any]?) -> Void) {
    Alamofire.request(url)
        .responseJSON { response in
            guard response.result.isSuccess else {
                print("Error while fetching tags: \(response.result.error)")
                completion(nil)
                return
            }
            guard let responseJSON = response.result.value as? [String: Any] else {
            print("Invalid tag information received from the service")
            completion(nil)
            return
        }
    completion(responseJSON)
    }
}

extension UIImageView {
    func downloadImage(path: String?, placeholder: UIImage) {
        if(path != nil) {
            if let text = path {
                let url = URL(string: "http://image.tmdb.org/t/p/w185/\((text))")
                self.sd_setImage(with: url, placeholderImage: placeholder, options: .highPriority) { (image, error, cahche, url) in
                    return
                }
            }
        }
    }
    func downloadImage(path: String?, placeholder: UIImage, finished: @escaping () -> Void) {
        if(path != nil) {
            if let text = path {
                let url = URL(string: "http://image.tmdb.org/t/p/w185/\((text))")
                self.sd_setImage(with: url, placeholderImage: placeholder, options: .highPriority) { (image, error, cahche, url) in
                    finished()
                }
            }
        }
    }
}

extension UIImageView {
    func downloadImageURL(path: String?) {
        if(path != nil) {
            if let text = path {
                let url = URL(string: text)
                self.sd_setImage(with: url, placeholderImage: nil, options: .highPriority) { (image, error, cahche, url) in
                    return
                }
            }
        }
    }
}


func downloadImage2(imageUrl: String, completion: @escaping (UIImage?) -> Void){
    let url = URL(string: "http://image.tmdb.org/t/p/w185/\((imageUrl))")
    Alamofire.request(url!).downloadProgress(closure: { (progress) in
        
        
    }).responseData { (response) in
        print(response.result)
        print(response.result.value)
        
        if let data = response.result.value {
            completion(UIImage(data: data))
        }
        
    }
}

func downloadImage(imageUrl: String, completion: @escaping (UIImage?) -> Void){
    let url = URL(string: "http://image.tmdb.org/t/p/w185/\((imageUrl))")
    KingfisherManager.shared.retrieveImage(with: url!, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
        if(error == nil) {
            completion(image)
        }
    })
}


