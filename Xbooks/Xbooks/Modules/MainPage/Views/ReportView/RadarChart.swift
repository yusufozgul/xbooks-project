//
//  RadarChart.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 8.11.2020.
//

import UIKit
import Charts

class RadarChart: UICollectionViewCell {
    static let reuseIdentifier: String = "RadarChart"
    @IBOutlet weak var chart: RadarChartView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(data: SummaryReportDataModel) {
        let mult: UInt32 = 80
        let min: UInt32 = 20
        let cnt = 5
        
        let block: (Int) -> RadarChartDataEntry = { _ in return RadarChartDataEntry(value: Double(arc4random_uniform(mult) + min))}
        let entries1 = (0..<cnt).map(block)
        
        
        
        let set1 = RadarChartDataSet(entries: entries1, label: "Okuma - Süre")
        set1.setColor(UIColor(red: 103/255, green: 110/255, blue: 129/255, alpha: 1))
        set1.fillColor = UIColor(red: 103/255, green: 110/255, blue: 129/255, alpha: 1)
        set1.drawFilledEnabled = true
        set1.fillAlpha = 0.7
        set1.lineWidth = 2
        set1.drawHighlightCircleEnabled = true
        set1.setDrawHighlightIndicators(false)
        
        let data: RadarChartData = RadarChartData(dataSet: set1)
        data.setValueFont(.systemFont(ofSize: 8, weight: .light))
        data.setDrawValues(false)
        data.setValueTextColor(.white)
        chart.data = data
    }

}
