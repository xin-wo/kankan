//
//  SKScNavBar.swift
//  SCNavController
//
//  Created by Xin on 16/10/30.
//  Copyright © 2016年 王鑫. All rights reserved.
//

import UIKit


protocol XScNavBarDelegate: NSObjectProtocol{
    /**
     * 点击ScNavBar上的Items回调的方法
     * @param index 被点击的Item的下标
     */
    func didSelectedWithIndex(index:Int)
    
    /**
     * 点击扩展菜单键触发的方法
     */
    func isShowScNavBarItemMenu(show:Bool, height:CGFloat)
}

class XScNavBar: UIView, XLaunchMenuDelegate {
    
    //MARK: -- 公共属性
    /**
     * SKScnavBarDelegate的代理属性
     */
    weak var delegate: XScNavBarDelegate?
    
    /**
     * 当前选中的Item的下标
     */
    var currentItemIndex:Int!
    /**
     * 所有Items的标题
     */
    var itemsTitles:NSArray!
    
    /**
     * 选中每个Item时下面的横线的颜色
     */
    var lineColor:UIColor!
    
    /**
     * 展开扩展菜单栏的按钮上的图片
     */
    var arrowBtnImage:UIImage!
    /**
     * 计算属性，根据currentItemIndex计算视图的Frame
     */
    var setViewWithItemIndex:Int {
        set{
            currentItemIndex = newValue
            let itemBtn = items[currentItemIndex] as! UIButton
            let flag = showArrowButton ? (kScreenWidth - arrowButtonWidth) : kScreenWidth
            if (itemBtn.frame.origin.x + itemBtn.frame.size.width) > flag {
                var offsetX = itemBtn.frame.origin.x + itemBtn.frame.size.width - flag
                if currentItemIndex < (items.count - 1) {
                    offsetX = offsetX + 60
                }
                scNavBar.setContentOffset(CGPointMake(offsetX, 0), animated: true)
            }else{
                scNavBar.setContentOffset(CGPointMake(0, 0), animated: true)
            }
            UIView.animateWithDuration(0.2) { () -> Void in
                let lineWidth = self.itemsWidth[self.currentItemIndex] as! CGFloat
                self.line.frame = CGRectMake(itemBtn.frame.origin.x + 2, self.line.frame.origin.y, lineWidth - 4.0, self.line.frame.size.height)
                for btn in self.items {
                    let tempBtn = btn as! UIButton
                    tempBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                    tempBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
                }
                itemBtn.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
                itemBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
            }
        }
        get{
            return currentItemIndex
        }
    }
    
    //MARK: -- 私有属性
    private var scNavBar:UIScrollView!            //可滑动导航栏
    private var arrowBtnImageView:UIImageView!    //展开扩展菜单栏的按钮
    private var line:UIView!                      //导航栏Item下面的线
    private var xLaunchMenu:XLaunchMenu!        //扩展菜单栏
    private var items:NSMutableArray!             //导航栏上Item数组
    private var itemsWidth:NSArray!               //Items的宽度数组
    private var showArrowButton:Bool = true       //显示扩展菜单按钮
    private var showScNavBarItemMenu:Bool!        //是否展开扩展菜单
    
    //MARK: ---- 公共方法 -----
    
    /**
     * 自定义初始化方法
     * @param frame SKScNavBar的frame
     * @param show  显示扩展菜单按钮
     */
    init(frame:CGRect, show:Bool, image:UIImage) {
        super.init(frame: frame)
        self.showArrowButton = show
        self.arrowBtnImage = image
        self.showScNavBarItemMenu = false
        initWithConfig()
        
    }
    
    /**
     * 设置Item上的数据
     */
    func setItemsData() {
                
        itemsWidth = getItemsWidthWithTitles(itemsTitles)
        if itemsWidth.count != 0 {
            let contentWidth = getScNavContentAddScNavBarItemsWithItemsWidth(itemsWidth)
            scNavBar.contentSize = CGSizeMake(contentWidth, 0)
        }
    }
    
    /**
     * 刷新所有的子视图
     */
    func refreshAll() {
        showLaunchMenu(showScNavBarItemMenu)
    }
    
    //MARK: ----- 私有方法 -----
    //MARK: -- 初始化方法
    private func initWithConfig() {
        items = NSMutableArray()
        //调用配置视图的方法
        configView()
    }
    
