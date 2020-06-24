//
//  DrawView.swift
//  Draw it
//
//  Created by Hanoudi on 4/26/20.
//  Copyright © 2020 Hans. All rights reserved.
//  Custom View

import UIKit

class DrawView: UIView {
    // MARK: - Variables
    // Optional line to keep track of line that is possibly being drawn
    // Array of lines to keep track if lines that were drawn
    var currentLine: Line?
    var finishedLines = [Line]()
    
    // MARK: - DrawView Methods
    // Stroke() draws a line along the receivers path using current drawing properties
    func stroke(_ line: Line) {
        let path = UIBezierPath()
        path.lineWidth = 10
        path.lineCapStyle = .round
        
        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
    }
    
    override func draw(_ rect: CGRect) {
        // Draw finished lines in black
        UIColor.black.setStroke()
        for line in finishedLines {
            stroke(line)
        }
        if let line = currentLine {
            // If there is aline currently begin drawn, do it in red
            UIColor.red.setStroke()
            stroke(line)
        }
    }
    // When touch begins you create a line and set both of it properties where the line began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // First figure out location of touch within views coordinate system
        // setNeedsDisplay() flags the view to be redrawn at the end of the run loop
        let touch = touches.first
        
        // Get location of the touch in view's cooridinate
        let location = touch?.location(in: self)
        
        currentLine = Line(begin: location!, end: location!)
        
        setNeedsDisplay()
    }
    
    // When the touch moves, update lines end
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        currentLine?.end = location
        
        setNeedsDisplay()
    }
    
    // When the touch ends, you draw your line
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if var line = currentLine {
            let touch = touches.first!
            let location = touch.location(in: self)
            line.end = location
            
            finishedLines.append(line)
        }
        currentLine = nil
        
        setNeedsDisplay()
    }
}
