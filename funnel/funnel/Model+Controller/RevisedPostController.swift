//
//  RevisedPostController.swift
//  funnel
//
//  Created by Drew Carver on 5/18/18.
//  Copyright © 2018 Rodrigo Sagebin. All rights reserved.
//

import Foundation
import CloudKit

class RevisedPostController {
    
    let ckManager = CloudKitManager()
    
    static let shared  = RevisedPostController()
    
    var revisedPostsToApprove: [RevisedPost] = []
    var revisedPostsUserCreated: [RevisedPost] = []
    
    func createRevisedPost(for post: Post, description: String, category1: Category1?, category2: Category2?, category3: Category3?) {
        var category1Ref: CKReference?
        var category2Ref: CKReference?
        var category3Ref: CKReference?
        
        if let category1 = category1 {
            category1Ref = CKReference(recordID: category1.ckRecordID ?? category1.ckRecord.recordID, action: .none)
        }
        
        if let category2 = category2 {
            category2Ref = CKReference(recordID: category2.ckRecordID ?? category2.ckRecord.recordID, action: .none)
        }
        
        if let category3 = category3 {
            category3Ref = CKReference(recordID: category3.ckRecordID ?? category3.ckRecord.recordID, action: .none)
        }

        let revisedPost = RevisedPost(post: post, description: description, category1Ref: category1Ref, category2Ref: category2Ref, category3Ref: category3Ref)
        
        ckManager.save(records: [revisedPost.ckRecord], perRecordCompletion: nil) { (records, error) in
            if let error = error {
                print("Error saving new revised post to CloudKit: \(error)")
            }
        }
        
    }
    
    func deleteRevisedPost(revisedPost: RevisedPost) {
        
    }
    
    func acceptRevisedPost(revisedPost: RevisedPost, for post: Post) {
        
    }
    
    
}
