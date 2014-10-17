//
//  MainTableViewController.swift
//  BTSDemo
//
//  Created by zubrin on 10/16/14.
//  Copyright (c) 2014 zubrin. All rights reserved.
//

import UIKit
import QuickLook

class MainTableViewController
    : UITableViewController
    , NSURLSessionDelegate
    , NSURLSessionDownloadDelegate
    , NSURLSessionDataDelegate
    , QLPreviewControllerDataSource
{

    // MARK: - Constants
    let sessionID = "com.zubrin.BTSDemo.sessionID"

    // MARK: - View tags
    let CellLabelTagValue            = 10
    let CellStartPauseButtonTagValue = 20
    let CellStopButtonTagValue       = 30
    let CellProgressBarTagValue      = 40
    let CellPreviewButtonTagValue    = 50
    
    // MARK: - Properties
    
    var urlSession: NSURLSession? = nil
    var docDirectoryURL: NSURL? = nil
    var arrFileDownloadData: [FileDownloadInfo] = []
    var fdiForPreview: FileDownloadInfo? = nil
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeFileDownloadDataArray()
        
        var urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains:NSSearchPathDomainMask.UserDomainMask) as [NSURL]
        self.docDirectoryURL = urls[0]
        
        // Disable scrolling in table view.
        self.tableView.scrollEnabled = false;
        
        self.configureSession()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int
    {
        return self.arrFileDownloadData.count
    }

    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("idCell", forIndexPath: indexPath) as UITableViewCell

        var fdi = self.arrFileDownloadData[indexPath.row]
        var startButtonImageName = "play"
        
        // UI
        var titleLabel   = cell.viewWithTag(CellLabelTagValue) as UILabel
        titleLabel.text = fdi.fileTitle

        var startButton  = cell.viewWithTag(CellStartPauseButtonTagValue) as UIButton
        var stopButton   = cell.viewWithTag(CellStopButtonTagValue) as UIButton
        var progressView = cell.viewWithTag(CellProgressBarTagValue) as UIProgressView
        var readyLabel   = cell.viewWithTag(CellPreviewButtonTagValue) as UIButton
        if !fdi.isDownloading {
            progressView.hidden = true
            stopButton.enabled = false
            startButton.hidden = fdi.isDownloadComplete
            stopButton.hidden = fdi.isDownloadComplete
            readyLabel.hidden = !fdi.isDownloadComplete
            startButtonImageName = "play"
        } else {
            progressView.hidden = false
            progressView.progress = fdi.downloadProgress
            stopButton.enabled = true
            startButtonImageName = "pause"
        }

        startButton.setImage(UIImage(named: startButtonImageName), forState: UIControlState.Normal)

        return cell
    }
    
    // MARK: - QLPreviewController data source

    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController!) -> Int {
        return 1
    }
    
    func previewController(controller: QLPreviewController!, previewItemAtIndex index: Int) -> QLPreviewItem! {
        return self.fdiForPreview!
    }
    
    // MARK: - NSURLSessionDelegate
    
    func URLSession(session: NSURLSession,
        downloadTask: NSURLSessionDownloadTask,
        didFinishDownloadingToURL location: NSURL)
    {
        let destinationFileName = downloadTask.originalRequest.URL.lastPathComponent
        if let destinationUrl = self.docDirectoryURL?.URLByAppendingPathComponent(destinationFileName) {
            let fileManager = NSFileManager.defaultManager()
            
            if fileManager.fileExistsAtPath(destinationUrl.path!) {
                fileManager.removeItemAtURL(destinationUrl, error: nil)
            }
            
            var error: NSError?
            if fileManager.copyItemAtURL(location, toURL: destinationUrl, error: &error) {
                let index = self.getFileDownloadInfoIndexWithTaskIdentifier(downloadTask.taskIdentifier)
                let fdi = self.arrFileDownloadData[index]
                fdi.isDownloading = false
                fdi.isDownloadComplete = true
                fdi.resetInfo()
                
                NSOperationQueue.mainQueue().addOperationWithBlock(){
                    self.tableView.reloadData()
                }
            } else {
                println("ERROR: unable to copy file: \(error?.localizedDescription)" )
            }
        }
    }
    
    func URLSession(session: NSURLSession,
        downloadTask: NSURLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64)
    {
        if totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown {
            println("Unknown transfer size")
        } else {
            let index = self.getFileDownloadInfoIndexWithTaskIdentifier(downloadTask.taskIdentifier)
            if index != -1 {
                let fdi = self.arrFileDownloadData[index]
                let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    fdi.downloadProgress = progress
                    
                    if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) {
                        let progressView = cell.viewWithTag(self.CellProgressBarTagValue) as UIProgressView
                        progressView.progress = fdi.downloadProgress
                    }
                }
            }
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            println("Download finished with error: \(error?.localizedDescription)")
        } else {
            println("Download finished with success")
        }
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        let appDelegate = UIApplication.sharedApplication().delegate! as AppDelegate
        
        self.urlSession?.getTasksWithCompletionHandler(){(dataTasks: [AnyObject]!,
                                                          uploadTasks: [AnyObject]!,
                                                          downloadTasks:[AnyObject]!) -> Void in
            if downloadTasks.count == 0 {
                if let handler = appDelegate.bgURLSessionCompletionHandler {
                    appDelegate.bgURLSessionCompletionHandler = nil
                    NSOperationQueue.mainQueue().addOperationWithBlock(){
                        handler()
                        
                        let notification = UILocalNotification()
                        notification.alertBody = "All files have been downloaded!"
                        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
                    }
                }
            }
        }
    }
    // MARK: - User actions
    
    @IBAction func startOrPauseSingleFileDownload(sender: AnyObject) {
        if sender.superview!!.superview is UITableViewCell {
            let cell = sender.superview!!.superview as UITableViewCell
            let iPath = self.tableView.indexPathForCell(cell)
            let fdi = self.arrFileDownloadData[iPath!.row]
            if !fdi.isDownloading {
                if !fdi.isValid() {
                    fdi.downloadTask = self.urlSession!.downloadTaskWithURL(NSURL(string: fdi.downloadSource))
                    fdi.taskID = fdi.downloadTask!.taskIdentifier
                    fdi.downloadTask!.resume()
                } else {
                    // The resume of download task will be done here
                    fdi.downloadTask = self.urlSession?.downloadTaskWithResumeData(fdi.taskResumeData!)
                    fdi.downloadTask?.resume()
                    fdi.taskID = fdi.downloadTask!.taskIdentifier
                }
            } else {
                //  The pause of a download task will be done here.
                fdi.downloadTask?.cancelByProducingResumeData() { (data) -> Void in
                    if data != nil {
                        fdi.taskResumeData = data
                    }
                }
            }
            
            fdi.isDownloading = !(fdi.isDownloading)
            self.tableView.reloadData()
        }
    }
    
    @IBAction func stopSingleFileDownload(sender: AnyObject) {
        if sender.superview!!.superview is UITableViewCell {
            let cell = sender.superview!!.superview as UITableViewCell
            let iPath = self.tableView.indexPathForCell(cell)
            let fdi = self.arrFileDownloadData[iPath!.row]
            fdi.downloadTask?.cancel()
            
            fdi.isDownloading = false
            fdi.downloadProgress = 0.0
            fdi.resetInfo()
            
            self.tableView.reloadData()
        }
    }
    
    @IBAction func showFilePreview(sender: AnyObject) {
        if sender.superview!!.superview is UITableViewCell {
            let cell = sender.superview!!.superview as UITableViewCell
            let iPath = self.tableView.indexPathForCell(cell)
            self.fdiForPreview = self.arrFileDownloadData[iPath!.row]
            
            // use quik look
            let qlPerviewController = QLPreviewController()
            qlPerviewController.dataSource = self
            self.navigationController?.pushViewController(qlPerviewController, animated: true)
        }
    }
    
    @IBAction func startAllDownload(sender: AnyObject) {
    }
    
    @IBAction func stopAllDownload(sender: AnyObject) {
    }
    
    @IBAction func initializeAll(sender: AnyObject) {
        for fdi in self.arrFileDownloadData {
            if fdi.isDownloading {
                fdi.downloadTask?.cancel()
            }
            fdi.isDownloading = false
            fdi.isDownloadComplete = false
            fdi.downloadProgress = 0.0
            fdi.resetInfo()
        }
        
        self.tableView.reloadData()
        
        let fileManager = NSFileManager.defaultManager()
        let files = fileManager.contentsOfDirectoryAtURL(self.docDirectoryURL!, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles, error: nil) as [NSURL]
        for fileUrl in files {
            fileManager.removeItemAtURL(fileUrl, error: nil)
        }
    }
    
    // MARK: - Private
    
    private func initializeFileDownloadDataArray() {
        self.arrFileDownloadData.append(FileDownloadInfo(title:"iOS Programming Guide", source:"https://developer.apple.com/library/ios/documentation/iphone/conceptual/iphoneosprogrammingguide/iphoneappprogrammingguide.pdf"))
        self.arrFileDownloadData.append(FileDownloadInfo(title:"Human Interface Guidelines", source:"https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/MobileHIG/MobileHIG.pdf"))
        self.arrFileDownloadData.append(FileDownloadInfo(title:"Networking Overview", source:"https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/NetworkingOverview.pdf"))
        self.arrFileDownloadData.append(FileDownloadInfo(title:"AV Foundation", source:"https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/AVFoundationPG.pdf"))
        self.arrFileDownloadData.append(FileDownloadInfo(title:"iPhone User Guide", source:"http://manuals.info.apple.com/MANUALS/1000/MA1565/en_US/iphone_user_guide.pdf"))
    }
    
    private func configureSession() {
        let sessionConf = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(sessionID)
        sessionConf.HTTPMaximumConnectionsPerHost = 5
        self.urlSession = NSURLSession(configuration: sessionConf, delegate: self, delegateQueue: nil)
    }
    
    private func getFileDownloadInfoIndexWithTaskIdentifier(taskID: Int) -> Int {
        var index = -1
        
        var count = 0
        for dfi in self.arrFileDownloadData {
            if dfi.taskID == taskID {
                index = count
                break
            }
            count++
        }
        
        return index
    }
}
