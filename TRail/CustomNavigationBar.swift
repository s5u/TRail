//
//  CustomNavigationBar.swift
//  TRail
//
//  Created by 清水 佑樹 on 2015/11/14.
//  Copyright © 2015年 yuki shimizu. All rights reserved.
//

import UIKit

class CustomNavigationBar: UINavigationBar {

    var subTitleLabel:  UILabel?
    var targetButton: UIBarButtonItem?
    var taskButton: UIBarButtonItem?
    var todoButton: UIBarButtonItem?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createSubTitle()
        createTargetButton()
//        createTaskButton()
//        createTodoButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSubTitle()
        layoutTargetButton()
//        layoutTaskButton()
//        layoutTodoButton()
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        var barSize = super.sizeThatFits(size)
        barSize.height += 30
        return barSize
    }
    
    func createSubTitle() {
        subTitleLabel = UILabel()
        subTitleLabel!.text = "piyopiyo"
        self.addSubview(subTitleLabel!)
    }
    
    func layoutSubTitle() {
        subTitleLabel!.sizeToFit()
        subTitleLabel!.center = self.center
        subTitleLabel!.center.y = 20
    }
    
    //TargetButton
    func createTargetButton() {
        targetButton = UIBarButtonItem()
        targetButton?.title = "Target"
        targetButton?.tintColor = UIColor.blueColor()
    }
    
    func layoutTargetButton() {

        
    }
    
    //TaskButton
    func createTaskButton() {
        
    }
    
    func layoutTaskButton() {
        
    }
    
    //TodoButton
    func createTodoButton() {
        
    }
    
    func layoutTodoButton() {
        
    }

}
