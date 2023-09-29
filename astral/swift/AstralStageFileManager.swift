//
//  AstralStageFileManager.swift
//  astral
//
//  Created by Joseph Haygood on 9/20/23.
//hy 

import Foundation

class AstralStageFileManager {
    
    /// Saves the stage data to disk.
    /// - Parameter stageData: The data to save.
    /// - Parameter filename: The name of the file to write.
    func saveStage(stageData: AstralStageData, filename: String) {
        do {
            let jsonData = try JSONEncoder().encode(stageData)
            let filePath = getDocumentsDirectory().appendingPathComponent(filename)
            try jsonData.write(to: filePath)
            print("Saved stage data to \(filePath)")
        } catch {
            print("Couldn't save file: \(error)")
        }
    }
    
    /// Loads the stage data from disk.
    /// - Parameter fileName: The name of the file to load.
    /// - Returns: The loaded stage data, or nil if the load fails.
    func loadStage(filename: String) -> AstralStageData? {
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        
        do {
            let jsonData = try Data(contentsOf: filePath)
            let loadedStageData = try JSONDecoder().decode(AstralStageData.self, from: jsonData)
            return loadedStageData
        } catch {
            print("Couldn't load file: \(error)")
            return nil
        }
    }

    /// Gets the documents directory path.
    /// - Returns: The URL of the documents directory.
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

