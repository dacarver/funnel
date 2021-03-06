//
//  PersonalFeedViewController.swift
//  funnel
//
//  Created by Alec Osborne on 5/14/18.
//  Copyright © 2018 Rodrigo Sagebin. All rights reserved.
//

import UIKit

class FollowingTableViewController: UITableViewController {

    // MARK: - Properties
    var sectionTitles: [String] = []
    var theRefreshControl: UIRefreshControl!
    var userPosts = [Post]()
    var userFollowings = [Post]()
    var communitySuggestions = [RevisedPost]()
    var userSuggestions = [RevisedPost]()
    
    var allPosts: [[Any]] = []
//    var revisedPost: RevisedPost? move back to PostDetail

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Following" // Isn't reflecting on the bar
        createRefreshControl()
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136: print("5, 5S, 5C, SE")
            case 1334: print("6, 6S, 7, 8")
            case 2208: print("6+, 6S+, 7+, 8+")
            case 2436: print("X")
            default: print("Unknown Device Height \(#function)")
            }
        }
        
//        tableView.contentInset = UIEdgeInsetsMake(0, 10, 0, -10)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchUserPosts()
        fetchFollowingPosts()
        fetchUserSuggestionPosts()
        fetchSuggestionsToApprove()
    }
    
    
    // MARK: - TableView Methods
    // Sections
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return allPosts.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard sectionTitles.indices ~= section else { return nil }
        return sectionTitles[section]
    }

    // Rows
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cellHeight = 115
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136: cellHeight = 115
            case 1334: cellHeight = 122
            case 2208: cellHeight = 125
            case 2436: cellHeight = 122
            default: print("Unknown Device Height \(#function)")
            }
        }
        return CGFloat(cellHeight)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = allPosts[section].count
        return rows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? FollowingTableViewCell else { return UITableViewCell() }
        
        if let post = allPosts[indexPath.section][indexPath.row] as? Post {
            if post.creatorRef.recordID  == UserController.shared.loggedInUser?.ckRecordID {
                cell.userPost = post
            }
            cell.userFollowing = post
        }
        
        if let revisedPost = allPosts[indexPath.section][indexPath.row] as? RevisedPost {
            if revisedPost.ckRecordID == UserController.shared.loggedInUser?.ckRecordID {
                cell.userSuggestion = revisedPost
            }
            cell.communitySuggestion = revisedPost
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        
        guard let user = UserController.shared.loggedInUser else { return }
        
        let selectedPost = self.allPosts[indexPath.section][indexPath.row]
        
        if let selectedPost = selectedPost as? Post {
            
            let postDetailSB = UIStoryboard(name: "PostDetail", bundle: .main)
            let postDetailVC = postDetailSB.instantiateViewController(withIdentifier: "PostDetailSB") as! PostDetailViewController
            postDetailVC.post = selectedPost
            navigationController?.pushViewController(postDetailVC, animated: true)
        }
        
        if let selectedPost = selectedPost as? RevisedPost, selectedPost.creatorRef.recordID == user.ckRecordID {
            
            let createAndSuggestSB = UIStoryboard(name: "CreateAndSuggest", bundle: .main)
            let createAndSuggestVC = createAndSuggestSB.instantiateViewController(withIdentifier: "CreateAndSuggestSB") as! CreateAndSuggestViewController
            createAndSuggestVC.revisedPost = selectedPost
            navigationController?.pushViewController(createAndSuggestVC, animated: true)
        }
        
        if let selectedPost = selectedPost as? RevisedPost, selectedPost.creatorRef.recordID != user.ckRecordID {
            
            let postDetailSB = UIStoryboard(name: "PostDetail", bundle: .main)
            let postDetailVC = postDetailSB.instantiateViewController(withIdentifier: "PostDetailSB") as! PostDetailViewController
            postDetailVC.revisedPost = selectedPost
            navigationController?.pushViewController(postDetailVC, animated: true)
        }
    }
    
    func fetchUserPosts() {
        
        startNetworkActivity()
        
        guard let user = UserController.shared.loggedInUser else { return }
        
        PostController.shared.fetchUserPosts(user: user) { (success) in
            DispatchQueue.main.async {
                if success {
                    
                    self.userPosts = PostController.shared.userPosts
                    self.endNetworkActivity()
                    self.setUpAllPostsArray()
                    self.tableView.reloadData()
                    
                }
                
                if !success {
                    print("Could not fetch user posts")
                    self.endNetworkActivity()
                }
            }
        }
    }
    
    func fetchFollowingPosts() {
        
        startNetworkActivity()
        
        guard let user = UserController.shared.loggedInUser else { return }
        
        PostController.shared.fetchFollowingPosts(user: user) { (success) in
            DispatchQueue.main.async {
                
                if success {
                    self.userFollowings = PostController.shared.followingPosts
                    self.endNetworkActivity()
                    self.setUpAllPostsArray()
                    self.tableView.reloadData()
                }
                
                if !success {
                    print("Could not fetch following posts")
                    self.endNetworkActivity()
                }
            }
        }
    }
    
    func fetchSuggestionsToApprove() {
        
        startNetworkActivity()
        
        guard let user = UserController.shared.loggedInUser else { return }
        
        RevisedPostController.shared.fetchRevisedPostsToApprove(originalPostCreator: user) { (success) in
            
            DispatchQueue.main.async {
                if success {
                    self.communitySuggestions = RevisedPostController.shared.revisedPostsToApprove
                    self.endNetworkActivity()
                    self.setUpAllPostsArray()
                    self.tableView.reloadData()
                }
                
                if !success {
                    print("Could not fetch community suggested posts")
                }
            }
        }
    }
    
    func fetchUserSuggestionPosts() {
        
        startNetworkActivity()
        
        guard let user = UserController.shared.loggedInUser else { return }
        
        RevisedPostController.shared.fetchRevisedPostsUserCreated(revisedPostCreator: user) { (success) in
            DispatchQueue.main.async {
                
                if success {
                    self.userSuggestions = RevisedPostController.shared.revisedPostsUserCreated
                    self.endNetworkActivity()
                    self.setUpAllPostsArray()
                    self.tableView.reloadData()
                }
                
                if !success {
                    print("Could not fetch user suggested posts")
                    self.endNetworkActivity()
                }
            }
        }
    }
    
    func setUpAllPostsArray() {
        var allPostsArray: [[Any]] = []
        self.sectionTitles = []
        
        if userPosts.count > 0 {
            allPostsArray.append(self.userPosts)
            sectionTitles.append("My Posts")
        }
        
        if userFollowings.count > 0 {
            allPostsArray.append(self.userFollowings)
            sectionTitles.append("Post I'm Following")
        }
        
        if communitySuggestions.count > 0 {
            allPostsArray.append(self.communitySuggestions)
            sectionTitles.append("Posts To Approve")
        }
        
        if userSuggestions.count > 0 {
            allPostsArray.append(self.userSuggestions)
            sectionTitles.append("Posts I've Suggested")
        }
        self.allPosts = allPostsArray
    }
    
    func startNetworkActivity() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func endNetworkActivity() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    @objc func didPullForRefresh() {
        
        fetchUserPosts()
        fetchFollowingPosts()
        fetchUserSuggestionPosts()
        fetchSuggestionsToApprove()
        tableView.reloadData()
        theRefreshControl.endRefreshing()
    }
    
    func createRefreshControl() {
        
        theRefreshControl = UIRefreshControl()
        theRefreshControl.addTarget(self, action: #selector(didPullForRefresh), for: .valueChanged)
        tableView.addSubview(theRefreshControl)
    }
}
