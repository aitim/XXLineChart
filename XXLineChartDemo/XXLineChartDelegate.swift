//
//  XXLineChartDelegate.swift
//  XXLineChartDemo
//
//  Created by xin.xin on 3/2/15.
//  Copyright (c) 2015 aitim. All rights reserved.
//

import Foundation
import UIKit

protocol XXLineChartDelegate{
    func labelForXAixs(lineChart:XXLineChart,item:CGFloat) ->String //生成X轴坐标值
    func labelForYAixs(lineChart:XXLineChart,item:CGFloat) ->String //生成Y轴坐标值
    func numberOfXAixs(chart:XXLineChart)->Int //x轴坐标个数
    func numberOfYAxis(chart:XXLineChart)->Int //y轴坐标个数
    func numberOfLines(chart:XXLineChart)->Int //曲线个数
    func numberOfPointsInLine(chart:XXLineChart,lineIndex:Int)->Int //某一条曲线上点数
    
}