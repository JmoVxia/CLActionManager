//
//  CLObserverProtocol.swift
//  CLObserverManager
//
//  Created by Chen JmoVxia on 2022/10/18.
//

import Foundation

protocol CLObserverProtocol where Self: AnyObject {
    /// 监听事件下发
    func action(with type: CLObserverManager.CLObserverType, data: Any?)
}