    //MARK: -- 配置视图
    private func configView() {
        let frameX = showArrowButton ? (kScreenWidth - arrowButtonWidth) : kScreenWidth
        if showArrowButton {
            arrowBtnImageView = UIImageView(frame: CGRectMake(frameX, 0, arrowButtonWidth, arrowButtonWidth))
            arrowBtnImageView.userInteractionEnabled = true
            
            arrowBtnImageView.image = arrowBtnImage
            arrowBtnImageView.backgroundColor = self.backgroundColor
            self.addSubview(arrowBtnImageView)
            
            //setShadowForView(arrowBtnImageView, shadowRadius: 10.0, shadowOpacity: 10.0)
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(XScNavBar.arrowBtnTapGesAction))
            arrowBtnImageView.addGestureRecognizer(tapGestureRecognizer)
        }
        scNavBar = UIScrollView(frame: CGRectMake(0, 0, frameX, scNavBarHeight))
        scNavBar.showsHorizontalScrollIndicator = false
        self.addSubview(scNavBar)
        //调用给视图设置阴影的方法
        setShadowForView(self, shadowRadius: 10.0, shadowOpacity: 10.0)
    }
    
    //MARK: -- 往导航栏上添加ItemButton
    private func getScNavContentAddScNavBarItemsWithItemsWidth(widths:NSArray) -> CGFloat {
        var buttonX:CGFloat = 0
        for index in 0 ..< itemsTitles.count {
            let button = UIButton(type: UIButtonType.Custom)
            button.frame = CGRectMake(buttonX, 0, widths[index] as! CGFloat, scNavBarHeight)
            button.setTitle((itemsTitles[index] as! String), forState: UIControlState.Normal)
            button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            button.titleLabel?.font = UIFont.systemFontOfSize(14)
            button.addTarget(self, action: #selector(XScNavBar.itemsBtnAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            scNavBar.addSubview(button)
            
            items.addObject(button)
            buttonX += widths[index] as! CGFloat
        }
        let btn = items[0] as! UIButton
        btn.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        btn.titleLabel?.font = UIFont.systemFontOfSize(16)
        self.setLineWithItemsWidth(widths[0] as! CGFloat)
        
        return buttonX
    }
    
    //MARK: -- 根据Items的宽度设置Item下面的线
    private func setLineWithItemsWidth(width:CGFloat) {
        line = UIView(frame: CGRectMake(2, scNavBarHeight - 2, width - 4, 2))
        line.backgroundColor = lineColor
        scNavBar.addSubview(line)
    }
    
    //MARK: -- 给视图设置阴影的方法
    private func setShadowForView(view:UIView, shadowRadius:CGFloat, shadowOpacity:Float) {
        view.layer.shadowRadius = shadowRadius
        view.layer.shadowOpacity = shadowOpacity
    }
    
    //MARK: -- 通过Item上的标题获取每个Item的宽度组成的数组
    private func getItemsWidthWithTitles(titles:NSArray) -> NSArray {
        let itemsWidths = NSMutableArray()
        for title in titles {
            let str = title as! NSString
            let size:CGSize = str.sizeWithAttributes([NSFontAttributeName:UIFont.systemFontOfSize(UIFont.systemFontSize())])
            let fValue:CGFloat = size.width + 40
            itemsWidths.addObject(fValue)
        }
        return itemsWidths
    }
    
    //MARK: -- 添加扩展菜单栏
    private func showLaunchMenu(show:Bool) {
        if show {
            setShadowForView(arrowBtnImageView, shadowRadius: 0, shadowOpacity: 0)
            UIView.animateWithDuration(0.5, animations: {
                [unowned self] in
                self.scNavBar.hidden = true
                self.arrowBtnImageView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                }, completion: { (finished:Bool) -> Void in
                    UIView.animateWithDuration(0.2, animations: { [unowned self] in
                        if self.xLaunchMenu == nil {
                            let layout = UICollectionViewFlowLayout()
                            self.xLaunchMenu = XLaunchMenu(layout: layout, subViewTitles: self.itemsTitles)
                            self.xLaunchMenu.delegate = self
                            self.addSubview(self.xLaunchMenu.launchMenu)
                            self.xLaunchMenu.launchMenu.reloadData()
                        }
                        self.xLaunchMenu.launchMenu.hidden = false
                    })
            })
        }else{
            UIView.animateWithDuration(0.5, animations: {
                [unowned self] in
                self.xLaunchMenu.launchMenu.hidden = !self.xLaunchMenu.launchMenu.hidden
                self.arrowBtnImageView.transform = CGAffineTransformIdentity
                }, completion: { (finished:Bool) -> Void in
                    self.scNavBar.hidden = !self.scNavBar.hidden
               self.setShadowForView(self.arrowBtnImageView, shadowRadius: 10.0, shadowOpacity: 10.0)
            })
        }
    }
    
    //MARK: -- 导航栏上面Item的点击事件
    func itemsBtnAction(sender:UIButton) {
        let index = items.indexOfObject(sender)
        delegate?.didSelectedWithIndex(index)
    }
    
    //MARK: -- 展开扩展菜单栏按钮点击事件
    func arrowBtnTapGesAction() {
        showScNavBarItemMenu = !showScNavBarItemMenu
        let height = kScreenWidth / 5.0 * CGFloat(itemsTitles.count / 4)
        delegate?.isShowScNavBarItemMenu(showScNavBarItemMenu, height: height)
    }
    
    //MARK: -- SKLaunchMenuDelegate中的方法
    func itemPressedWithIndex(index: Int) {
        arrowBtnTapGesAction()
        delegate?.didSelectedWithIndex(index)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
