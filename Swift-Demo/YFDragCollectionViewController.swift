//
//  YFDragCollectionViewController.swift
//  Swift-Demo
//
//  Created by 刘永峰 on 2017/7/10.
//  Copyright © 2017年 Witgo. All rights reserved.
//

import UIKit

import YFSortableCollectionViewFlowLayoutSwift

private let reuseIdentifier = "DragsortCell"

class YFDragCollectionViewController: UICollectionViewController {
    
    fileprivate var selectedChannels: [String] = ["军事","科技","新闻","头条","娱乐","八卦","合肥","安徽","本地","体育","科技","新闻","头条","娱乐","八卦","合肥","安徽","本地","体育","科技","新闻","头条","娱乐","八卦","合肥","安徽","本地","体育","科技","新闻","头条","娱乐","八卦","合肥","安徽","本地","体育","科技","新闻","头条","娱乐","八卦","合肥","安徽","本地","体育","科技","新闻","头条","娱乐","八卦","合肥","安徽","本地","体育","科技","新闻","头条","娱乐","八卦","合肥","安徽","本地","体育"]
    fileprivate var unSelectedChannels: [String] = ["视频","语音","图片","搞笑","网易","财经","热门","直播","更贴","房产"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        let layout = YFSortableCollectionViewFlowLayout()
        let margin: CGFloat = 20.0
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = margin
        layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin)
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 5 * margin)/4.0, height: 40)
        collectionView?.collectionViewLayout = layout

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if section == 0 {
            return selectedChannels.count
        }
        return unSelectedChannels.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DragsortCell
    
        cell.nameLabel.text = indexPath.section == 0 ? selectedChannels[indexPath.row] : unSelectedChannels[indexPath.row]
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension YFDragCollectionViewController: YFSortableCollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, itemAt sourceIndexPath: IndexPath, willMoveTo destinationIndexPath: IndexPath) {
        
    }
    func collectionView(_ collectionView: UICollectionView, itemAt sourceIndexPath: IndexPath, didMoveTo destinationIndexPath: IndexPath) {
        let name = selectedChannels.remove(at: sourceIndexPath.row)
        selectedChannels.insert(name, at: destinationIndexPath.row)
    }
    func collectionView(_ collectionView: UICollectionView, itemCanMoveAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    func collectionView(_ collectionView: UICollectionView, canMoveItemTo indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
}

class DragsortCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.red : UIColor.lightGray
        }
    }
}
