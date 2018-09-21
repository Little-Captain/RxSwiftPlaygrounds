//: Playground - noun: a place where people can play

import Foundation

let stringArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
let fullFilter = stringArray.flatMap { Int($0) }.filter { $0 % 2 == 0 }
print(fullFilter)

let partialFilter = stringArray[4..<stringArray.count].flatMap { Int($0) }.filter { $0 % 2 == 0 }
print(partialFilter)
