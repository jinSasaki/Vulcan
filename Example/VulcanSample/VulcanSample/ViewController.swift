//
//  ViewController.swift
//  VulcanSample
//
//  Created by Jin Sasaki on 2016/10/20.
//  Copyright © 2016年 Sasakky. All rights reserved.
//

import UIKit
import Vulcan

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    @IBAction func didTapButton() {
        imageView.image = nil
        imageView.vl_setImage(url: URL(string: "https://github.com/jinSasaki/Vulcan/raw/master/assets/sample_1024.jpg")!)
    }

    @IBAction func didTapPriorityButton() {
        imageView.image = nil

        imageView.vl_setImage(urls: [
            .url(URL(string: "https://github.com/jinSasaki/Vulcan/raw/master/assets/sample_100.jpg")!, priority: 100),
            .url(URL(string: "https://github.com/jinSasaki/Vulcan/raw/master/assets/sample_1024.jpg")!, priority: 1000)
            ])
    }

    @IBAction func didTapCacheClearButton() {
        imageView.image = nil
        UIImageView.vl_sharedImageDownloader.cache?.removeAll()
    }
}

