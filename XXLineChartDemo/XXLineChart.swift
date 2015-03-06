//
//  XXLineChart.swift
//  XXLineChartDemo
//
//  Created by xin.xin on 3/2/15.
//  Copyright (c) 2015 aitim. All rights reserved.
//

import UIKit

class XXLineChart: UIView {
    var delegate:XXLineChartDelegate?
    var dataSource:XXLineChartDataSource?
    
    var lineWidth:CGFloat = 0.5 //线条宽度
    var gridLineWidth:CGFloat = 0.5 //网格线条宽度
    var axisLineWidth:CGFloat = 0.5 //坐标轴线条宽度
    var margin:CGFloat = 10
    var axisColor:UIColor = UIColor(white: 0.7, alpha: 1.0) //坐标轴的颜色
    var showGrid:Bool = true //是否显示网格
    var bezierSmoothing = true //贝塞尔曲线是否平滑
    var bezierSmootingTension:CGFloat = 0.2 //贝塞尔曲线拉伸度
    var animationDuration:CGFloat = 0.5
    
    var displayDataPoint:Bool = false //是否显示数据点
    var dataPointRadius:CGFloat?
    var dataPointColor:UIColor?
    
    var fillColor:UIColor?  //填充颜色
    var gridLineColor:UIColor = UIColor(white: 0.9, alpha: 1.0 ) //网格线颜色
    var color:UIColor = UIColor.xxOrange()
    
    //label attributes
    var xAxisLabelBackgroundColor:UIColor = UIColor.clearColor()
    var xAxisLabelTextColor:UIColor = UIColor.grayColor()
    var xAxisLabelFont:UIFont = UIFont.systemFontOfSize(10)
    
    var yAxisLabelBackgroundColor:UIColor = UIColor.clearColor()
    var yAxisLabelTextColor:UIColor = UIColor.grayColor()
    var yAxisLabelFont:UIFont = UIFont.systemFontOfSize(10)
    
    private var minY:CGFloat = CGFloat.max //y轴最小值
    private var maxY:CGFloat = CGFloat.min //y轴最大值
    private var minX:CGFloat = CGFloat.max //x轴最小值
    private var maxX:CGFloat = CGFloat.min //x轴最大值
    private var scale:CGFloat = 0
    private var axisWidth:CGFloat = 0 //x轴长度
    private var axisHeight:CGFloat = 0 //y轴高度
    private var horizontalGridStep:Int = 0 //纵向网格数
    private var verticalGridStep:Int = 0    //横向网格数
    private var lineCount:Int = 0 //线条数量
    private var layers:[CALayer] = []
    private var labels:[UILabel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initParameters()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initParameters()
    }
    
    private func initParameters(){
        self.clearsContextBeforeDrawing = true
        self.backgroundColor = UIColor.whiteColor()
        self.axisWidth = self.frame.width - self.margin * 2
        self.axisHeight = self.frame.height - self.margin * 2
    }
    
    func strokeChart(){
        if let dl = self.delegate{
            self.horizontalGridStep = dl.numberOfXAixs(self)
            self.verticalGridStep = dl.numberOfYAxis(self)
            self.lineCount = dl.numberOfLines(self)
            
            self.computeValueBounds() //计算最大值与最小值
            self.drawScale() //画出x轴与y轴刻度
            
            for i in 0..<self.lineCount{
                self.drawLine(i) //绘曲线
            }
        }
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        if let dl = self.delegate{
            if self.lineCount > 0{
                self.drawGrid()
            }
        }
    }
    
    //计算出所有线条中的最大最小值
    private func computeValueBounds(){
        if let delegate = self.delegate{
            var lineCount:Int = delegate.numberOfLines(self)
            for i in 0..<lineCount{
                var pointCount = delegate.numberOfPointsInLine(self, lineIndex: i)
                
                if let ds = self.dataSource{
                    for j in 0..<pointCount{
                        var (x,y) = ds.lineChart(self, lineIndex: i, pointIndex: j)
                        
                        if self.minY > y{
                            self.minY = y
                        }
                        if self.maxY < y{
                            self.maxY = y
                        }
                        
                        if self.minX > x {
                            self.minX = x
                        }
                        if self.maxX < x {
                            self.maxX = x
                        }
                    }
                }
            }
            
            var step = ceil((self.maxY-self.minY)/CGFloat(self.verticalGridStep))
            self.maxY = self.minY + CGFloat(step)*CGFloat(self.verticalGridStep)
            
            step = ceil((self.maxX - self.minX)/CGFloat(self.horizontalGridStep))
            self.maxX = self.minX + CGFloat(step)*CGFloat(self.horizontalGridStep)
       
            if self.minY < 0{
                //TODO: If the minimum is negative then we want to have one of the step to be zero so that the chart is displayed nicely and more comprehensively
                
            }
            
            if self.minX < 0 {
                //TODO:If the minimum is negative then we want to have one of the step to be zero so that the chart is displayed nicely and more comprehensively
                
            }
        }
        
    }
    
