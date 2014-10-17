//
//  FileDownloadInfo.swift
//  BTSDemo
//
//  Created by zubrin on 10/16/14.
//  Copyright (c) 2014 zubrin. All rights reserved.
//

import Foundation
import QuickLook

class FileDownloadInfo
    : NSObject
    , QLPreviewItem
{
    
    var fileTitle: String
    var downloadSource: String
    var downloadTask: NSURLSessionDownloadTask?
    var taskResumeData: NSData?
    var downloadProgress: Float = 0.0
    var isDownloading: Bool = false
    var isDownloadComplete: Bool = false
    var taskID: Int = -1
    
    init(title: String, source: String) {
        fileTitle = title
        downloadSource = source
        downloadTask = nil
        taskResumeData = nil
    }
    
    // MARK: - Public
    
    func isValid() -> Bool {
        return taskID != -1 && downloadTask != nil && taskID == downloadTask?.taskIdentifier
    }

    func resetInfo() {
        downloadTask = nil
        taskResumeData = nil
        taskID = -1
    }
    
    // MARK: - QLPreviewItem methods
    
    var previewItemURL: NSURL! {
        get {
            let urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains:NSSearchPathDomainMask.UserDomainMask) as [NSURL]
            let docDirectoryURL = urls[0]
            let destinationFileName = NSURL(string: self.downloadSource).lastPathComponent
            let destinationUrl = docDirectoryURL.URLByAppendingPathComponent(destinationFileName)
            return destinationUrl
        }
    }
    
    var previewItemTitle: String! {
        get {
            return self.fileTitle
        }
    }
}