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
        guard let jsPath = Bundle.main.path(forResource: "ototheory-core", ofType: "js"),
              let jsCode = try? String(contentsOfFile: jsPath) else {
            print("❌ Failed to load JS bundle")
            return nil
        }
        
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
}

// Models
struct ChordInfo {
    let root: String
    let quality: String
    let bass: String?
}
