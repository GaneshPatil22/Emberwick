//
//  MemoryTokenContent.swift
//  Emberwick
//
//  What a flying memory token shows: a win's photo, its title on a paper card, or a
//  soft blurred-handwriting fallback for ambiance.
//

import Foundation

enum MemoryTokenContent: Hashable {
    case image(Data)
    case title(String)
    case fallback
}
