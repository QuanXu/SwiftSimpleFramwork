//
//  ListViewController.swift
//  SwiftDemo
//
//  Created by zhoutong on 16/11/18.
//  Copyright © 2016年 zhoutong. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher
import ESPullToRefresh


class ListViewController: BaseViewController {

    fileprivate let CellIdentifierClass = "cellId"
    var json:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func layoutPageSubViews() {
        self.demoTableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(0)
            make.left.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.view).offset(0)
        }
        
    }
    
    
    //MARK:----属性-----
    lazy var demoTableView:UITableView = {
        let _demoTableView = UITableView.init(frame: CGRect(x:0,y:0,width:0,height:0), style: UITableViewStyle.plain)
        _demoTableView.backgroundColor = UIColor.clear
        _demoTableView.dataSource = self
        _demoTableView.delegate = self
        
        let v:UIView = UIView.init(frame: CGRect.zero)
        _demoTableView.tableFooterView = v
        return _demoTableView
    }()
    
}
extension ListViewController{
    //设置view
    func setUpView(){
        self.title = "table view"
        self.view.addSubview(self.demoTableView)

        self.setRightButton(imgName: "tab_user_selected")
        
        self.demoTableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifierClass)
        
        var header: ESRefreshProtocol & ESRefreshAnimatorProtocol
        var footer: ESRefreshProtocol & ESRefreshAnimatorProtocol
        header = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
        footer = ESRefreshFooterAnimator.init(frame: CGRect.zero)
        _ = self.demoTableView.es_addPullToRefresh(animator: header) { [weak self] in
            self?.loadData()
        }
        _ = self.demoTableView.es_addInfiniteScrolling(animator: footer) { [weak self] in
            self?.loadMore()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.demoTableView.es_autoPullToRefresh()
        }
    }
    //刷新
    func loadData(){
        self.initLoadingView()
        ApiManager.sharedInstance.getListData(success: { (value) in
            self.removeLoadingView()
            self.json = JSON(value)
            self.demoTableView.reloadData()
            self.demoTableView.es_stopPullToRefresh()
        }) { (error) in
            self.removeLoadingView()
            self.demoTableView.es_stopPullToRefresh()
        }
    }
    //加载更多
    func loadMore(){
        DLog(message: "loadMore")
        self.demoTableView.reloadData()
        self.demoTableView.es_stopLoadingMore()
        //self.demoTableView.es_noticeNoMoreData()
        //self.demoTableView.es_removeRefreshFooter()
    }
    override func rightButtonAction() {
        alert(title: "提示", msg: "请输入密码")
    }
    
}
extension ListViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.json["data"].count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifierClass)!
        cell.textLabel?.text = self.json["data"][indexPath.row]["anchor_city"].string
        cell.imageView?.kf.setImage(with: self.json["data"][indexPath.row]["avatar_small"].URL, placeholder: UIImage.init(named: "tab_find_selected"), options: nil, progressBlock: nil, completionHandler: nil)
        return cell
    }
}
