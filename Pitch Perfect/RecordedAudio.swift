//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Khoa Vo on 8/6/15.
//  Copyright (c) 2015 AppSynth. All rights reserved.
//

import Foundation

// Note: capitalize first letters of all class names 
class RecordedAudio:NSObject {
    
    var filePathUrl: NSURL!
    var title:String!
    
    init(filePathUrl: NSURL, title:String) {
        
        self.filePathUrl = filePathUrl
        self.title = title
        
    }
    
}