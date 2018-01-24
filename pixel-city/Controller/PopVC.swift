//
//  PopVC.swift
//  pixel-city
//
//  Created by LinuxPlus on 1/22/18.
//  Copyright © 2018 ARC. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var ownerLbl: UILabel!
    
    var passedImage: UIImage!
    var passedTitle: String!
    var passedOwner: String!
    
    func initData(forImage image: UIImage) {
        self.passedImage = image
    }
    
    func initData(forImage image: UIImage, title: String, owner: String) {
        self.passedOwner = "by: \(owner)"
        self.passedTitle = title
        initData(forImage: image)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLbl.text = passedTitle
        ownerLbl.text = passedOwner
        popImageView.image = passedImage
        addDoubleTap()
    }


    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func screenWasDoubleTapped()    {
        dismiss(animated: true, completion: nil)
    }
    
}
