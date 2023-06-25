//
//  WhisperApi.swift
//  Pody
//
//  Created by cwr on 2023/6/19.
//

import Foundation
import SwiftWhisper
import Logging
import BackgroundTasks


func doTranscription(on audioFileURL:URL) async {
    
    let logger = Logger(label: "whisperService")
    let params = WhisperParams()
    params.language = .english
    params.n_threads = 6
//    params.max_len = 1
//    params.token_timestamps = true
    
    let home = NSHomeDirectory() as NSString
    logger.info("\(home)")
    //    let bundle = Bundle.main.bundlePath
    
    let modelFileUrl = URL(string:"https://huggingface.co/guillaumekln/faster-whisper-small/resolve/main/ggml-tiny.bin")!
    let modelFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ggml-tiny.bin")
    
    let wavFileUrl = URL(string:"http://192.168.123.2:5244/d/ALLE1323962167.mp3")!
    let wavFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3")

//    let wavFileUrl = URL(string:"http://192.168.123.2:5244/d/jfk.wav")!
//    let wavFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("jfk.wav")
    
    var modelFileExisted = FileManager.default.fileExists(atPath: modelFilePath.path)
    var wavFileExisted = FileManager.default.fileExists(atPath: wavFilePath.path)
    
    
    let downloadService = DownloadService(allowsCellularDownload: true)
    var wavDownloadStarted = false
    var wavProcessStarted = false
    logger.info("modelFile download start")
    
    if !FileManager.default.fileExists(atPath: modelFilePath.path) {
        downloadService.downloadFile(fromUrl: modelFileUrl, toUrl: modelFilePath, progressHandler: {(fromUrl, progress) in
            logger.info("modelFile download progress: \(progress * 100)%")
        }) { fromUrl, toUrl, error in
            if let error = error {
                logger.info("modelFile download error: \(error.localizedDescription)")
            } else {
                logger.info("modelFile download completed: \(toUrl.absoluteString)")
                downloadAudioFile()
            }
        }
    } else{
        logger.info("modelFile existed")
        downloadAudioFile()
    }
    
    func downloadAudioFile() {
        if !FileManager.default.fileExists(atPath: wavFilePath.path) {
            logger.info("wavFile download start")
            logger.info("wavFile is \(wavDownloadStarted)")
            if !wavDownloadStarted{
                wavDownloadStarted = true
                logger.info("wavFile1 is \(wavDownloadStarted)")
                downloadService.downloadFile(fromUrl: wavFileUrl, toUrl: wavFilePath, progressHandler: { (fromUrl,progress) in
                    logger.info("wavFile download progress: \(progress * 100)%")
                },  completionHandler: { (fromUrl, toUrl, error) in
                    if let error = error {
                        logger.info("wavFile download error: \(error.localizedDescription)")
                    } else {
                        logger.info("wavFile download ok")
                        doTrans()
                    }
                })
            }
        } else {
            logger.info("audio file existed")
            doTrans()
        }
    }
    
    func doTrans() {
        if !wavProcessStarted{
            wavProcessStarted = true
            let whisper = Whisper(fromFileURL: modelFilePath, withParams: params)
            let delegateObject = MyWhisperDelegate()
            whisper.delegate = delegateObject
            convertAudioFileToPCMArray(fileURL: wavFilePath) { result in
                let request = BGProcessingTaskRequest(identifier: "whisper")
                request.requiresNetworkConnectivity = true // Need to true if your task need to network process. Defaults to false.
                request.requiresExternalPower = true // Need to true if your task requires a device connected to power source. Defaults to false.

                request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60) // Process after 5 minutes.

                do {
                    try BGTaskScheduler.shared.submit(request)
                } catch {
                    print("Could not schedule image fetch: (error)")
                }
                Task {
                    switch result {
                    case .success(let pcmArray):
                        // 获取到[Float]类型的结果
                        logger.info("convert to pcm ++++++++ succeed")
                        //                                        logger.info(pcmArray)
                        let segments = try await whisper.transcribe(audioFrames: pcmArray)
                        
                        whisper.transcribe(audioFrames: pcmArray) { result in
                            switch result {
                            case .success(let segments):
                                // 处理转录成功的结果
                                print("转录成功，共得到 \(segments.count) 个片段")
                            case .failure(let error):
                                // 处理转录失败的错误
                                print("转录失败：\(error)")
                            }
                        }
                        logger.info("convert to segments ++++++++ succeed")
                        /// 给个默认值0，没意义，后面会改
                        let subtitles = segments.map{Subtitle(index: 0, startTime: TimeInterval($0.startTime / 1000), endTime: TimeInterval($0.endTime / 1000), text: $0.text)}

                        subtitlesToSrt(subtitles: subtitles, filePath: wavFilePath.deletingPathExtension().appendingPathExtension("en.srt"))
                        logger.info("Transcribed audio: \(segments.map(\.text).joined())")
                    case .failure(let error):
                        // 处理错误情况
                        logger.info("转换失败: \(error)")
                    }
                }
            }
        }
    }
}



class MyWhisperDelegate: WhisperDelegate {
    func whisper(_ whisper: Whisper, didUpdateProgress progress: Double) {
        logger.info("转录进度：\(progress * 100)%")
    }
    
    func whisper(_ aWhisper: Whisper, didProcessNewSegments segments: [Segment], atIndex index: Int) {
        logger.info("process atIndex: \(index)")
    }

    func whisper(_ aWhisper: Whisper, didCompleteWithSegments segments: [Segment]) {
        logger.info("Transcribed audio: \(segments.map(\.text).joined())")
    }
}


import AudioKit

func convertAudioFileToPCMArray(fileURL: URL, completionHandler: @escaping (Result<[Float], Error>) -> Void) {
    var options = FormatConverter.Options()
    options.format = .wav
    options.sampleRate = 16000
    options.bitDepth = 16
    options.channels = 1
    options.isInterleaved = false
    
    let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
    let converter = FormatConverter(inputURL: fileURL, outputURL: tempURL, options: options)
    converter.start { error in
        if let error {
            completionHandler(.failure(error))
            return
        }
        
        let data = try! Data(contentsOf: tempURL) // Handle error here
        
        let floats = stride(from: 44, to: data.count, by: 2).map {
            return data[$0..<$0 + 2].withUnsafeBytes {
                let short = Int16(littleEndian: $0.load(as: Int16.self))
                return max(-1.0, min(Float(short) / 32767.0, 1.0))
            }
        }
        
        try? FileManager.default.removeItem(at: tempURL)
        
        completionHandler(.success(floats))
    }
}

