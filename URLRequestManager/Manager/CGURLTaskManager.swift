//
//  CGURLTaskManager.swift
//  TestCG_CGKit
//
//  Created by DY on 2017/3/29.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit


class CGURLTaskManager: NSObject {
    
    private var taskList = [Int : CGTaskDataModel]()
    
    //MARK:- 添加移除 task
    func addTaskData(sessionTask: URLSessionTask) -> CGTaskDataModel {
        
        var taskDataModel   = taskList[sessionTask.taskIdentifier];
        if taskDataModel == nil {
            
            taskDataModel   = CGTaskDataModel.init(task: sessionTask)
            taskList.updateValue(taskDataModel!, forKey: sessionTask.taskIdentifier)
        }
        return taskDataModel!
    }
    
    func removeTaskData(sessionTask: URLSessionTask) -> CGTaskDataModel? {
        
        return self.removeTaskData(sessionTaskIdentifier: sessionTask.taskIdentifier)
    }
    
    func removeTaskData(sessionTaskIdentifier: Int) -> CGTaskDataModel? {
        
        return taskList.removeValue(forKey: sessionTaskIdentifier)
    }
    
    func getTaskData(sessionTask: URLSessionTask) -> CGTaskDataModel {
        return self.addTaskData(sessionTask: sessionTask)
    }
    
    //MARK:- 设置 taskDataModel 的 URLResponse
    func setupTaskData(sessionTask: URLSessionTask, response: URLResponse) {
        
        
    }
    
    //MARK:- 设置 taskDataModel 的 data
    func setupTaskData(sessionTask: URLSessionTask, data: Data) {
        
        let taskDataModel   = self.getTaskData(sessionTask: sessionTask)
        taskDataModel.append(data: data)
    }
}
