//// AudioTrace.swift （Xcodeに貼る）
import Foundation
import QuartzCore   // 時間計測
import os

private let appStart = CACurrentMediaTime()

enum LogTag {
    static let audio = Logger(subsystem: "com.ototheory.app", category: "audio")
}

/// 時刻(ms)付きでログを出す。Xcodeのコンソールに表示されます。
func audioTrace(_ message: String) {
    let ms = Int((CACurrentMediaTime() - appStart) * 1000)
    print("[\(ms) ms] \(message)")
    LogTag.audio.info("[audio] \(message, privacy: .public)")
}

//  AudioTrace.swift.swift
//  OtoTheory
//
//  Created by Norito Harada on 2025/10/05.
//