    //绘制网格线
    private func drawGrid(){
        var context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, self.gridLineWidth)
        CGContextSetStrokeColorWithColor(context, self.axisColor.CGColor)
        
        CGContextMoveToPoint(context, self.margin, self.margin)
        CGContextAddLineToPoint(context, self.margin, self.axisHeight + self.margin + 3)
        CGContextStrokePath(context)
        
        if self.showGrid{
            //draw vertical grid line
            for i in 0..<self.horizontalGridStep{
                CGContextSetStrokeColorWithColor(context, self.gridLineColor.CGColor)
                CGContextSetLineWidth(context, self.gridLineWidth)
                
                var point = CGPointMake(CGFloat(i+1)*self.axisWidth/CGFloat(self.horizontalGridStep) + self.margin, self.margin)
                
                CGContextMoveToPoint(context, point.x, point.y)
                CGContextAddLineToPoint(context, point.x, self.axisHeight + self.margin + 3)
                CGContextStrokePath(context)
            }
            
            //draw horizontal grid line
            for i in 0...self.verticalGridStep{
                if i == self.verticalGridStep{
                    CGContextSetStrokeColorWithColor(context, self.axisColor.CGColor)
                    CGContextSetLineWidth(context, self.gridLineWidth)
                }else{
                    CGContextSetStrokeColorWithColor(context, self.gridLineColor.CGColor)
                    CGContextSetLineWidth(context, self.gridLineWidth)
                }
                var point = CGPointMake(self.margin, CGFloat(i) * self.axisHeight / CGFloat(self.verticalGridStep) + self.margin)
                
                CGContextMoveToPoint(context, point.x, point.y)
                CGContextAddLineToPoint(context, self.axisWidth + self.margin, point.y)
                CGContextStrokePath(context)
            }
        }
        
    }
    //绘制刻度
    private func drawScale(){
        for i in 0..<self.labels.count{
            self.labels[i].removeFromSuperview()
        }
        self.labels = []
        
        //x轴刻度
        var step = ceil((self.maxX - self.minX)/CGFloat(self.horizontalGridStep))
        for i in 0..<self.horizontalGridStep + 1{
            var text = self.delegate!.labelForXAixs(self, item: self.minX + CGFloat(i)*step)
            var rect = CGRectMake(self.margin, self.axisHeight+self.margin, self.axisWidth - self.margin*2, 20)
            var size = NSString(string: text).boundingRectWithSize(rect.size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:self.xAxisLabelFont], context: nil).size
            
            var centerPoint = CGPointMake(CGFloat(i)*self.axisWidth/CGFloat(self.horizontalGridStep) + self.margin, self.axisHeight + self.margin + 3)
            
            var label = UILabel(frame: CGRectMake(centerPoint.x - size.width/2, centerPoint.y, size.width, size.height ))
            label.text = text
            label.font = self.xAxisLabelFont
            label.textColor = self.xAxisLabelTextColor
            label.textAlignment = .Center
            label.backgroundColor = UIColor.clearColor()
            self.addSubview(label)
            self.labels.append(label)
        }
        
        //y轴刻度
        step = ceil((self.maxY - self.minY)/CGFloat(self.verticalGridStep))
        for i in 0..<self.verticalGridStep+1{
            var text = self.delegate!.labelForYAixs(self, item: self.minY + CGFloat(i)*step)
            var rect = CGRectMake(0, self.margin, self.axisWidth, 20)
            var size = NSString(string: text).boundingRectWithSize(rect.size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:self.yAxisLabelFont], context: nil).size
            
            var centerPoint = CGPointMake(self.margin - size.width - 3, self.axisHeight + self.margin - CGFloat(i)*self.axisHeight/CGFloat(self.verticalGridStep) - size.height/2)
            
            var label = UILabel(frame: CGRectMake(centerPoint.x, centerPoint.y, size.width, size.height))
            label.text = text
            label.font = self.yAxisLabelFont
            label.textColor = self.yAxisLabelTextColor
            label.textAlignment = .Center
            label.backgroundColor = UIColor.clearColor()
            self.addSubview(label)
            self.labels.append(label)
        }
    }
    //绘制曲线
    private func drawLine(index:Int){
        //清空旧图
        for i in 0..<self.layers.count{
            self.layers[i].removeFromSuperlayer()
        }
        self.layers = []
        
        if let dl = self.delegate{
            //读取所有数据点
            var pointCount = dl.numberOfPointsInLine(self, lineIndex: index)
            var points:[CGPoint] = []
            for i in 0..<pointCount{
                if let ds = self.dataSource{
                    var (x,y) = ds.lineChart(self, lineIndex: index, pointIndex: i)
                    
                    var point = self.getPoint(x, yValue: y)
                    points.append(point)
                }
            }
            //开始绘制
            if points.count > 0{
                var pathLayer = CAShapeLayer()
                pathLayer.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
                pathLayer.path = self.getLinePath(points, smooth: true, closed: false).CGPath
                pathLayer.strokeColor = self.color.CGColor
                pathLayer.fillColor = nil
                pathLayer.lineWidth = self.lineWidth
                pathLayer.lineJoin = kCALineJoinRound
                
                self.layer.addSublayer(pathLayer)
                self.layers.append(pathLayer)
                
                var pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
                pathAnimation.duration = CFTimeInterval( self.animationDuration)
                pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                pathAnimation.fromValue = 0
                pathAnimation.toValue = 1
                pathLayer.addAnimation(pathAnimation, forKey: "path")
            }
        }
    }
    
    private func getPoint(xValue:CGFloat,yValue:CGFloat)->CGPoint{
        //x轴位置
        var value = self.maxX - self.minX
        var x:CGFloat = self.axisWidth * (xValue-self.minX) / value + self.margin
        
        
        //y轴位置
        value = self.maxY - self.minY
        var y:CGFloat = (self.margin + self.axisHeight) - self.axisHeight * (yValue-self.minY) / value
        
        NSLog("value:\(xValue,yValue) position:\(x) \(y)")
        
        return CGPointMake(x, y)
    }
    
    private func getLinePath(points:[CGPoint],smooth:Bool,closed:Bool)->UIBezierPath{
        var path = UIBezierPath()
        if smooth{
            for i in 0..<points.count-1{
                var p = points[i]
                
                if i == 0 {
                    path.moveToPoint(p)
                }
                
                //the first control point
                var m:CGPoint = CGPointZero
                
                if i > 0{
                    m.x = (points[i+1].x - points[i-1].x)/2
                    m.y = (points[i+1].y - points[i-1].y)
                }else{
                    m.x = (points[i+1].x - points[i].x)/2
                    m.y = (points[i+1].y - points[i].y)
                }
                
                var firstControlPoint = CGPointMake(points[i].x + m.x * self.bezierSmootingTension
                    , points[i].y + m.y * self.bezierSmootingTension)
                
                m = CGPointZero
                if i < points.count - 2{
                    m.x = (points[i+2].x - points[i].x)/2
                    m.y = (points[i+2].y - points[i].y)/2
                }else{
                    m.x = (points[i+1].x - points[i].x)/2
                    m.y = (points[i+1].x - points[i].x)/2
                }
                
                var secondControlPoint = CGPointMake(points[i+1].x - m.x * self.bezierSmootingTension, points[i+1].y - m.y * self.bezierSmootingTension)
                
                path.addCurveToPoint(points[i+1], controlPoint1: firstControlPoint, controlPoint2: secondControlPoint)
            }
        }else{
            for i in 0..<points.count{
                if i > 0{
                    path.addLineToPoint(points[i])
                }else{
                    path.moveToPoint(points[i])
                }
            }
        }
        
        if closed{
            //TODO: close the path
        }
        return path
    }
}
