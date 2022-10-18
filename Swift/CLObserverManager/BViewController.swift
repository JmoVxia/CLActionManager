//
//  BViewController.swift
//  CLObserverManager
//
//  Created by Chen JmoVxia on 2022/10/18.
//

import UIKit

//MARK: - JmoVxia---类-属性
class BViewController: UIViewController {
    private lazy var button: UIButton = {
        let view = UIButton()
        view.setTitle("点我", for: .normal)
        view.clipsToBounds = true
        view.backgroundColor = .red.withAlphaComponent(0.35)
        view.addTarget(self, action: #selector(clickAction), for: .touchUpInside)
        view.sizeToFit()
        return view
    }()
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "1")
        return view
    }()
    
    private lazy var label: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 30)
        view.textColor = .red
        view.text = "我是文字"
        view.backgroundColor = .red.withAlphaComponent(0.35)
        view.sizeToFit()
        return view
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(button)
        button.center = view.center
        
        view.addSubview(imageView)
        imageView.frame = CGRect(x: 199, y: 199, width: 80, height: 80)
        
        view.addSubview(label)
        label.frame = CGRect(x: 199, y: 299, width: 80, height: 80)
        label.sizeToFit()
        
        CLObserverManager.addObserver(self, types: [.image, .color(.backgroundColor), .color(.text)])
    }
}
@objc extension BViewController {
    func clickAction() {
        CLObserverManager.action(with: .color(.backgroundColor), data: UIColor.random)
        CLObserverManager.action(with: .color(.text), data: UIColor.random)
        CLObserverManager.action(with: .image, data: UIImage(named: "\(Int.random(in: 1...9))"))
    }
}
extension BViewController: CLObserverProtocol {
    func action(with type: CLObserverManager.CLObserverType, data: Any?) {
        if type == .image,
           let image = data as? UIImage {
            imageView.image = image
        }else if type == .color(.backgroundColor),
                 let color = data as? UIColor {
            label.backgroundColor = color
        }else if type == .color(.text),
                 let color = data as? UIColor {
            label.textColor = color
        }
    }
}
