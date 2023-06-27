//
//  WhisperApi.swift
//  Pody
//
//  Created by cwr on 2023/6/19.
//

import BackgroundTasks
import Foundation
import Logging
import SwiftWhisper
import Zip

func doTranscription(on _: URL) async {
    let logger = Logger(label: "whisperService")
    let params = WhisperParams()
    params.language = .english
    params.n_threads = 6
//    params.max_len = 1
//    params.token_timestamps = true

    let home = NSHomeDirectory() as NSString
    logger.info("\(home)")
    //    let bundle = Bundle.main.bundlePath

    let modelFileUrl = URL(string: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en.bin")!
    let modelFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ggml-tiny.en.bin")

    let modelCoremlFileZipUrl = URL(string: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en-encoder.mlmodelc.zip")!
    let modelCoremlFileZipPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ggml-tiny.en-encoder.mlmodelc.zip")
    let modelCoremlFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ggml-tiny.en-encoder.mlmodelc")

    let wavFileUrl = URL(string: "http://192.168.123.2:5244/d/ALLE1323962167.mp3")!
    let wavFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3")

    logger.info("modelFileUrl: \(modelFileUrl)")
    logger.info("modelFilePath: \(modelFilePath)")
    logger.info("modelCoremlFileZipUrl: \(modelCoremlFileZipUrl)")
    logger.info("modelCoremlFileZipPath: \(modelCoremlFileZipPath)")
    logger.info("modelCoremlFilePath: \(modelCoremlFilePath)")
    logger.info("modelCoremlFilePath: \(modelCoremlFilePath.deletingLastPathComponent())")
    logger.info("modelCoremlFilePath: \(modelCoremlFilePath.deletingPathExtension())")
    logger.info("wavFileUrl: \(wavFileUrl)")
    logger.info("wavFilePath: \(wavFilePath)")

//    let wavFileUrl = URL(string:"http://192.168.123.2:5244/d/jfk.wav")!
//    let wavFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("jfk.wav")

    var modelFileExisted = FileManager.default.fileExists(atPath: modelFilePath.path)
    var wavFileExisted = FileManager.default.fileExists(atPath: wavFilePath.path)

    let downloadService = DownloadService(allowsCellularDownload: true)
    var wavDownloadStarted = false
    var wavProcessStarted = false
    downloadModelFile()

    func downloadModelFile() {
        if !FileManager.default.fileExists(atPath: modelFilePath.path) {
            logger.info("modelCoremlFile not existed: \(modelFilePath.absoluteString)")
            downloadService.downloadFile(fromUrl: modelFileUrl, toUrl: modelFilePath, progressHandler: { _, progress in
                logger.info("modelFile download progress: \(progress * 100)%")
            }) { _, toUrl, error in
                if let error {
                    logger.info("modelFile download error: \(error.localizedDescription)")
                } else {
                    logger.info("modelFile download completed: \(toUrl.absoluteString)")
                    downloadCoremlFile()
                }
            }
        } else {
            logger.info("modelCoremlFile existed: \(modelFilePath.absoluteString)")
            downloadCoremlFile()
        }
    }

    func downloadCoremlFile() {
        if !FileManager.default.fileExists(atPath: modelCoremlFilePath.path) {
            logger.info("modelCoremlFile not existed: \(modelCoremlFilePath.absoluteString)")
            downloadService.downloadFile(fromUrl: modelCoremlFileZipUrl, toUrl: modelCoremlFileZipPath, progressHandler: { _, progress in
                logger.info("modelCoremlFile download progress: \(progress * 100)%")
            }) { _, toUrl, error in
                if let error {
                    logger.info("modelCoremlFile download error: \(error.localizedDescription)")
                } else {
                    logger.info("modelCoremlFile download completed: \(toUrl.absoluteString)")
                    do {
                        try Zip.unzipFile(modelCoremlFileZipPath, destination: modelCoremlFilePath.deletingLastPathComponent(), overwrite: true, password: nil)
                        try FileManager.default.removeItem(at: modelCoremlFilePath)
//                        print("Unzipped at path: \(unzipDirectory.path)")
                    } catch {
                        print("Error unzipping file: \(error)")
                    }
                    downloadAudioFile()
                }
            }
        } else {
            logger.info("modelCoremlFile existed: \(modelCoremlFilePath.absoluteString)")
            downloadAudioFile()
        }
    }

    func downloadAudioFile() {
        if !FileManager.default.fileExists(atPath: wavFilePath.path) {
            logger.info("wavFile not existed: \(wavFilePath.absoluteString)")
            logger.info("wavFile is \(wavDownloadStarted)")
//            if !wavDownloadStarted{
            wavDownloadStarted = true
            logger.info("wavFile1 is \(wavDownloadStarted)")
            downloadService.downloadFile(fromUrl: wavFileUrl, toUrl: wavFilePath, progressHandler: { _, progress in
                logger.info("wavFile download progress: \(progress * 100)%")
            }, completionHandler: { _, _, error in
                if let error {
                    logger.info("wavFile download error: \(error.localizedDescription)")
                } else {
                    logger.info("wavFile download ok")
                    doTrans()
                }
            })
//            }
        } else {
            logger.info("wavFile existed: \(wavFilePath.absoluteString)")
            doTrans()
        }
    }

    func doTrans() {
//        if !wavProcessStarted{
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
                case let .success(pcmArray):
                    // 获取到[Float]类型的结果
                    logger.info("convert to pcm succeed")
                    logger.info("transcribe start")
                    let segments = try await whisper.transcribe(audioFrames: pcmArray)
                    /// 给个默认值0，没意义，后面会改
                    let subtitles = segments.map { Subtitle(index: 0, startTime: TimeInterval($0.startTime / 1000), endTime: TimeInterval($0.endTime / 1000), text: $0.text) }

                    subtitlesToSrt(subtitles: subtitles, filePath: wavFilePath.deletingPathExtension().appendingPathExtension("en.srt"))
                case let .failure(error):
                    // 处理错误情况
                    logger.info("转换失败: \(error)")
                }
            }
        }
//        }
    }
}

class MyWhisperDelegate: WhisperDelegate {
    func whisper(_: Whisper, didUpdateProgress progress: Double) {
        logger.info("transcribe progress: \(progress * 100)%")
    }

    func whisper(_: Whisper, didProcessNewSegments _: [Segment], atIndex _: Int) {
//        logger.info("process atIndex: \(index)")
    }

    func whisper(_: Whisper, didCompleteWithSegments segments: [Segment]) {
        logger.info("transcribe succeed, total segment count: \(segments.count)")
    }

    func whisper(_: Whisper, didErrorWith error: Error) {
        logger.info("transcribe failed with error: \(error)")
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
            data[$0 ..< $0 + 2].withUnsafeBytes {
                let short = Int16(littleEndian: $0.load(as: Int16.self))
                return max(-1.0, min(Float(short) / 32767.0, 1.0))
            }
        }

        try? FileManager.default.removeItem(at: tempURL)

        completionHandler(.success(floats))
    }
}
