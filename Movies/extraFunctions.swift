//
//  extraFunctions.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 23/03/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage
import Alamofire
import TMDBSwift

let mainColor = UIColor(red:74/255, green:144/255, blue:226/255, alpha:1.0)
let backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
let yellowColor = UIColor(red: 248/255, green: 207/255, blue: 28/255, alpha: 1.0)
let redColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0)
let greenColor = UIColor(red: 109/255, green: 183/255, blue: 93/255, alpha: 1.0)
let brownColor  = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1.0)
let apikey = "fa7f8ec398c80ce982ed4ceb6d95871f"

extension UIView {
    func roundCorners (value: Double) {
        layer.cornerRadius = CGFloat(value);
        clipsToBounds = true;
    }
}

func addShadowCell(cell: UITableViewCell) {
    cell.layer.shadowOpacity = 0.2
    cell.layer.shadowOffset = CGSize(width: 0, height: 2)
    cell.layer.shadowRadius = 2
    cell.layer.shadowColor = UIColor.black.cgColor
    cell.layer.masksToBounds = false
}

func roleToActor (role: Role) -> Person {
    var actor = Person()
    actor.name = role.name
    actor.id = role.id
    actor.profilePath = role.profilePath
    actor.profileImage = role.profileImage
    return actor
}

func dateToYear (dateString: String) -> Int{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    let date = dateFormatter.date(from:dateString)
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day, .hour], from: date!)
    let finalDate = calendar.date(from:components)
    let formatter = DateFormatter()
    formatter.dateStyle = DateFormatter.Style.long
    formatter.timeStyle = .medium
    let year = calendar.component(.year, from: finalDate!)
    return year
}

func convertDateFormatter(date: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"//this your string date format
    dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
    dateFormatter.locale = Locale(identifier: "your_loc_id")
    let convertedDate = dateFormatter.date(from: date)
    
    guard dateFormatter.date(from: date) != nil else {
        assert(false, "no date from string")
        return ""
    }
    
    dateFormatter.dateFormat = "d MMMM yyyy"///this is what you want to convert format
    dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
    let timeStamp = dateFormatter.string(from: convertedDate!)
    return timeStamp
}
let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImageUsingCacheWithUrlString(_ urlString: String) {
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        let url = URL(string: "http://image.tmdb.org/t/p/w185/\((urlString))")
        
        Alamofire.request(url!).responseImage { (response) in
            if let downladedImage = response.result.value {
                imageCache.setObject(downladedImage, forKey: urlString as NSString)
                self.image = downladedImage
            }
        }
    }
}

func addShadow(navigationController: UINavigationController?) {
    navigationController?.navigationBar.shadowImage = UIImage()
    navigationController?.navigationBar.layer.masksToBounds = false
    navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
    navigationController?.navigationBar.layer.shadowOpacity = 0.8
    navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
    navigationController?.navigationBar.layer.shadowRadius = 3
}

func getTodayString() -> String{
    let date = Date()
    let calender = Calendar.current
    let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second,.nanosecond], from: date)
    
    let year = components.year
    let month = components.month
    let day = components.day
    let hour = components.hour
    let minute = components.minute
    let second = components.second
    let nanosecond = components.nanosecond
    let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + "-" + String(hour!)  + "-" + String(minute!) + "-" +  String(second!) + "-" +  String(nanosecond!)
    return today_string
    
}

func StringToDate(isoDate: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss-SSSS"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    let date = dateFormatter.date(from:isoDate)!
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
    let finalDate = calendar.date(from:components)
    return finalDate!
}

struct LanguageHelper {
    static func getLanguageStringFrom(code:String) -> String? {
        let locale: NSLocale? = NSLocale(localeIdentifier: "en")
        return locale?.displayName(forKey: .identifier, value: code)
    }
}

@IBDesignable class RoundButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet {
            refreshCorners(value: cornerRadius)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        refreshCorners(value: cornerRadius)
    }
    
    func refreshCorners(value: CGFloat) {
        layer.cornerRadius = value
    }
}

@IBDesignable class RoundView: UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet {
            refreshCorners(value: cornerRadius)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        refreshCorners(value: cornerRadius)
    }
    
    func refreshCorners(value: CGFloat) {
        layer.cornerRadius = value
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// Shift Array
extension Array {
    
    func shiftRight( amount: Int = 1) -> [Element] {
        var amountMutable = amount
        assert(-count...count ~= amountMutable, "Shift amount out of bounds")
        if amountMutable < 0 { amountMutable += count }  // this needs to be >= 0
        return Array(self[amountMutable ..< count] + self[0 ..< amountMutable])
    }
    
    mutating func shiftRightInPlace(amount: Int = 1) {
        self = shiftRight(amount: amount)
    }
}

extension Date {
    func isInSameWeek(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }
    func isInSameMonth(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
    }
    func isInSameYear(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .year)
    }
    func isInSameDay(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .day)
    }
    var isInThisWeek: Bool {
        return isInSameWeek(date: Date())
    }
    var isInToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    var isInTheFuture: Bool {
        return Date() < self
    }
    var isInThePast: Bool {
        return self < Date()
    }
    static var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date().noon)!
    }
    static var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date().noon)!
    }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var monthBefore: Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}

func generateRandomPastelColor(withMixedColor mixColor: UIColor?) -> UIColor {
    // Randomly generate number in closure
    let randomColorGenerator = { ()-> CGFloat in
        CGFloat(arc4random() % 256 ) / 256
    }
    
    var red: CGFloat = randomColorGenerator()
    var green: CGFloat = randomColorGenerator()
    var blue: CGFloat = randomColorGenerator()
    
    // Mix the color
    if let mixColor = mixColor {
        var mixRed: CGFloat = 0, mixGreen: CGFloat = 0, mixBlue: CGFloat = 0;
        mixColor.getRed(&mixRed, green: &mixGreen, blue: &mixBlue, alpha: nil)
        
        red = (red + mixRed) / 2;
        green = (green + mixGreen) / 2;
        blue = (blue + mixBlue) / 2;
    }
    
    return UIColor(red: red, green: green, blue: blue, alpha: 1)
}

var loadingSpinner : UIView?

extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = backgroundColor
        
        var loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = spinnerView.center
        loadingView.backgroundColor = UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        ai.center = CGPoint(x: loadingView.frame.size.width/2, y: loadingView.frame.size.height/2)
        loadingView.addSubview(ai)
        spinnerView.addSubview(loadingView)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        loadingSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            loadingSpinner?.removeFromSuperview()
            loadingSpinner = nil
        }
    }
}

public extension UIImageView {
    
    func roundedImage() {
        let layer = self.layer
        layer.masksToBounds = true
        layer.cornerRadius = self.frame.width / 2
        UIGraphicsBeginImageContext(self.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.image = roundedImage
    }
    
}

class Counter {
    var id = 0
    var count = 0
    
    init(id: Int, count: Int){
        self.id = id
        self.count = count
    }
}

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
}

