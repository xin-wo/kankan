//
//  DataBase.swift
//  响巢看看
//
//  Created by qianfeng on 16/11/21.
//  Copyright © 2016年 王鑫. All rights reserved.
//

import UIKit
import CoreData

class DataBase {
    static let shareDataBase = DataBase()
    private init() {}
    var delegate: AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    func insertWithModel(model: HotModel) {
        let entity  = NSEntityDescription.insertNewObjectForEntityForName("VideoEntity", inManagedObjectContext: delegate.managedObjectContext) as! VideoEntity
        entity.img = model.img
        entity.playtimes = model.playtimes
        entity.title = model.title
        entity.videoid = model.videoid
        
        delegate.saveContext()
        
    }
    
    func selectEntity(videoid: NSNumber) -> VideoEntity? {
        let request = NSFetchRequest()
        //设置数据请求的实体结构,设置数据库中查找的表
        request.entity = NSEntityDescription.entityForName("VideoEntity", inManagedObjectContext: delegate.managedObjectContext)
        request.fetchLimit = 1 //限定查询结果的最大数量
        //设置排序
        //        request.sortDescriptors = [NSSortDescriptor(key: , ascending: true)]
        //设置查询条件
        request.predicate = NSPredicate(format: "videoid == %@", videoid)
        do {
            //查询操作,返回查询结果，是一个数组
            let objects = try delegate.managedObjectContext.executeFetchRequest(request)
            if objects.count > 0 {
                return objects[0] as? VideoEntity
            }
        } catch {
            let nserror = error as NSError
            NSLog("查询错误：\(nserror), \(nserror.userInfo)")
        }
        
        return nil
    }
    
    
    func selectNum(num: Int) -> [HotModel]? {
        let request = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("VideoEntity", inManagedObjectContext: delegate.managedObjectContext)
        // 设置查询结果的最大数量
        request.fetchLimit = num
        /*设置排序
         参1：key 是以什么排序
         参2： 是否是升序，true是升序，false是降序
         
         */
        //        request.sortDescriptors = [NSSortDescriptor(key: "age", ascending: true)]
        
        // BETWEEN 在两者之间
        
        //        let num1 = NSNumber(integer: 14)
        //        let num2 = NSNumber(integer: 20)
        //        request.predicate = NSPredicate(format: "age BETWEEN {%@, %@}", num1, num2)
        //
        //复合条件
        
        //        request.predicate = NSPredicate(format: "age > %@ && sex == %@", num1, "女")
        
        // %K 用来做key的占位符
        
        //        request.predicate = NSPredicate(format: "%K > %@", "age", num1)
        
        
        do {
            // 查询操作
            let objects = try delegate.managedObjectContext.executeFetchRequest(request) as! [VideoEntity]
            var array: [HotModel] = []
            
            
            for App in objects {
                let model = HotModel()
                model.img = App.img
                model.playtimes = App.playtimes
                model.title = App.title
                model.videoid = App.videoid
                
                array.append(model)
            }
            return array
            
        } catch {
            let nserror = error as NSError
            NSLog("查询错误：\(nserror), \(nserror.userInfo)")
            
            
        }
        
        return nil
        
    }
    
    
    // 根据id删除数据
    func deleteWithIDcard(ID videoid: NSNumber) {
        // 拿到entity
        let entity = self.selectEntity(videoid)
        
        // 用managerContext去删除
        delegate.managedObjectContext.deleteObject(entity!)
        
        // 让managerContext与数据库同步
        delegate.saveContext()
    }
    
    
    
    
}