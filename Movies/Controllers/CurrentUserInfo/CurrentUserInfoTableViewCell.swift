//
//  UserInfoTableViewCell.swift
//  SocialMovie
//
//  Created by Andrea Spinazzola on 15/07/18.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import UIKit
import TMDBSwift
import Charts
import HGCircularSlider

class CurrentUserInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var picture: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var followers: UIButton!
    @IBOutlet weak var following: UIButton!
    @IBOutlet weak var moviesWatchedLabel: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        picture.roundCorners(value: Double(Int(picture.frame.height/2)))
        picture.layer.borderColor = UIColor.white.cgColor
        picture.layer.borderWidth = 3
        picture.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class WatchedMoviesTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewAllButton: UIButton!
    var moviesId: [(Int, Date)]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension WatchedMoviesTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (moviesId != nil) {
            if(moviesId.count < 10) {
                return moviesId.count
            }
            return 10
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "watchedMovieCollectionCell", for: indexPath) as! WatchedMovieCollectionViewCell
        cell.picture.image = #imageLiteral(resourceName: "background")
        cell.userGraph.isHidden = true
        cell.userLabel.isHidden = true
        if(moviesId[indexPath.row] != nil){
            MovieMDB.movie(movieID: moviesId[indexPath.row].0, completion: { (client, movie) in
                if (movie?.poster_path != nil) {
                    cell.picture.downloadImage(path:movie?.poster_path, placeholder: #imageLiteral(resourceName: "background"))
                }
                if let voteAverage = movie?.vote_average {
                    cell.averageLabel.text = String(format: "%.1f", voteAverage)
                    cell.averageGraph.endPointValue = CGFloat(voteAverage)
                }
                if let votes = currentUserFirebase?.votes {
                    for i in votes{
                        if(i.id == movie?.id) {
                            cell.userGraph.endPointValue = CGFloat(i.vote)
                            cell.userLabel.text = String(i.vote)
                            cell.userGraph.isHidden = false
                            cell.userLabel.isHidden = false
                        }
                        
                    }
                }
            })
        }
        cell.tag = indexPath.row        
        return cell
    }
}

class WatchedMovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var averageGraph: CircularSlider!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var userGraph: CircularSlider!
    @IBOutlet weak var userLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.roundCorners(value: 4)
    }
}

extension WatchedMoviesTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 125, height: 188)
    }
}

class MovieStatsTableViewCell: UITableViewCell, GetChartData {
    
    @IBOutlet weak var chart: LineChart!
    @IBOutlet weak var viewYear: UIView!
    @IBOutlet weak var viewMonth: UIView!
    @IBOutlet weak var viewWeek: UIView!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var monthbutton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var months: UILabel!
    @IBOutlet weak var days: UILabel!
    @IBOutlet weak var hours: UILabel!
    @IBOutlet weak var yearTotal: UILabel!
    @IBOutlet weak var monthTotal: UILabel!
    @IBOutlet weak var weekTotal: UILabel!
    
    func getChartData(with dataPoints: [String], values: [String]) {
        self.workoutDuration = dataPoints
        self.beatsPerMinute = values
    }
    
    var workoutDuration: [String] = [String]()
    var beatsPerMinute: [String] = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chart.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

class MoviesWatchedChartCell: UITableViewCell, GetChartData {
    
    @IBOutlet weak var chart: LineChart!
    
    func getChartData(with dataPoints: [String], values: [String]) {
        self.workoutDuration = dataPoints
        self.beatsPerMinute = values
    }
    
    var workoutDuration: [String] = [String]()
    
    var beatsPerMinute: [String] = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chart.delegate = self
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class FriendHistogramCell: UITableViewCell, GetChartData {
    
    @IBOutlet weak var chart: HistogramChart!
    
    func getChartData(with dataPoints: [String], values: [String]) {
        self.workoutDuration = dataPoints
        self.beatsPerMinute = values
    }
    
    var workoutDuration: [String] = [String]()
    var beatsPerMinute: [String] = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chart.delegate = self
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class GenresPieChartCell: UITableViewCell {
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    var movies: [MovieMDB]?
    
    @IBOutlet var colorsView: Array<UIView>!
    @IBOutlet var namesLabels: Array<UILabel>!
    @IBOutlet var valuesLabels: Array<UILabel>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        var sum: Double = 0
        for i in 0...dataPoints.count - 1 {
            let dataEntry1 = PieChartDataEntry(value: Double(values[i]), label: dataPoints[i], data:  dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry1)
            sum = sum + values[i]
        }
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "Units Sold")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
                
        var colors: [UIColor] = [UIColor(red: 255/255, green: 179/255, blue: 186/255, alpha: 1), UIColor(red: 255/255, green: 223/255, blue: 186/255, alpha: 1), UIColor(red: 255/255, green: 255/255, blue: 186/255, alpha: 1), UIColor(red: 186/255, green: 255/255, blue: 201/255, alpha: 1), UIColor(red: 186/255, green: 225/255, blue: 255/255, alpha: 1), UIColor(red: 149/255, green: 125/255, blue: 173/255, alpha: 1)]
        var c = 0
        for s in 0...dataPoints.count - 1 {
            colorsView[c].backgroundColor = colors[s]
            namesLabels[s].text = dataPoints[c]
            valuesLabels[s].text = String(format: "%.0f", values[s] / sum * 100) + "%"
            c = c + 1
        }
        pieChartDataSet.colors = colors
        
        pieChartDataSet.form = .circle
        pieChartDataSet.selectionShift = 0
        
        pieChartView.legend.enabled = false
        pieChartView.drawEntryLabelsEnabled = false
        pieChartView.drawSlicesUnderHoleEnabled = false
        pieChartDataSet.drawValuesEnabled = false
    }
    
}

class ListTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addList: UIButton!
    
