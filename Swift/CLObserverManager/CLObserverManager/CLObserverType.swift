//
//  CLObserverType.swift
//  CLObserverManager
//
//  Created by Chen JmoVxia on 2022/10/18.
//

import Foundation

extension CLObserverManager {
    enum CLObserverType {
        case color(CLColor)
        case image
        var rawValue: String {
            switch self {
            case let .color(value):
                return value.rawValue + "color"
            case .image:
                return "image"
            }
        }
    }
}

extension CLObserverManager.CLObserverType {
    enum CLColor: String {
        case backgroundColor
        case text
    }
}

extension CLObserverManager.CLObserverType: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
