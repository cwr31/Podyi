// //
// //  WhisperServiceV2.swift
// //  Pody
// //
// //  Created by cwr on 2023/6/25.
// //

// import Foundation
// import whisper

// func doTrans() {

//     let modelFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ggml-tiny.bin")
//     let wavFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3")
//     // let ctx = whisper_init_from_file("models/for-tests-ggml-base.en.bin")
//     let ctx = modelFilePath.relativePath.withCString { whisper_init_from_file($0) }

//     var params = whisper_full_default_params(WHISPER_SAMPLING_GREEDY)

//     params.print_realtime   = true
//     params.print_progress   = false
//     params.print_timestamps = true
//     params.print_special    = false
//     params.translate        = false
//     //params.language         = "en";
//     params.n_threads        = 4
//     params.offset_ms        = 0

//     // let n_samples = Int32(WHISPER_SAMPLE_RATE)
//     // let pcmf32 = [Float](repeating: 0, count: Int(n_samples))

//     convertAudioFileToPCMArray(fileURL: wavFilePath) { result in
//                     switch result {
//                     case .success(let pcmArray):
//                         // 获取到[Float]类型的结果
//                         logger.info("convert to pcm ++++++++ succeed")
//                         let ret = whisper_full(ctx, params, pcmArray, Int32(pcmArray.count))
//                         assert(ret == 0, "Failed to run the model")

//                         let n_segments = whisper_full_n_segments(ctx)

//                         for i in 0..<n_segments {
//                             let text_cur = whisper_full_get_segment_text(ctx, i)
//                             print(text_cur as Any)
//                         }
//                         logger.info("convert to segments ++++++++ succeed")
//                         /// 给个默认值0，没意义，后面会改
//                         // let subtitles = segments.map{Subtitle(index: 0, startTime: TimeInterval($0.startTime / 1000), endTime: TimeInterval($0.endTime / 1000), text: $0.text)}

//                         // subtitlesToSrt(subtitles: subtitles, filePath: wavFilePath.deletingPathExtension().appendingPathExtension("en.srt"))
//                         // logger.info("Transcribed audio: \(segments.map(\.text).joined())")
//                     case .failure(let error):
//                         // 处理错误情况
//                         logger.info("转换失败: \(error)")
//                     }
//     }
//     whisper_print_timings(ctx)
//     whisper_free(ctx)
// }

// import AudioKit

// func convertAudioFileToPCMArray(fileURL: URL, completionHandler: @escaping (Result<[Float], Error>) -> Void) {
//     var options = FormatConverter.Options()
//     options.format = .wav
//     options.sampleRate = 16000
//     options.bitDepth = 16
//     options.channels = 1
//     options.isInterleaved = false

//     let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
//     let converter = FormatConverter(inputURL: fileURL, outputURL: tempURL, options: options)
//     converter.start { error in
//         if let error {
//             completionHandler(.failure(error))
//             return
//         }

//         let data = try! Data(contentsOf: tempURL) // Handle error here

//         let floats = stride(from: 44, to: data.count, by: 2).map {
//             return data[$0..<$0 + 2].withUnsafeBytes {
//                 let short = Int16(littleEndian: $0.load(as: Int16.self))
//                 return max(-1.0, min(Float(short) / 32767.0, 1.0))
//             }
//         }

//         try? FileManager.default.removeItem(at: tempURL)

//         completionHandler(.success(floats))
//     }
// }
