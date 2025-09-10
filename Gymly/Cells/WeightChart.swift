//
//  WeightChart.swift
//  Gymly
//
//  Created by Sebastián Kučera on 26.03.2025.
//

import SwiftUI
import Charts
import SwiftData

struct WeightChart: View {
    @EnvironmentObject var config: Config
    @Query(sort: \WeightPoint.date, order: .forward) var weightPoints: [WeightPoint]
    var body: some View {
        Chart {
            ForEach(weightPoints) { weightPoint in
                LineMark(
                    x: .value("Date", weightPoint.date),
                    y: .value("Weight", weightPoint.weight * (config.weightUnit == "Kg" ? 1.0 : 2.20462))
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.red)
                .symbol {
                    Circle()
                        .fill(.red)
                        .frame(width: 10, height: 10)
                }

                PointMark(
                    x: .value("Date", weightPoint.date),
                    y: .value("Weight", weightPoint.weight * (config.weightUnit == "Kg" ? 1.0 : 2.20462))
                )
                .annotation(position: .top) {
                    Text(String(format: "%.1f", weightPoint.weight * (config.weightUnit == "Kg" ? 1.0 : 2.20462)))
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .chartYScale(domain: config.userWeight * (config.weightUnit == "Kg" ? 1.0 : 2.20462)-10...config.userWeight * (config.weightUnit == "Kg" ? 1.0 : 2.20462)+10)
        .preferredColorScheme(.dark)
        .frame(width: 300, height: 150)
    }
}

