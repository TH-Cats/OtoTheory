import Foundation
import JavaScriptCore

class TheoryBridge {
    private let context: JSContext
    
    init?() {
        guard let context = JSContext() else {
            print("❌ Failed to create JSContext")
            return nil
        }
        self.context = context
        
        // エラーハンドリング
        context.exceptionHandler = { context, exception in
            if let exc = exception {
                print("❌ JS Error: \(exc)")
            }
        }
        
        // JSファイルの読み込み
        guard let jsPath = Bundle.main.path(forResource: "ototheory-core", ofType: "js") else {
            print("❌ JS file not found in bundle")
            print("   Bundle path: \(Bundle.main.bundlePath)")
            if let resourcePath = Bundle.main.resourcePath {
                print("   Resource path: \(resourcePath)")
                if let files = try? FileManager.default.contentsOfDirectory(atPath: resourcePath) {
                    print("   Files in bundle: \(files.filter { $0.hasSuffix(".js") })")
                }
            }
            return nil
        }
        
        print("✅ Found JS file at: \(jsPath)")
        
        guard let jsCode = try? String(contentsOfFile: jsPath, encoding: .utf8) else {
            print("❌ Failed to read JS file")
            return nil
        }
        
        print("✅ JS file loaded, size: \(jsCode.count) bytes")
        
        // JS実行
        context.evaluateScript(jsCode)
        
        // OtoCore の構造を確認
        let checkScript = """
        (function() {
            if (typeof OtoCore === 'undefined') {
                return 'OtoCore is undefined';
            }
            const keys = Object.keys(OtoCore);
            return 'OtoCore keys: ' + keys.join(', ');
        })()
        """
        
        if let checkResult = context.evaluateScript(checkScript) {
            print("🔍 \(checkResult.toString() ?? "nil")")
        }
        
        print("✅ TheoryBridge initialized successfully")
    }
    
    // Chord parsing
    func parseChord(_ symbol: String) -> ChordInfo? {
        let script = """
        (function() {
            try {
                const result = OtoCore.parseChord('\(symbol)');
                return JSON.stringify(result);
            } catch (e) {
                return JSON.stringify({ error: e.message });
            }
        })()
        """
        
        guard let result = context.evaluateScript(script),
              let jsonString = result.toString(),
              let jsonData = jsonString.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            print("❌ Failed to parse chord result")
            return nil
        }
        
        if dict["error"] != nil {
            print("❌ JS Error in parseChord: \(dict["error"] ?? "unknown")")
            return nil
        }
        
        return ChordInfo(
            root: dict["root"] as? String ?? "",
            quality: dict["quality"] as? String ?? "",
            bass: dict["bass"] as? String
        )
    }
    
    // Diatonic chords
    func getDiatonicChords(key: String, scale: String) -> [String] {
        let script = """
        (function() {
            try {
                const result = OtoCore.getDiatonicChords('\(key)', '\(scale)');
                console.log('getDiatonicChords result:', result);
                return JSON.stringify(result);
            } catch (e) {
                console.log('getDiatonicChords error:', e.message);
                return JSON.stringify([]);
            }
        })()
        """
        
        guard let result = context.evaluateScript(script),
              let jsonString = result.toString(),
              let jsonData = jsonString.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: jsonData) as? [String] else {
            print("❌ Failed to parse diatonic chords result")
            return []
        }
        
        print("✅ getDiatonicChords returned \(array.count) chords: \(array)")
        return array
    }
    
    func analyzeProgression(_ chords: [String]) -> [KeyCandidate] {
        let chordsJSON = chords.map { "\"\($0)\"" }.joined(separator: ",")
        let script = """
        (function() {
            try {
                const result = OtoCore.analyzeProgression([\(chordsJSON)]);
                return JSON.stringify(result);
            } catch (e) {
                return JSON.stringify({ error: e.message });
            }
        })()
        """
        
        guard let result = context.evaluateScript(script),
              let jsonString = result.toString(),
              let jsonData = jsonString.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            print("❌ Failed to parse analyze result")
            return []
        }
        
        return array.compactMap { dict in
            guard let tonic = dict["tonic"] as? String,
                  let mode = dict["mode"] as? String,
                  let confidence = dict["confidence"] as? Int,
                  let reasons = dict["reasons"] as? [String] else {
                return nil
            }
            return KeyCandidate(tonic: tonic, mode: mode, confidence: confidence, reasons: reasons)
        }
    }
    
    func scoreScales(_ chords: [String], key: String, mode: String) -> [ScaleCandidate] {
        let chordsJSON = chords.map { "\"\($0)\"" }.joined(separator: ",")
        let script = """
        (function() {
            try {
                const result = OtoCore.scoreScales([\(chordsJSON)], { root: '\(key)', mode: '\(mode)' });
                return JSON.stringify(result);
            } catch (e) {
                return JSON.stringify({ error: e.message });
            }
        })()
        """
        
        guard let result = context.evaluateScript(script),
              let jsonString = result.toString(),
              let jsonData = jsonString.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            print("❌ Failed to parse scoreScales result")
            return []
        }
        
        return array.compactMap { dict in
            guard let root = dict["root"] as? String,
                  let type = dict["type"] as? String,
                  let score = dict["score"] as? Int else {
                return nil
            }
            return ScaleCandidate(root: root, type: type, score: score)
        }
    }
}

// Models
struct ChordInfo {
    let root: String
    let quality: String
    let bass: String?
}

struct KeyCandidate {
    let tonic: String
    let mode: String
    let confidence: Int
    let reasons: [String]
}

struct ScaleCandidate {
    let root: String
    let type: String
    let score: Int
}
