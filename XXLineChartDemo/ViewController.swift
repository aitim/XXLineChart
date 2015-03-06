//
//  ViewController.swift
//  XXLineChartDemo
//
//  Created by xin.xin on 3/2/15.
//  Copyright (c) 2015 aitim. All rights reserved.
//

import UIKit

class ViewController: UIViewController,XXLineChartDelegate,XXLineChartDataSource {
    var chart:XXLineChart?
    
    private var data:[(CGFloat,CGFloat)] = [(3,8),(4,5),(7,9),(8,12)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        chart = XXLineChart(frame: CGRectMake(20, 40, self.view.bounds.width - 40, 166))
        chart?.delegate = self
        chart?.dataSource = self
        
        self.view.addSubview(chart!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnClicked(sender: UIButton) {
        chart?.strokeChart()
    }
    /******* XXLineChart *******/
    func labelForXAixs(lineChart: XXLineChart, item: CGFloat) -> String {
        return Int(item).description
    }
    
    func labelForYAixs(lineChart: XXLineChart, item: CGFloat) -> String {
        return Int(item).description
    }
    
    func numberOfLines(chart: XXLineChart) -> Int {
        return 1
    }
    
    func numberOfXAixs(chart: XXLineChart) -> Int {
        return 6
    }
    
    func numberOfYAxis(chart: XXLineChart) -> Int {
        return 5
    }
    
    func numberOfPointsInLine(chart: XXLineChart, lineIndex: Int) -> Int {
        return 4
    }
    
    func lineChart(chart: XXLineChart, lineIndex: Int, pointIndex: Int) -> (CGFloat,CGFloat) {
        return data[pointIndex]
    }
}

