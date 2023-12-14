//
//  AstralNotifications.swift
//  astral
//
//  Created by Joseph Haygood on 8/30/23.
//

import Foundation

extension NSNotification.Name {
    static let playMap          = NSNotification.Name("playMap")
    static let saveFile         = NSNotification.Name("saveFile")
    static let loadFile         = NSNotification.Name("loadFile")
    static let stopMap          = NSNotification.Name("stopMap")
    static let layerAdded       = NSNotification.Name("layerAdded")
    static let pathApplyChanges = NSNotification.Name("pathApplyChanges")
    static let hideToolbar      = NSNotification.Name("hideToolbar")
}
