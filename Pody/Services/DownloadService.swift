//
//  DownloadService.swift
//  Pody
//
//  Created by cwr on 2023/6/20.
//

import Foundation
import Logging

class DownloadService: NSObject {
    let logger = Logger(label: "downloadService")

    //    private let progressHandler: ((URL, Double) -> Void)?
    //    private let completionHandler: ((URL, URL?, Error?) -> Void)?

    private let allowsCellularDownload: Bool
    private let DOWNLOAD_MAX_CONCURRENCY = 3

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "DownloadService_\(Date())")
        config.isDiscretionary = !allowsCellularDownload
        config.sessionSendsLaunchEvents = true
        config.allowsCellularAccess = allowsCellularDownload
        config.timeoutIntervalForRequest = 30
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    private var activeDownloads: [DownloadInfo] = []
    private var queuedDownloads = Set<DownloadInfo>()

    var activeCount: Int {
        activeDownloads.count
    }

    var queuedCount: Int {
        queuedDownloads.count
    }

    init(allowsCellularDownload: Bool) {
        self.allowsCellularDownload = allowsCellularDownload
    }

    func downloadFile(fromUrl: URL, toUrl: URL, progressHandler: @escaping (URL, Double) -> Void, completionHandler: @escaping (URL, URL, Error?) -> Void) {
        logger.info("start download from: \(fromUrl) to: \(toUrl))")

        var _info = DownloadInfo(fromUrl: fromUrl, toUrl: toUrl, progressHandler: progressHandler, completionHandler: completionHandler)
        /// 有同样的任务在等待，直接返回
        let temp = queuedDownloads.filter { $0 == _info }.count
        guard temp == 0 else {
            return
        }
        if activeCount < DOWNLOAD_MAX_CONCURRENCY {
            doDownloadFile(info: &_info)
        } else {
            queuedDownloads.insert(_info)
        }
    }

    func doDownloadFile(info: inout DownloadInfo) {
        /// 超过了3个任务正在运行，直接返回，等待下次被触发
        if activeCount >= DOWNLOAD_MAX_CONCURRENCY {
            return
        }
        var request = URLRequest(url: info.fromUrl)
        // HTTPHeaderFields?.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        let _task: URLSessionDownloadTask = session.downloadTask(with: request)
        _task.taskDescription = info.fromUrl.absoluteString

        info.task = _task

        queuedDownloads.remove(info)
        activeDownloads.append(info)
        _task.resume()
    }
}

extension DownloadService {
    struct DownloadInfo: Hashable {
        static func == (info1: DownloadService.DownloadInfo, info2: DownloadService.DownloadInfo) -> Bool {
            info1.fromUrl == info2.fromUrl && info1.toUrl == info2.toUrl
        }

        let fromUrl: URL
        let toUrl: URL
        var completionHandler: (URL, URL, Error?) -> Void
        var progressHandler: (URL, Double) -> Void
        var task: URLSessionDownloadTask?
        var progress: Double = 0.0
        var totalBytesExpected: Int64?

        func hash(into hasher: inout Hasher) {
            hasher.combine(fromUrl)
            hasher.combine(toUrl)
        }

        init(fromUrl: URL, toUrl: URL, progressHandler: @escaping (URL, Double) -> Void, completionHandler: @escaping (URL, URL, Error?) -> Void) {
            self.fromUrl = fromUrl
            self.toUrl = toUrl
            self.completionHandler = completionHandler
            self.progressHandler = progressHandler
            task = nil
        }
    }
}

extension DownloadService: URLSessionDownloadDelegate {
    // 下载任务完成时调用
    func urlSession(_: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let _info = activeDownloads.filter { $0.task == downloadTask }.first

        /// 将_info解包，给info，如果解包失败，说明_info为nil，执行else内代码
        guard var info = _info else {
            return
        }
        /// location是下载完成后的临时文件
        do {
            try FileManager.default.replaceItemAt(info.toUrl, withItemAt: location)
            logger.info("文件移动成功")
        } catch {
            logger.info("文件移动失败：\(error.localizedDescription)")
        }
        //        activeDownloads.remove(_info)

        /// 一个任务结束，执行下一个任务
        if activeCount < DOWNLOAD_MAX_CONCURRENCY, queuedCount > 0 {
            let _nextInfo = queuedDownloads.popFirst()
            if var nextInfo = _nextInfo {
                // _nextInfo 不为 nil，执行后续步骤
                doDownloadFile(info: &nextInfo)
            } else {
                // _nextInfo 为 nil，跳过后续步骤
            }
        }

        info.completionHandler(info.fromUrl, info.toUrl, nil)
    }

    // 下载任务进度更新时调用
    func urlSession(_: URLSession, downloadTask: URLSessionDownloadTask, didWriteData _: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let _info = activeDownloads.filter { $0.task == downloadTask }.first

        guard var info = _info else {
            return
        }

        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        info.progress = progress
        info.progressHandler(info.fromUrl, progress)
        //        progressHandler(_info!.fromUrl, progress)
    }

    // 下载任务恢复时调用
    func urlSession(_: URLSession, downloadTask _: URLSessionDownloadTask, didResumeAtOffset _: Int64, expectedTotalBytes _: Int64) {}

    // 下载任务完成时调用，用于处理文件存储和错误处理
    func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            let _info = activeDownloads.filter { $0.task == task }.first
            guard let info = _info else {
                return
            }
            info.completionHandler(info.fromUrl, info.toUrl, error)
        }
    }
}
