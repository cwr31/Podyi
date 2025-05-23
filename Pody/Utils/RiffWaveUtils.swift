import Foundation

// https://stackoverflow.com/questions/32036146/how-to-read-data-from-a-wav-file-to-an-array
// https://stackoverflow.com/questions/32036146/how-to-read-data-from-a-wav-file-to-an-array/32036376#32036376
func decodeWaveFile(_ url: URL) throws -> [Float] {
    let data = try Data(contentsOf: url)
    let floats = stride(from: 44, to: data.count, by: 2).map {
        data[$0 ..< $0 + 2].withUnsafeBytes {
            let short = Int16(littleEndian: $0.load(as: Int16.self))
            return max(-1.0, min(Float(short) / 32767.0, 1.0))
        }
    }
    return floats
}
