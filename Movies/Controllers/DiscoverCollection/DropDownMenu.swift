//
//  DropDownMenu.swift
//  Movies
//
//  Created by Andrea Spinazzola on 03/05/2019.
//  Copyright © 2019 Andrea Spinazzola. All rights reserved.
//

import UIKit
import BottomPopup
import TMDBSwift

class DropDownMenu: BottomPopupViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let collectionViewHeaderFooterReuseIdentifier = "MyHeaderFooterClass"
    
    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    
    var mode = String()
    var save = false
    
    var genresIndex = [Int]()
    
    var yearsIndex = [Int]()
    var tap = 0
    
    var votes = [Int]()
    var country = [String]()
    var cast = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(MyHeaderFooterClass.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: collectionViewHeaderFooterReuseIdentifier)
        
        switch mode {
        case "Genre":
            titleLabel.text = "Choose Genres"
        case "Years":
            titleLabel.text = "Choose Years"
        case "Vote":
            titleLabel.text = "Choose votes"
        default:
            break
        }
        
    }
    
    @IBAction func save(_ sender: Any) {
        save = true
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func getPopupHeight() -> CGFloat {
        return height ?? CGFloat(300)
    }
    
    override func getPopupTopCornerRadius() -> CGFloat {
        return topCornerRadius ?? CGFloat(10)
    }
    
    override func getPopupPresentDuration() -> Double {
        return presentDuration ?? 1.0
    }
    
    override func getPopupDismissDuration() -> Double {
        return dismissDuration ?? 1.0
    }
    
    override func shouldPopupDismissInteractivelty() -> Bool {
        return shouldDismissInteractivelty ?? true
    }
}

extension DropDownMenu: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if(mode == "Genre") {
            return 1
        }
        if(mode == "Years") {
            return 2
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(mode == "Genre") {
            return getGenresList().count
        }
        if(mode == "Years") {
            if(section == 0) {
                return 10
            }
            if(section == 1) {
                return getYearsList().count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        if(mode == "Years"){
            return CGSize(width: collectionView.bounds.width, height: 60)
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: collectionViewHeaderFooterReuseIdentifier, for: indexPath)
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            label.textAlignment = .left
            if(indexPath.section == 0) {
                label.text = "Decades"
            }
            if(indexPath.section == 1) {
                label.text = "Years"
            }
            label.font = UIFont.systemFont(ofSize: 19, weight: .medium)
            label.textColor = UIColor.lightGray
            label.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(label)
            label.heightAnchor.constraint(equalToConstant: 20).isActive = true
            label.leadingAnchor.constraint(equalToSystemSpacingAfter: headerView.safeAreaLayoutGuide.leadingAnchor, multiplier: 0).isActive = true
            label.bottomAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
            headerView.backgroundColor = UIColor.white
            return headerView
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: collectionViewHeaderFooterReuseIdentifier, for: indexPath)
            
            footerView.backgroundColor = UIColor.green
            return footerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(mode == "Genre") {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dropDown", for: indexPath) as! DropDownMenuCollectionViewCell
            cell.label.text = getGenresList()[indexPath.row]
            if(genresIndex[indexPath.row] == 0) {
                cell.setUnselected()
            }
            if(genresIndex[indexPath.row] == 1) {
                cell.setSelected()
            }
            return cell
        }
        if(mode == "Years") {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dropDown", for: indexPath) as! DropDownMenuCollectionViewCell
            if(indexPath.section == 0){
                var decade = 2010
                cell.label.text = String(decade - indexPath.row*10) + "'s"
            }
            if(indexPath.section == 1){
                cell.label.text = String(getYearsList()[getYearsList().count - indexPath.row - 1])
                if(yearsIndex[indexPath.row] == 0) {
                    cell.setUnselected()
                }
                if(yearsIndex[indexPath.row] == 1) {
                    cell.setSelected()
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(mode == "Genre") {
            var cell = collectionView.cellForItem(at: indexPath) as! DropDownMenuCollectionViewCell
            if(genresIndex[indexPath.row] == 0){
                genresIndex[indexPath.row] = 1
                cell.setSelected()
            } else {
                genresIndex[indexPath.row] = 0
                cell.setUnselected()
            }
        }
        if(mode == "Years") {
            var cell = collectionView.cellForItem(at: indexPath) as! DropDownMenuCollectionViewCell
            var startIndex = -1
            var endIndex = -1
            
            for (i, value) in yearsIndex.enumerated(){
                if(value == 1 && endIndex == -1) {
                    startIndex = i
                }
                if(startIndex != -1 && value == 1){
                    endIndex = i
                }
            }
            
            if(tap == 0) {
                startIndex = indexPath.row
                tap = 1
            }
            else if(tap == 1) {
                endIndex = indexPath.row
                tap = 0
            }
            if(endIndex == -1) {
                yearsIndex[startIndex] = 1
            } else {
                for (i, value) in yearsIndex.enumerated(){
                    if(i >= startIndex && i <= endIndex){
                        yearsIndex[i] = 1
                        let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 1)) as! DropDownMenuCollectionViewCell
                        cell.setSelected()
                    } else {
                        yearsIndex[i] = 0
                        let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 1)) as! DropDownMenuCollectionViewCell
                        cell.setUnselected()
                    }
                }
            }
        }
    }
}

extension DropDownMenu: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(mode == "Genre") {
            let label = UILabel(frame: CGRect.zero)
            label.text = "  " + getGenresList()[indexPath.row] + "  "
            label.sizeToFit()
            return CGSize(width: label.frame.width, height: 50)
        }
        if(mode == "Years") {
            let label = UILabel(frame: CGRect.zero)
            label.text = "  " + String(getYearsList()[indexPath.row]) + "  "
            label.sizeToFit()
            var numberCellForLine = 5
            return CGSize(width: (UIScreen.main.bounds.width - 16 - 4*4) / 5, height: 35)
        }
        return CGSize(width: 0, height: 0)
    }
    
}

class DropDownMenuCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.roundCorners(value: Double(label.frame.height/2))
    }
    
    func setUnselected() {
        label.backgroundColor = .clear
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.darkText.cgColor
        label.textColor = UIColor.darkText
    }
    
    func setSelected() {
        label.backgroundColor = greenColor
        label.layer.borderWidth = 0
        label.textColor = UIColor.white
    }
}

class MyHeaderFooterClass: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.purple
        
        // Customize here
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
}
