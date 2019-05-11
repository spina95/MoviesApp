//
//  Movie.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 22/06/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import Foundation
import ObjectMapper
import TMDBSwift

class Movie: Mappable {
    required init?(map: Map) {
        
    }
    
    
    var title: String?
    var id: Int?
    var originalTitle: String?
    var overview: String?
    var originalLanguage: String?
    var posterPath: String?
    var poster: UIImage?
    var imdbID: String?
    var budget: Int?
    var adult: Bool?
    var homepage: String?
    var tagline: String?
    var runtime: Int?
    var genres: [Genre]?
    var productionCompanies: [ProductionCompanies]?
    var productionCountries: [ProductionCountries]?
    var releaseDate: String? = ""
    var revenue: Int?
    var spokenLanguages: [SpokenLanguages]?
    var status: String?
    var voteAverage: Double?
    var voteCount: Int?
    
    var cast: [Role]?
    var crew: [CrewMember]?
    var videos: [MovieVideo]?
    var similarMovies: [Movie]?
    var backdrops: [MovieImage]?
    var posters: [MovieImage]?
    
    init () {
    }
    
    func mapping(map: Map) {
        title <- map["title"]
        id <- map["id"]
        adult <- map["adult"]
        budget <- map["budget"]
        homepage <- map["homepage"]
        imdbID <- map["imdb_id"]
        originalLanguage <- map["original_language"]
        originalTitle <- map["original_title"]
        overview <- map["overview"]
        posterPath <- map["poster_path"]
        tagline <- map["tagline"]
        genres <- map["genres"]
        productionCompanies <- map["production_companies"]
        productionCountries <- map["production_countries"]
        releaseDate <- map["release_date"]
        revenue <- map["revenue"]
        runtime <- map["runtime"]
        spokenLanguages <- map["spoken_languages"]
        status <- map["status"]
        voteAverage <- map["vote_average"]
        voteCount <- map["vote_count"]
    }
}

class Genre: Mappable {
    
    var id: Int?
    var name: String?
    
    init() {}
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}

class ProductionCompanies: Mappable {
    
    var name: String?
    var id: Int?
    var origin_country: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        id <- map["id"]
        origin_country <- map["origin_country"]
    }
}

class ProductionCountries: Mappable {
    
    var iso_3166_1: String?
    var name: String?
    
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        iso_3166_1 <- map["iso_3166_1"]
        name <- map["name"]
    }
}

class SpokenLanguages: Mappable {
    
    var iso_639_1: String?
    var name: String?
    
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        iso_639_1 <- map["iso_639_1"]
        name <- map["name"]
    }
}

class Role: Mappable {
    
    var castId: Int?
    var character: String?
    var credit_id: String?
    var gender: Int?
    var id: Int?
    var name: String?
    var order: Int?
    var profilePath: String?
    var profileImage: UIImage?
    
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        castId <- map["cast_id"]
        character <- map["character"]
        credit_id <- map["credit_id"]
        gender <- map["gender"]
        id <- map["id"]
        name <- map["name"]
        order <- map["order"]
        profilePath <- map["profile_path"]
    }
}
    
class CrewMember: Mappable {
        
        var creditId: String?
        var department: String?
        var gender: Int?
        var id: Int?
        var job: String?
        var name: String?
        var profilePath: String?
        
        required init?(map: Map){
        }
        
        func mapping(map: Map) {
            creditId <- map["credit_id"]
            department <- map["department"]
            gender <- map["gender"]
            id <- map["id"]
            job <- map["job"]
            name <- map["name"]
            profilePath <- map["profile_path"]
        }
}

class MovieImage: Mappable {
    
    var filePath: String?
    var heigth: Int?
    var iso_639_1: String?
    var width: Int?
    
    init(){
        
    }
    
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        filePath <- map["file_path"]
        heigth <- map["height"]
        iso_639_1 <- map["iso_639_1"]
        width <- map["width"]
    }
}

class MovieVideo: Mappable {
    
    var id: String?
    var iso_639_1: String?
    var iso_3166_1: String?
    var name: String?
    var key: String?
    var site: String?
    var size: Int?
    var type: String?
    
    init(){}
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        id <- map["id"]
        iso_639_1 <- map["iso_639_1"]
        iso_3166_1 <- map["iso_3166_1"]
        name <- map["name"]
        site <- map["site"]
        size <- map["size"]
        type <- map["type"]
        key <- map["key"]
    }
}

