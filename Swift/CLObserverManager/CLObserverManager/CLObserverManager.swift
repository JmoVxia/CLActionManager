//
//  CLObserverManager.swift
//  CLObserverManager
//
//  Created by Chen JmoVxia on 2022/10/18.
//

import UIKit

class CLObserverManager: NSObject {
    static let shared = CLObserverManager()
    private let mapTable = CLMapTable()
    override private init() {
        super.init()
    }
}

extension CLObserverManager {
    /// 添加事件监听
    class func addObserver(_ observer: CLObserverProtocol, types: [CLObserverType]) {
        for type in types {
            let key = "\(type.rawValue)+\(Unmanaged.passUnretained(observer as AnyObject).toOpaque())"
            shared.mapTable.setObject(observer, forKey: key)
        }
    }

    /// 发送监听事件
    class func action(with type: CLObserverType, data: Any? = nil) {
        DispatchQueue.main.async {
            shared.mapTable.keys.forEach { key in
                guard let observer = shared.mapTable.object(forKey: key) else { return }
                guard key == "\(type.rawValue)+\(Unmanaged.passUnretained(observer as AnyObject).toOpaque())" else { return }
                observer.action(with: type, data: data)
            }
        }
    }
}
