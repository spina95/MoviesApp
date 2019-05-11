//
//  Histogram.swift
//  Movies
//
//  Created by Andrea Spinazzola on 18/10/2018.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import Foundation
import UIKit
import Charts

class HistogramChart: UIView {
    // Line graph properties
    let barChartView = BarChartView()
    var dataEntry: [BarChartDataEntry] = []
    // chart date
    var workoutDuration = [String]()
    var beatsPerMinute = [String]()
    var delegate: GetChartData! {
        didSet {
            populateData()
            barChartSetup()
        }
    }
    
    func populateData() {
        workoutDuration = delegate.workoutDuration
        beatsPerMinute = delegate.beatsPerMinute
    }
    
    func barChartSetup() {
        // Line chart config
        self.backgroundColor = UIColor.white
        self.addSubview(barChartView)
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        barChartView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        barChartView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        barChartView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        barChartView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        // Line chart animation
        barChartView.animate(xAxisDuration: 0.0, yAxisDuration: 0.0, easingOption: .easeInSine)
        
    }
    
    func setBarChart(dataPoints: [String], values: [String]) {
        barChartView.noDataTextColor = UIColor.white
        barChartView.noDataText = "No data for the chart"
        barChartView.backgroundColor = UIColor.white
        
        dataEntry.removeAll()
        for i in 0...dataPoints.count-1 {
            let dataPoint = BarChartDataEntry(x: Double(i), y: Double(values[i])!)
            dataEntry.append(dataPoint)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntry, label: "BPM")
        let chartData = BarChartData()
        chartData.addDataSet(chartDataSet)
        chartData.setDrawValues(false)
        var colors = [UIColor]()
        for i in 0...dataEntry.count - 1 {
            if(i == 0) {
                colors.append(mainColor)
            }
            else {
                colors.append(UIColor.lightGray)
            }
        }
        chartDataSet.colors = colors
        chartData.barWidth = 0.25
        chartData.highlightEnabled = false
        
        let formatter: ChartFormatter = ChartFormatter()
        formatter.setValues(values: dataPoints)
        let xaxis: XAxis = XAxis()
        xaxis.valueFormatter = formatter
        barChartView.sizeToFit()
        barChartView.highlightPerTapEnabled = false
        barChartView.scaleXEnabled = false
        barChartView.scaleYEnabled = false
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.granularityEnabled = true
        barChartView.xAxis.valueFormatter = xaxis.valueFormatter
        barChartView.xAxis.axisLineWidth = 1.5
        barChartView.xAxis.axisLineColor = UIColor.darkGray
        barChartView.legend.enabled = false
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.drawGridLinesEnabled = true
        barChartView.leftAxis.drawLabelsEnabled = true
        barChartView.leftAxis.granularityEnabled = true
        barChartView.leftAxis.granularity = 1.0
        let numberFormatter = NumberFormatter()
        numberFormatter.generatesDecimalNumbers = false
        barChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter.init(formatter: numberFormatter)

        barChartView.data = chartData
        
    }
}