    var listArray: [List]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}

extension ListTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if listArray != nil {
            return listArray.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCollectionViewCell", for: indexPath) as! ListCollectionViewCell
        cell.tag = indexPath.row
        cell.title.text = listArray[indexPath.row].name
        
        var count = 0
    
        var counter = 0
        let ids = listArray[indexPath.row].moviesId
        count = ids.count
        for i in ids{
            var check = 0
            for id in (currentUserFirebase?.moviesWatchedId)! {
                if(i == id.id) {
                    check = 1
                }
            }
            if(check == 0) {
                counter = counter + 1
            }
        }
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: String(count) + " movies")
        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: NSRange(location:count.description.count, length:7))
        cell.moviesTot.attributedText = myMutableString
        
        myMutableString = NSMutableAttributedString(string: String(counter) + " to watch")
        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: NSRange(location:counter.description.count, length:9))
        cell.toWatch.attributedText = myMutableString
        
        if(listArray[indexPath.row].shared == false) {
            cell.shared.text = "Private"
        } else {
            cell.shared.text = "Public"
        }
        
        return cell
    }
}

class ListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var moviesTot: UILabel!
    @IBOutlet weak var toWatch: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var shared: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.roundCorners(value: 6)
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowColor = UIColor.gray.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}

extension ListTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 146, height: 160)
    }
}

class GenreCount {
    var id: Int = 0
    var name: String = ""
    var count: Int = 0
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
        self.count = 0
    }
}

class InfoTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

class ActorsStatsTableViewCell: UITableViewCell, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var mainView: UIView!
    
    var user: UserFirebase!
    var actorArray: [PersonMDB]?
    
    var slides:[ActorSlide] = [];
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.delegate = self
        
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        self.bringSubviewToFront(pageControl)
    }
    
    func createSlides() -> [ActorSlide] {
        
        let slide1:ActorSlide = Bundle.main.loadNibNamed("ActorSlide", owner: self, options: nil)?.first as! ActorSlide
        slide1.titleSlide.text = "Actors"
        
        let slide2:ActorSlide = Bundle.main.loadNibNamed("ActorSlide", owner: self, options: nil)?.first as! ActorSlide
        slide2.titleSlide.text = "Actress"
        
        let slide3:ActorSlide = Bundle.main.loadNibNamed("ActorSlide", owner: self, options: nil)?.first as! ActorSlide
        slide3.titleSlide.text = "Directors"
        
        
        
        return [slide1, slide2, slide3]
        
    }
    
    func setupSlideScrollView(slides : [ActorSlide]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 180)
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(slides.count), height: 180)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: UIScreen.main.bounds.width * CGFloat(i), y: 0, width: UIScreen.main.bounds.width, height: 180)
            scrollView.addSubview(slides[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/UIScreen.main.bounds.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

class ActorSlide: UIView {
    
    @IBOutlet weak var picture1: UIImageView!
    @IBOutlet weak var picture2: UIImageView!
    @IBOutlet weak var picture3: UIImageView!
    @IBOutlet weak var titleSlide: UILabel!
    @IBOutlet weak var name1: UILabel!
    @IBOutlet weak var name2: UILabel!
    @IBOutlet weak var name3: UILabel!
    @IBOutlet weak var count1: UILabel!
    @IBOutlet weak var count2: UILabel!
    @IBOutlet weak var count3: UILabel!
    
    override func awakeFromNib() {
        picture1.roundCorners(value: Double(picture1.frame.height/2))
        picture2.roundCorners(value: Double(picture2.frame.height/2))

        picture3.roundCorners(value: Double(picture3.frame.height/2))

        
    }
}

class PrivateTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}
