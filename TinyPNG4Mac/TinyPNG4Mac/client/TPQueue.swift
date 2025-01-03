//
//  TPQueue.swift
//  tinypng
//
//  Created by kyle on 16/6/30.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Foundation

struct TPQueue<Element: Equatable> {
    private var queue: [Element] = []

    mutating func enqueue(_ object: Element) {
        queue.append(object)
    }

    mutating func dequeue() -> Element? {
        guard !queue.isEmpty else { return nil }
        return queue.removeFirst()
    }

    func isEmpty() -> Bool {
        return queue.isEmpty
    }

    func peek() -> Element? {
        return queue.first
    }

    func size() -> Int {
        return queue.count
    }
    
    func contains(_ element: Element) -> Bool {
        return queue.contains { e in
            e == element
        }
    }
    
    mutating func removeAll() {
        queue.removeAll()
    }
}
