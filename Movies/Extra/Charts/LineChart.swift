//
//  LineChart.swift
//  Movies
//
//  Created by Andrea Spinazzola on 16/10/2018.
//  Copyright © 2018 Andrea Spinazzola. All rights reserved.
//

import Foundation
import UIKit
import Charts

class LineChart: UIView {
    // Line graph properties
    let lineChartView = LineChartView()
    var lineDataEntry: [ChartDataEntry] = []
    // chart date
    var workoutDuration = [String]()
    var beatsPerMinute = [String]()
    var delegate: GetChartData! {
        didSet {
            populateData()
            lineChartSetup()
        }
    }

    func populateData() {
        workoutDuration = delegate.workoutDuration
        beatsPerMinute = delegate.beatsPerMinute
    }

    func lineChartSetup() {
        // Line chart config
        backgroundColor = UIColor.white
        addSubview(lineChartView)
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        lineChartView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        lineChartView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        lineChartView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        lineChartView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        // Line chart animation
        lineChartView.animate(xAxisDuration: 0.0, yAxisDuration: 0.0, easingOption: .easeInSine)
        
    }
    
    func setLineChart(dataPoints: [String], values: [String]) {
        lineChartView.noDataTextColor = UIColor.white
        lineChartView.noDataText = "No data for the chart"
        lineChartView.backgroundColor = UIColor.white
        
        let count = dataPoints.count
        lineDataEntry.removeAll()
        for i in 0...dataPoints.count-1 {
            let dataPoint = ChartDataEntry(x: Double(i), y: Double(values[i])!)
            lineDataEntry.append(dataPoint)
        }
        
        let chartDataSet = LineChartDataSet(values: lineDataEntry, label: "BPM")
        let chartData = LineChartData()
        chartData.addDataSet(chartDataSet)
        chartData.setDrawValues(true)
        chartDataSet.colors = [mainColor]
        chartDataSet.setCircleColor(mainColor)
        chartDataSet.circleHoleColor = mainColor
        chartDataSet.circleRadius = 4.0
        chartDataSet.drawValuesEnabled = false
        chartDataSet.fillColor = mainColor
        chartDataSet.drawFilledEnabled = true
        chartDataSet.highlightEnabled = false
        
        let formatter: ChartFormatter = ChartFormatter()
        formatter.setValues(values: dataPoints)
        let xaxis: XAxis = XAxis()
        xaxis.valueFormatter = formatter
        lineChartView.fitScreen()
        lineChartView.highlightPerTapEnabled = false
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.drawLabelsEnabled = true
        lineChartView.xAxis.valueFormatter = xaxis.valueFormatter
        lineChartView.xAxis.axisLineWidth = 1.5
        lineChartView.xAxis.setLabelCount(dataPoints.count, force: true)
        lineChartView.xAxis.axisLineColor = UIColor.darkGray
        lineChartView.xAxis.gridColor = UIColor.lightGray
        lineChartView.chartDescription?.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = true
        lineChartView.leftAxis.drawLabelsEnabled = true
        lineChartView.leftAxis.granularityEnabled = true
        lineChartView.leftAxis.granularity = 1.0
        lineChartView.leftAxis.gridColor = UIColor.lightGray
        lineChartView.data = chartData
        setNeedsDisplay()
    }
}

public class ChartFormatter: NSObject, IAxisValueFormatter {
    var workoutDuration = [String]()
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return workoutDuration[Int(value) % workoutDuration.count]
    }
    
    public func setValues(values: [String]) {
        self.workoutDuration = values
    }
}

protocol GetChartData {
    func getChartData(with dataPoints: [String], values: [String])
    var workoutDuration: [String] {get set}
    var beatsPerMinute: [String] {get set}
}
