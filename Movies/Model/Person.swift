//
//  Actor.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 22/06/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import Foundation
import ObjectMapper

class Person: Mappable {
    
    var adult: Bool?
    var biography: String?
    var birthday: String?
    var deathday: String?
    var gender: Int? //0=notset 1=female 2=male
    var homepage: String?
    var id: Int?
    var imdbId: Int?
    var name: String?
    var placeOfBirth: String?
    var profilePath: String?
    var profileImage: UIImage?
    var credits: (castCredits: [CastCredits]?, crewCredits: [CrewCredits]?)
    
    var knownFor: [Movie]?
    
    init(){}
    
    func getRoles() -> [String] {
        var roles = [String]()
        if(credits.castCredits != nil) {
            if(gender == 1) { roles.append("Actress")}
            if(gender == 2) { roles.append("Actor")}
        }
        if (credits.crewCredits != nil){
            for i in credits.crewCredits! {
                var check = 0
                for j in roles {
                    if(j == i.job) { check = 1}
                }
                if(check == 0) { roles.append(i.job!)}
            }
        }
        return roles
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        adult <- map["adult"]
        biography <- map["biography"]
        birthday <- map["birthday"]
        deathday <- map["deathday"]
        gender <- map["gender"]
        homepage <- map["homepage"]
        id <- map["id"]
        imdbId <- map["imdb_id"]
        name <- map["name"]
        placeOfBirth <- map["place_of_birth"]
        profilePath <- map["profile_path"]
        knownFor <- map["known_for"]
    }
}

class CastCredits: Mappable {
    
    var character: String?
    var credit_id: String?
    var releaseDate: String?
    var adult: Bool?
    var title: String?
    var genreIds: [Int]?
    var id: Int?
    var posterPath: String?
    var overview: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        character <- map["character"]
        credit_id <- map["credit_id"]
        releaseDate <- map["release_date"]
        adult <- map["adult"]
        title <- map["title"]
        genreIds <- map["genre_ids"]
        id <- map["id"]
        posterPath <- map["poster_path"]
        overview <- map["overview"]
    }
}

class CrewCredits: Mappable {
    
    var id: Int?
    var department: String?
    var job: String?
    var overview: String?
    var posterPath: String?
    var title: String?
    var genreIds: [Int]?
    var adult: Int?
    var releaseDate: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        department <- map["department"]
        job <- map["job"]
        adult <- map["adult"]
        overview <- map["overview"]
        posterPath <- map["poster_path"]
        title <- map["title"]
        genreIds <- map["genre_ids"]
        releaseDate <- map["release_date"]
    }
}
