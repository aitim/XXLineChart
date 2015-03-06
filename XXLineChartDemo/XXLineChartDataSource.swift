//
//  XXLineChartDataSource.swift
//  XXLineChartDemo
//
//  Created by xin.xin on 3/2/15.
//  Copyright (c) 2015 aitim. All rights reserved.
//

import Foundation
import UIKit

protocol XXLineChartDataSource{
    func lineChart(chart:XXLineChart,lineIndex:Int,pointIndex:Int)->(CGFloat,CGFloat)
    
    
}