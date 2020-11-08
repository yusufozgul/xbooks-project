//
//  SummaryReportView.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 6.11.2020.
//

import UIKit
import Charts

class SummaryReportView: UICollectionViewCell {
    static let reuseIdentifier: String = "SummaryReportView"
    @IBOutlet weak var chartView: LineChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
        chartView.delegate = self
        
        chartView.xAxis.enabled = false
        
        let yAxis = chartView.leftAxis
        yAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size:12)!
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .white
        yAxis.labelPosition = .insideChart
        yAxis.axisLineColor = .white
        
        chartView.xAxis.enabled = false
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        
        chartView.animate(xAxisDuration: 2, yAxisDuration: 2)
    }
    
    func setData(data: SummaryReportDataModel) {
        
        let dateFormatter = DateFormatter()
        
        let dailyMinutes: [ChartDataEntry] = data.data.map({ (value) -> ChartDataEntry in
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            let date = dateFormatter.date(from: value.date)
            dateFormatter.dateFormat = "dd"
            return ChartDataEntry(x: Double(dateFormatter.string(from: date!)) ?? 0, y: Double(value.point))
        })
        
        
        
        
        let set1 = LineChartDataSet(entries: dailyMinutes, label: "")
        set1.mode = .cubicBezier
        set1.drawCirclesEnabled = false
        set1.lineWidth = 1.8
        set1.fillColor = .white
        set1.fillAlpha = 1
        set1.drawHorizontalHighlightIndicatorEnabled = true
        
        let data = LineChartData(dataSet: set1)
        chartView.data = data
    }
}

extension SummaryReportView: ChartViewDelegate {
    
}
