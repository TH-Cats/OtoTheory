# OtoTheory iOS - Current Preset Summary

## Purpose
I want to expand the chord progression presets in OtoTheory iOS app. Below is the current implementation with 20 patterns across 5 categories.

## Technical Context
- **Roman Numeral Notation**: Uppercase = Major (I, IV, V), Lowercase = Minor (ii, iii, vi)
- **Conversion**: Roman numerals are converted to actual chords based on selected key
  - Example in C major: `I` → C, `vi` → Am, `bVII` → Bb
- **Categories**: Rock, Pop, Blues, Ballad, Jazz (in this display order)
- **Target**: Add more useful, real-world progressions that musicians commonly use

## Current 20 Presets

### Rock (5 patterns)
1. **I–♭VII–IV (Mixo)** - `["I", "bVII", "IV"]`
   - Description: "Rock/Mixolydian feel. Sweet Child O' Mine"
   
2. **I–IV–V (Classic Rock)** - `["I", "IV", "V"]`
   - Description: "Classic rock. La Bamba, Twist and Shout"
   
3. **I–♭III–♭VII–IV (Aeolian)** - `["I", "bIII", "bVII", "IV"]`
   - Description: "Dark rock progression"
   
4. **vi–IV–V** - `["vi", "IV", "V"]`
   - Description: "Minor to major resolution"
   
5. **I–II (Phrygian)** - `["I", "II"]`
   - Description: "Phrygian color. Flamenco feel"

### Pop (4 patterns)
6. **I–V–vi–IV (Canon)** - `["I", "V", "vi", "IV"]`
   - Description: "Most popular progression. Let It Be, Don't Stop Believin'"
   
7. **I–vi–IV–V (50s)** - `["I", "vi", "IV", "V"]`
   - Description: "50s doo-wop classic. Stand By Me"
   
8. **vi–IV–I–V (Axis)** - `["vi", "IV", "I", "V"]`
   - Description: "Axis progression. With Or Without You"
   
9. **I–IV–vi–V** - `["I", "IV", "vi", "V"]`
   - Description: "Bright and uplifting"

### Blues (2 patterns)
10. **12-bar Blues** - `["I", "I", "I", "I", "IV", "IV", "I", "I", "V", "IV", "I", "V"]`
    - Description: "Standard 12-bar blues"
    
11. **8-bar Blues** - `["I", "I", "IV", "IV", "I", "V", "I", "V"]`
    - Description: "Shorter blues form"

### Ballad (5 patterns)
12. **I–iii–IV–V** - `["I", "iii", "IV", "V"]`
    - Description: "Smooth ascending ballad"
    
13. **I–IV–I–V (Simple)** - `["I", "IV", "I", "V"]`
    - Description: "Simple and clear"
    
14. **vi–V–IV–V** - `["vi", "V", "IV", "V"]`
    - Description: "Melancholic ballad"
    
15. **I–V–IV** - `["I", "V", "IV"]`
    - Description: "Three-chord ballad"
    
16. **I–vi–iii–IV (Descending)** - `["I", "vi", "iii", "IV"]`
    - Description: "Descending thirds"

### Jazz (4 patterns)
17. **ii–V–I (Jazz)** - `["ii", "V", "I"]`
    - Description: "Jazz turnaround. Most common in standards"
    
18. **ii–V–I–vi** - `["ii", "V", "I", "vi"]`
    - Description: "Extended jazz turnaround"
    
19. **iii–vi–ii–V (Circular)** - `["iii", "vi", "ii", "V"]`
    - Description: "Circular progression. Autumn Leaves"
    
20. **I–vi–ii–V** - `["I", "vi", "ii", "V"]`
    - Description: "Jazz classic. Blue Moon"

## Request for ChatGPT
Please suggest **10-15 additional useful chord progressions** that:
1. Are commonly used in real songs across various genres (R&B, Soul, Gospel, Country, EDM, etc.)
2. Include interesting variations (chromatic movements, borrowed chords, modal interchange)
3. Are practical for songwriting and music production
4. Include famous song examples if possible
5. Cover different lengths (2-8 chords)

Please provide in this format:
```
Category: [Rock/Pop/Blues/Ballad/Jazz/Other]
Name: [Short descriptive name]
Roman Numerals: [Array of Roman numerals]
Description: [One-line description with song example]
```

## Notes
- Users can select any key (C, C#, D, etc.) and the progressions will be transposed automatically
- The app converts Roman numerals to actual chord symbols (e.g., `I` in C = C, `ii` in C = Dm)
- Target audience: songwriters, producers, guitarists, pianists


