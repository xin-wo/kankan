//
//  VideoViewController.swift
//  响巢看看
//
//  Created by qianfeng on 16/11/4.
//  Copyright © 2016年 王鑫. All rights reserved.
//

import UIKit

class VideoViewController: HotBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        url = HotSocialUrl
        configUI()
        loadData()
    }

    
}