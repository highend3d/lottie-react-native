//
//  ViewRecorder.swift
//  LottieTest
//
//  Created by Koretskiyil on 15/11/2017.
//  Copyright © 2017 ikoretskiy. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class AssetWriter {
    
    var frameBuffer : [UIImage]
    
    private var _framesPerSecond : Int;
    var framesPerSecond : Int {
        set { _framesPerSecond = newValue }
        get { return _framesPerSecond }
    }
    
    
    private var _size : CGSize;
    var size : CGSize {
        set { _size  = newValue }
        get { return _size}
    }
    
    private var _startDate : NSDate;
    var startDate : NSDate {
        set { _startDate = newValue }
        get {return _startDate }
    }
    
    private var _endDate : NSDate;
    var endDate : NSDate {
        set { _endDate = newValue }
        get {return _endDate }
    }
    
    var _fileOutputPath : String!;
    var _fileOutputURL : URL!;
    
    var input : AVAssetWriterInput!;
    var adapter : AVAssetWriterInputPixelBufferAdaptor!;
    var _timeOfFirstFrame : CFAbsoluteTime;
    
    var _writer : AVAssetWriter? = nil;
    var writer : AVAssetWriter{
        get{
            if (_writer != nil){
                return _writer!
            }
            
            _fileOutputPath = self.createOutputUrl()
            _fileOutputURL = URL(fileURLWithPath: _fileOutputPath)
            
            do {
                _writer =  try AVAssetWriter(url: _fileOutputURL, fileType: .m4v)
            } catch {
                print ("error with asset writer")
            }
            
            /*
            AVVideoCompressionPropertiesKey: @
            {
                AVVideoAverageBitRateKey: @6000000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
            },
             */
            
            let outputSettings =
                [
                    AVVideoCodecKey : AVVideoCodecType.h264,
                    AVVideoWidthKey : NSNumber(value: Float(self.size.width)),
                    AVVideoHeightKey : NSNumber(value: Float(self.size.height))
                ] as [String : Any]

            
            self.input = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
            
            
            let attributes = [
                kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32ARGB,
                kCVPixelBufferWidthKey : NSNumber(value: Float(self.size.width)),
                kCVPixelBufferHeightKey : NSNumber(value: Float(self.size.height))
            ] as [String : Any]

            self.adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.input, sourcePixelBufferAttributes: attributes)
            
            self._writer?.add(self.input)
            self.input.expectsMediaDataInRealTime = true
            _timeOfFirstFrame  = CFAbsoluteTimeGetCurrent()
            return self._writer!
        }
    }
    
    func createOutputUrl() -> String{
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first;
        
        var path = ""
        
        if let documentDirectory = documentDirectory {
            let intervalTimestamp = Date().timeIntervalSince1970;
            let filename = String(format: "star_%08x.mov", Int(intervalTimestamp))
            
            path = String(format: "%@/%@", documentDirectory, filename)
            
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: path) {
                do {
                    try fileManager.removeItem(atPath: path)
                } catch {
                    print ("error while removing")
                }
            }

        }
        
        print ("Output " + path)
        return path
        //return URL(fileURLWithPath: path)
    }
    
    let mediaQueue : DispatchQueue;
    
    init(){
        self.frameBuffer = [UIImage]();
        self._framesPerSecond = 30
        self._size = UIScreen.main.bounds.size;
        self._startDate = NSDate()
        self._endDate = NSDate()
        self._timeOfFirstFrame = 0.0;
        //self.
        mediaQueue = DispatchQueue(label: "mediaQueue");
    }
    
    func writeFrame(_ image : UIImage) {
        frameBuffer.append(image);
        //[self.frameBuffer addObject
    }
    
    func pixelBufferFromImage(img : UIImage) -> CVPixelBuffer{
        var buffer: CVPixelBuffer? = nil
        let status : CVReturn =  CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, self.adapter.pixelBufferPool!, &buffer)
        
        print ("status create  buffer ", 0 )
        
        if let buffer = buffer {
            let managedPixelBuffer = buffer
            CVPixelBufferLockBaseAddress(managedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0));
            let data    = CVPixelBufferGetBaseAddress(managedPixelBuffer);
            let colorSpace  = CGColorSpaceCreateDeviceRGB();
            
            let context   = CGContext(
                data: data,
                width: Int(self.size.width ),
                height: Int(self.size.height)  ,
                bitsPerComponent: 8,
                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                space: colorSpace,
                bitmapInfo: CGBitmapInfo.alphaInfoMask.rawValue & CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue).rawValue);
            
            context?.draw(img.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width, height:self.size.height));
            CVPixelBufferUnlockBaseAddress(managedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0));
        }
        return buffer!;
    }
    
    func writeVideoFromImages (callback : @escaping(String) -> Void) {
        if self.writer.startWriting(){
            self.writer.startSession(atSourceTime: kCMTimeZero)
            
            self.input.requestMediaDataWhenReady(on: mediaQueue) {
                self.mediaQueue.async {
                    var index : Int = 0;
                    while (!self.frameBuffer.isEmpty){
                        autoreleasepool{
                            if (self.input.isReadyForMoreMediaData){
                                let value = self.frameBuffer.remove(at: 0)
                                print ("Writing ", index, value)
                                let present : CMTime = CMTimeMake(Int64(index), Int32(self._framesPerSecond))
                                let buffer = self.pixelBufferFromImage(img: value);
                                
                                let appendSucceeded = self.adapter.append(buffer, withPresentationTime: present)
                                usleep(1000)
                                //print("input ready",  index)
                                index += 1;
                            } else {
                                //Thread.sleep(forTimeInterval: . )
                                usleep(1000)
                            }
                            
                        }
                    }
                        
                    self.input.markAsFinished()
                    self.writer.finishWriting {
                        callback(self._fileOutputPath)
                    }
                }
            }
        }
    }
    
}

@objc public class ViewRecorder : NSObject{
    var timer: DispatchSourceTimer?
    var sourceView : UIView!
    var writer : AssetWriter!;
    
    var callback : ((String) -> Void)!;
    
    override init() {
        super.init()
        self.writer = AssetWriter()
    }
    
    @objc public func start( view : UIView, withCallback : @escaping (String) -> Void  ) -> Void {
        self.callback = withCallback;
        self.sourceView = view
        self.writer.size = view.bounds.size;
        
        self.writer.size.width *= 2;
        self.writer.size.height  *= 2;
        
        //self.writer.framesPerSecond = 24;
        
        self.writer.framesPerSecond = 60 ;
        
        self.writer.startDate = NSDate()
        
        let queue = DispatchQueue.global(qos: .default)
        timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(), queue: queue)
        
        let repeatingTime : Int = 1000 / (self.writer.framesPerSecond);
    
        
        timer?.schedule(deadline: .now(), repeating: .milliseconds(repeatingTime) , leeway: DispatchTimeInterval.milliseconds(0))
        
        timer?.setEventHandler(handler: { [weak self] in
            DispatchQueue.main.sync {
                let image : UIImage = (self?.imageFromView((self?.sourceView!)!)!)!
                self?.writer.writeFrame(image);
            }
        })
        
        timer?.resume()
    }
    
    @objc func stop() {
        timer?.cancel()
        self.writer.endDate = NSDate()
        self.writer.writeVideoFromImages(callback: self.callback)
    }
    
    func imageFromView(_ view : UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true,  0);
        
        if (view.responds(to: #selector(view.drawHierarchy(in:afterScreenUpdates:)))){
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        } else {
            view.layer.render(in: UIGraphicsGetCurrentContext()!)
        }
        
        let rasterizedView = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return rasterizedView;
    }
}
