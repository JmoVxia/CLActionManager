//
//  CLMapTable.swift
//  CLObserverManager
//
//  Created by Chen JmoVxia on 2022/10/18.
//

import Foundation


class CLMapTable {
    private let mapTable = NSMapTable<NSString, AnyObject>(keyOptions: .strongMemory, valueOptions: .weakMemory)
    var keys: [String] {
        return mapTable.keyEnumerator().allObjects as? [String] ?? []
    }

    var objects: [CLObserverProtocol] {
        return mapTable.objectEnumerator()?.allObjects as? [CLObserverProtocol] ?? []
    }

    func object(forKey aKey: String) -> CLObserverProtocol? {
        return mapTable.object(forKey: aKey as NSString) as? CLObserverProtocol
    }

    func setObject(_ anObject: CLObserverProtocol, forKey aKey: String) {
        mapTable.setObject(anObject, forKey: aKey as NSString)
    }
}
