//
//  DetailViewCell.swift
//  funnel
//
//  Created by Alec Osborne on 5/16/18.
//  Copyright © 2018 Rodrigo Sagebin. All rights reserved.
//

import UIKit
import CloudKit

protocol CommentsDelegate {
    func didTapComment(post: Post)
}

protocol SuggestionDelegate {
    func postSuggestionButtonTapped(post: Post)
}

class DetailViewCell: UITableViewCell {

    // MARK: - Properties
    var commentsDelegate: CommentsDelegate?
    
    var suggestDelegate: SuggestionDelegate?
    
    var post: Post? {
        didSet {
            checkIfUserIsFollowing()
            
            updateViews()
        }
    }
    
    var isFollowing = false

    
    // MARK: - Outlets
    
    @IBOutlet weak var frontView: UIView!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postApprovedImage: UIImageView!
    @IBOutlet weak var postFollowingCountLabel: UILabel!
    @IBOutlet weak var postFollowingButton: UIButton!
    @IBOutlet weak var postSuggestionCountLabel: UILabel!
    @IBOutlet weak var postSuggestionButton: UIButton!
    @IBOutlet weak var postCommentsCountLabel: UILabel!
    @IBOutlet weak var commentsButtonOutlet: UIButton!
    
    // MARK: - Actions
    @IBAction func postFollowingButtonTapped(_ sender: UIButton) {
        
        guard let user = UserController.shared.loggedInUser else { return }
        guard let post = self.post else { return }
        
        isFollowing = !isFollowing
        
        if isFollowing == true {
            postFollowingButton.setImage(#imageLiteral(resourceName: "star-filled-500"), for: .normal)
            PostController.shared.addFollowerToPost(user: user, post: post)

        } else if isFollowing == false {
            postFollowingButton.setImage(#imageLiteral(resourceName: "star"), for: .normal)
            PostController.shared.removeFollowerFromPost(user: user, post: post)
        }
        updateViews()
    }
    
    func checkIfUserIsFollowing() {
        isFollowing = false
        guard let userID = UserController.shared.loggedInUser else { return }
        let userRef = CKReference(recordID: userID.ckRecordID, action: .none)
        guard let followersRefs = post?.followersRefs else { return }
        
        for refNumber in followersRefs {
            if refNumber == userRef {
                isFollowing = true
                return
            }
        }
    }
    
    @IBAction func postSuggestButtonTapped(_ sender: UIButton) {
        guard let post = post else { return }
        suggestDelegate?.postSuggestionButtonTapped(post: post)
        print("suggestionButton tapped")
    }
    
    @IBAction func commentsButtonTapped(_ sender: Any) {
        print("Trying to show comments...")
        guard let post = post else { return }
        commentsDelegate?.didTapComment(post: post)
    }
    
    // MARK: - Other Functions
    func updateViews() {
        if let post = post {
            
            frontView.layer.cornerRadius = 3
            frontView.layer.borderColor = UIColor.lightGray.cgColor
            frontView.layer.borderWidth = 1
            
            self.postApprovedImage.isHidden = true
            self.categoriesLabel.text = post.categoryAsString
            self.descriptionTextView.text = post.description
            self.postImageView.image = post.image
            self.postFollowingCountLabel.text = String(post.followersRefs.count)
        }
    }
}
