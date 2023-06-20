//
//  AstralBitmapFont.swift
//  astral
//
//  Created by Joseph Haygood on 5/21/23.
//

import Foundation
import SpriteKit

struct AstralBitmapFontCharacter {
    let id: Int
    let rect: CGRect
    let xOffset: CGFloat
    let yOffset: CGFloat
    let xAdvance: CGFloat
}



//
// Loads a .fnt file exported from bmGlyph
//
class AstralBitmapFont {
    var filename : String = ""
    var fileExtension : String = ".fnt"
    var characters: [Int: AstralBitmapFontCharacter] = [:]
    var spritesheet: SKTexture!
    
    //
    // Constructor
    //
    init(font filename: String, ext: String = ".fnt") {
        self.filename = filename
        self.fileExtension = ext
        self.loadFont(fromFile: filename)
    }
    
    
    
    //
    // Load characters from .fnt file into atlas
    //
    func loadFont(fromFile fileName: String, withExtension fileExtension: String = "fnt") {
        guard let fontURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Could not find font file")
            return
        }

        do {
            let fontFileContents = try String(contentsOf: fontURL)
            let lines = fontFileContents.split(separator: "\r\n")
            
            for line in lines {
                if line.hasPrefix("page") {
                    let name = line.split(separator: "=")
                    let name2 = name[2].split(separator: "\"")
                    self.spritesheet = SKTexture(imageNamed: String(name2[0]))
                } else if line.hasPrefix("char") {
                    let properties = line.split(separator: " ")
                    if properties.count < 9 {
                        continue
                    }
                        
                    let id = Int(properties[1].split(separator: "=")[1])!
                    let x = CGFloat(Int(properties[2].split(separator: "=")[1])!)
                    let y = CGFloat(Int(properties[3].split(separator: "=")[1])!)
                    let width = CGFloat(Int(properties[4].split(separator: "=")[1])!)
                    let height = CGFloat(Int(properties[5].split(separator: "=")[1])!)
                    let xOffset = CGFloat(Int(properties[6].split(separator: "=")[1])!)
                    let yOffset = CGFloat(Int(properties[7].split(separator: "=")[1])!)
                    let xAdvance = CGFloat(Int(properties[8].split(separator: "=")[1])!)
                    
                    let rect = CGRect(x: x, y: y, width: width, height: height)
                    let character = AstralBitmapFontCharacter(id: id, rect: rect, xOffset: xOffset, yOffset: yOffset, xAdvance: xAdvance)
                    self.characters[id] = character
                }
            }
        } catch {
            print("Error reading font file: \(error)")
        }
    }
    
    
    //
    // draw text using the font
    //
    func createLabel(withText text: String, maxWidth: CGFloat, scale: CGFloat = 1.0, color: SKColor = .white, typewriterDelay: TimeInterval = 0.05, soundFileName: String? = nil) -> SKNode {
        let labelNode = SKNode()
        var cursorX: CGFloat = 0
        var cursorY: CGFloat = 0
        var currentLineWidth: CGFloat = 0
        var charIndex = 0

        // Set up a buffer to hold the next word
        var wordBuffer: [Character] = []
        var wordWidth: CGFloat = 0.0

        for character in text {
            // If we encounter a space, we've hit the end of a word
            if character == " " || character == "\n" {
                processWordBuffer(wordBuffer: &wordBuffer, cursorX: &cursorX, cursorY: cursorY, currentLineWidth: &currentLineWidth, scale: scale, typewriterDelay: typewriterDelay, charIndex: &charIndex, soundFileName: soundFileName, labelNode: labelNode)
                wordWidth = 0.0

                // If it's a space character, add space
                if character == " " {
                    cursorX += 10 * scale
                    currentLineWidth += 10 * scale
                }

                // If it's a newline character, start a new line
                if character == "\n" {
                    cursorY -= 28 * scale
                    cursorX = 0
                    currentLineWidth = 0
                }
                // Insert a delay for space and newline characters
                let waitAction = SKAction.wait(forDuration: typewriterDelay)
                labelNode.run(waitAction)
                charIndex += 1
            } else {
                guard let asciiValue = character.asciiValue else { continue }
                let charId = Int(asciiValue)
                guard let bitmapFontChar = self.characters[charId] else { continue }
                wordBuffer.append(character)
                wordWidth += bitmapFontChar.xAdvance * scale

                // Check if adding this word would exceed the max width
                if currentLineWidth + wordWidth > maxWidth {
                    // Start a new line
                    cursorY -= 28 * scale
                    cursorX = 0
                    currentLineWidth = 0
                }
            }
        }

        // Don't forget to handle the last word if it's present
        if !wordBuffer.isEmpty {
            processWordBuffer(wordBuffer: &wordBuffer, cursorX: &cursorX, cursorY: cursorY, currentLineWidth: &currentLineWidth, scale: scale, typewriterDelay: typewriterDelay, charIndex: &charIndex, soundFileName: soundFileName, labelNode: labelNode)
        }

        return labelNode
    }






    
    
    
    func createCharacterSprite(character: AstralBitmapFontCharacter, position: CGPoint, scale: CGFloat, typewriterDelay: TimeInterval, charIndex: Int, soundFileName: String?) -> SKSpriteNode {
        let spriteNode = self.drawCharacter(character: character, position: position, scale: scale)
        spriteNode.alpha = 0

        let addAction = SKAction.run {
            spriteNode.alpha = 1.0
            if let soundFileName = soundFileName {
                spriteNode.run(SKAction.playSoundFileNamed(soundFileName, waitForCompletion: false))
            }
        }

        let waitAction = SKAction.wait(forDuration: typewriterDelay * Double(charIndex))
        spriteNode.run(SKAction.sequence([waitAction, addAction]))

        return spriteNode
    }
    
    
    func processWordBuffer(wordBuffer: inout [Character], cursorX: inout CGFloat, cursorY: CGFloat, currentLineWidth: inout CGFloat, scale: CGFloat, typewriterDelay: TimeInterval, charIndex: inout Int, soundFileName: String?, labelNode: SKNode) {
        for bufferChar in wordBuffer {
            guard let asciiValue = bufferChar.asciiValue else { continue }
            let charId = Int(asciiValue)
            guard let bitmapFontChar = self.characters[charId] else { continue }

            let position = CGPoint(x: cursorX, y: cursorY)
            let spriteNode = createCharacterSprite(character: bitmapFontChar, position: position, scale: scale, typewriterDelay: typewriterDelay, charIndex: charIndex, soundFileName: soundFileName)
            labelNode.addChild(spriteNode)

            cursorX += bitmapFontChar.xAdvance * scale
            currentLineWidth += bitmapFontChar.xAdvance * scale
            charIndex += 1
        }
        wordBuffer.removeAll()
    }
    
    
    
    //
    // add a character to a label
    //
    func drawCharacter(character: AstralBitmapFontCharacter, position: CGPoint, scale: CGFloat = 1.0) -> SKSpriteNode {
        let normalizedRect = self.normalize(rect: character.rect)
        let texture = SKTexture(rect: normalizedRect, in: spritesheet)
        let spriteNode = SKSpriteNode(texture: texture)
        spriteNode.anchorPoint = CGPoint(x: 0.0, y: 1.0)
        spriteNode.position = CGPoint(x: position.x + character.xOffset * scale, y: position.y - character.yOffset * scale)
        spriteNode.xScale = scale
        spriteNode.yScale = scale
        return spriteNode
    }
    
    
    /*
     *
     *   normalize(rect)
     *
     *      converts a rectangle's coordinates from the bitmap font's pixel coordinates
     *      to normalized coordinates, which are in the range [0, 1]. The origin's y-coordinate
     *      is negated to convert from the bitmap font's coordinate system (where y increases downward)
     *      to SpriteKit's coordinate system (where y increases upward).
     *      The rectangle's size is also normalized by dividing by the atlas texture's size.
     *
     */
    func normalize(rect: CGRect) -> CGRect {
        let textureSize = spritesheet.size()

        // Normalize the rectangle's origin
        let normalizedX = rect.origin.x / textureSize.width
        
        // Negating y due to SpriteKit's coordinate system
        let normalizedY = 1 - ((rect.origin.y + rect.size.height) / textureSize.height)

        // Normalize the rectangle's size
        let normalizedWidth = rect.size.width / textureSize.width
        let normalizedHeight = rect.size.height / textureSize.height

        return CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
    }
}
