//
//  main.swift
//  AOC1913
//
//  Created by Heiko Goes on 23.12.19.
//  Copyright © 2019 Heiko Goes. All rights reserved.
//

enum Opcode: Int {
    case Add = 1
    case Multiply = 2
    case Halt = 99
    case Input = 3
    case Output = 4
    case JumpIfTrue = 5
    case JumpIfFalse = 6
    case LessThan = 7
    case Equals = 8
    case AdjustRelativeBase = 9
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}

struct ParameterModes {
    let digits: String
    private var parameterPointer: Int
    
    init(digits: String) {
        self.digits = digits
        parameterPointer = digits.count - 1
    }
    
    mutating func getNext() -> ParameterMode {
        let digit = parameterPointer >= 0 ? digits[parameterPointer...parameterPointer] : "0"
        parameterPointer -= 1
        
        return ParameterMode(rawValue: Int(digit)!)!
    }
}

enum ParameterMode: Int {
    case Position = 0
    case Immediate = 1
    case Relative = 2
}

struct Program {
    private(set) var memory: [Int]
    private var instructionPointer = 0
    private var relativeBase = 0
    
    public mutating func getNextParameter(parameterMode: ParameterMode) -> Int {
        var parameter: Int
        switch parameterMode {
            case .Position:
                parameter = memory[memory[instructionPointer]]
            case .Immediate:
                parameter = memory[instructionPointer]
            case .Relative:
                parameter = memory[memory[instructionPointer] + relativeBase]
        }
        
        instructionPointer += 1
        return parameter
    }
    
    public mutating func run(input: Int) -> Int? {
        repeat {
            var startString = String(memory[instructionPointer])
            if startString.count == 1 {
                startString = "0" + startString
            }
            
            instructionPointer += 1
            
            let opcode = Opcode(rawValue: Int(startString[startString.count - 2...startString.count - 1])!)!
            if opcode == .Halt {
                return nil
            }
            
            var parameterModes = startString.count >= 3 ? ParameterModes(digits: startString[0...startString.count - 3]) : ParameterModes(digits: "")
            
            switch opcode {
                case .Add:
                    let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                    let parameter2 = getNextParameter(parameterMode: parameterModes.getNext())
                    let parameter3 = getNextParameter(parameterMode: .Immediate)
                    
                    let parameterMode = parameterModes.getNext()
                    if parameterMode == .Relative {
                        memory[parameter3 + relativeBase] = parameter1 + parameter2
                    } else {
                        memory[parameter3] = parameter1 + parameter2
                    }
                case .Multiply:
                    let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                    let parameter2 = getNextParameter(parameterMode: parameterModes.getNext())
                    let parameter3 = getNextParameter(parameterMode: .Immediate)
                    
                    let parameterMode = parameterModes.getNext()
                    if parameterMode == .Relative {
                        memory[parameter3 + relativeBase] = parameter1 * parameter2
                    } else {
                        memory[parameter3] = parameter1 * parameter2
                    }
                case .Halt: ()
                case .Input:
                    let parameter = getNextParameter(parameterMode: .Immediate)
                    let parameterMode = parameterModes.getNext()
                    if parameterMode == .Relative {
                        memory[parameter + relativeBase] = input
                    } else {
                        memory[parameter] = input
                    }
                case .Output:
                    let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                    return parameter1
                    //print(parameter1)
                case .JumpIfTrue:
                    let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                    if parameter1 != 0 {
                        let parameter2 = getNextParameter(parameterMode: parameterModes.getNext())
                        instructionPointer = parameter2
                    } else {
                        instructionPointer += 1
                    }
                case .JumpIfFalse:
                    let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                    if parameter1 == 0 {
                        let parameter2 = getNextParameter(parameterMode: parameterModes.getNext())
                        instructionPointer = parameter2
                    } else {
                        instructionPointer += 1
                    }
                case .LessThan:
                    let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                    let parameter2 = getNextParameter(parameterMode: parameterModes.getNext())
                    let parameter3 = getNextParameter(parameterMode: .Immediate)
                    
                    let parameterMode = parameterModes.getNext()
                    let value = parameter1 < parameter2 ? 1 : 0
                    if parameterMode == .Relative {
                        memory[parameter3 + relativeBase] = value
                    } else {
                        memory[parameter3] = value
                    }
                case .Equals:
                   let parameter1 = getNextParameter(parameterMode: parameterModes.getNext())
                   let parameter2 = getNextParameter(parameterMode: parameterModes.getNext())
                   let parameter3 = getNextParameter(parameterMode: .Immediate)
                   
                   let parameterMode = parameterModes.getNext()
                   let value = parameter1 == parameter2 ? 1 : 0
                   if parameterMode == .Relative {
                        memory[parameter3 + relativeBase] = value
                   } else {
                        memory[parameter3] = value
                    }
                case .AdjustRelativeBase:
                   let parameter = getNextParameter(parameterMode: parameterModes.getNext())
                   relativeBase += parameter
            }
        } while true
    }
    
    init(memory: String) {
        self.memory = memory
            .split(separator: ",")
            .map{ Int($0)! }
    }
}

let memoryString = """
1,380,379,385,1008,2151,549350,381,1005,381,12,99,109,2152,1102,1,0,383,1101,0,0,382,21002,382,1,1,21001,383,0,2,21101,37,0,0,1106,0,578,4,382,4,383,204,1,1001,382,1,382,1007,382,36,381,1005,381,22,1001,383,1,383,1007,383,21,381,1005,381,18,1006,385,69,99,104,-1,104,0,4,386,3,384,1007,384,0,381,1005,381,94,107,0,384,381,1005,381,108,1105,1,161,107,1,392,381,1006,381,161,1101,-1,0,384,1106,0,119,1007,392,34,381,1006,381,161,1102,1,1,384,20101,0,392,1,21102,19,1,2,21102,1,0,3,21101,0,138,0,1106,0,549,1,392,384,392,21002,392,1,1,21101,19,0,2,21102,3,1,3,21102,161,1,0,1106,0,549,1102,0,1,384,20001,388,390,1,21002,389,1,2,21101,0,180,0,1105,1,578,1206,1,213,1208,1,2,381,1006,381,205,20001,388,390,1,20102,1,389,2,21101,205,0,0,1105,1,393,1002,390,-1,390,1102,1,1,384,21002,388,1,1,20001,389,391,2,21102,1,228,0,1106,0,578,1206,1,261,1208,1,2,381,1006,381,253,21001,388,0,1,20001,389,391,2,21102,253,1,0,1106,0,393,1002,391,-1,391,1102,1,1,384,1005,384,161,20001,388,390,1,20001,389,391,2,21102,1,279,0,1105,1,578,1206,1,316,1208,1,2,381,1006,381,304,20001,388,390,1,20001,389,391,2,21101,0,304,0,1106,0,393,1002,390,-1,390,1002,391,-1,391,1101,1,0,384,1005,384,161,21001,388,0,1,21001,389,0,2,21102,1,0,3,21102,1,338,0,1106,0,549,1,388,390,388,1,389,391,389,20102,1,388,1,20101,0,389,2,21102,4,1,3,21101,365,0,0,1106,0,549,1007,389,20,381,1005,381,75,104,-1,104,0,104,0,99,0,1,0,0,0,0,0,0,236,16,16,1,1,18,109,3,22101,0,-2,1,22102,1,-1,2,21101,0,0,3,21102,1,414,0,1106,0,549,21202,-2,1,1,22102,1,-1,2,21102,429,1,0,1105,1,601,1202,1,1,435,1,386,0,386,104,-1,104,0,4,386,1001,387,-1,387,1005,387,451,99,109,-3,2105,1,0,109,8,22202,-7,-6,-3,22201,-3,-5,-3,21202,-4,64,-2,2207,-3,-2,381,1005,381,492,21202,-2,-1,-1,22201,-3,-1,-3,2207,-3,-2,381,1006,381,481,21202,-4,8,-2,2207,-3,-2,381,1005,381,518,21202,-2,-1,-1,22201,-3,-1,-3,2207,-3,-2,381,1006,381,507,2207,-3,-4,381,1005,381,540,21202,-4,-1,-1,22201,-3,-1,-3,2207,-3,-4,381,1006,381,529,22102,1,-3,-7,109,-8,2106,0,0,109,4,1202,-2,36,566,201,-3,566,566,101,639,566,566,1202,-1,1,0,204,-3,204,-2,204,-1,109,-4,2105,1,0,109,3,1202,-1,36,594,201,-2,594,594,101,639,594,594,20101,0,0,-2,109,-3,2105,1,0,109,3,22102,21,-2,1,22201,1,-1,1,21101,0,383,2,21102,1,195,3,21102,1,756,4,21101,0,630,0,1106,0,456,21201,1,1395,-2,109,-3,2105,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,2,2,0,2,0,0,0,0,2,2,0,2,2,2,0,2,2,2,2,0,0,2,0,2,0,0,0,2,2,2,2,2,0,1,1,0,2,0,0,2,2,2,0,0,2,0,0,2,0,2,0,0,2,2,0,0,2,0,0,2,2,2,0,2,0,2,2,2,0,1,1,0,2,2,0,2,2,0,2,0,0,0,2,0,2,0,0,2,0,2,0,0,2,2,2,2,0,2,2,2,0,0,0,2,0,1,1,0,0,0,0,2,0,0,2,2,0,0,2,2,0,2,0,2,2,0,2,2,2,0,0,0,2,2,2,2,0,2,2,2,0,1,1,0,2,0,0,0,0,0,0,0,2,2,2,2,0,2,2,2,2,2,0,2,2,0,2,0,0,0,2,2,2,0,2,0,0,1,1,0,2,0,2,2,2,2,2,0,0,2,0,0,0,2,0,2,2,0,0,2,0,2,2,2,2,0,2,0,0,0,0,0,0,1,1,0,2,2,0,0,0,2,0,0,0,2,2,0,2,2,2,0,2,2,2,0,2,2,2,2,2,2,2,0,2,2,2,2,0,1,1,0,0,2,0,2,2,2,2,0,0,2,2,0,0,2,0,0,2,0,0,2,2,0,0,2,0,2,2,0,0,2,0,2,0,1,1,0,2,2,2,2,0,2,0,2,2,0,2,2,2,2,0,0,0,0,0,0,0,2,2,2,2,2,0,2,0,0,0,2,0,1,1,0,2,0,0,0,2,0,0,2,0,0,2,0,0,0,2,2,2,2,2,0,2,0,2,0,2,0,2,0,0,2,2,0,0,1,1,0,0,2,0,2,0,0,2,0,2,0,2,2,2,0,2,0,2,2,2,2,2,0,0,2,2,2,2,0,2,2,2,0,0,1,1,0,2,2,2,2,0,0,2,2,0,0,2,0,0,0,2,0,0,2,2,0,0,2,2,0,2,2,0,2,2,2,2,2,0,1,1,0,2,2,2,0,0,2,2,0,2,2,0,0,2,2,0,0,0,2,2,0,2,2,2,0,2,2,2,2,2,2,2,2,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,41,18,64,4,35,69,87,3,61,92,57,18,62,5,79,85,93,19,49,29,82,55,89,89,54,81,9,18,83,31,88,84,91,60,30,80,76,17,43,67,53,1,87,74,50,67,38,2,13,58,18,4,4,46,61,32,48,76,53,56,73,93,20,24,80,69,13,67,19,15,13,29,16,92,21,20,22,82,83,21,51,54,13,97,7,78,96,6,9,63,21,66,62,6,57,2,83,63,26,49,13,8,72,52,67,51,17,52,34,89,37,76,10,62,28,41,79,62,28,48,29,85,52,35,45,25,66,25,84,34,12,34,64,34,54,13,53,82,51,89,14,15,7,32,58,64,26,21,70,38,5,73,91,9,95,62,69,5,41,66,89,17,65,88,18,15,82,53,86,59,12,70,26,75,31,54,44,86,36,89,97,94,4,4,46,84,49,7,38,40,93,28,20,18,6,37,35,68,51,71,12,26,47,30,98,76,14,82,36,5,7,90,20,71,20,69,83,70,37,53,37,68,74,50,49,85,83,34,35,43,54,43,41,23,29,75,85,70,52,83,74,72,49,75,64,61,28,69,15,74,20,38,96,96,22,64,23,91,50,11,80,55,66,47,88,5,18,18,55,8,92,20,42,98,37,82,5,1,11,32,41,86,93,49,56,37,64,45,79,24,26,82,49,47,43,56,51,17,11,18,36,86,49,38,58,33,97,65,56,86,57,23,74,70,58,50,29,14,20,5,78,54,20,90,39,95,80,3,29,50,47,74,25,98,98,66,1,13,50,38,48,97,89,20,78,74,5,23,45,44,65,31,5,44,71,91,86,81,86,87,28,1,71,38,19,34,16,92,92,2,71,93,12,97,87,33,86,26,15,81,88,85,98,10,27,42,26,20,78,4,42,62,57,38,84,27,21,54,55,34,63,41,7,18,93,18,27,94,83,85,92,97,43,21,12,91,17,96,56,60,15,93,3,13,39,85,49,8,39,54,54,66,44,7,23,98,2,1,3,9,1,85,88,27,82,15,5,67,43,93,23,35,57,57,24,11,65,12,61,44,40,76,60,60,45,8,24,34,91,22,38,34,33,69,8,75,7,3,19,35,39,73,64,79,50,89,75,29,96,59,26,64,30,90,15,68,18,71,31,6,84,15,80,3,43,71,65,54,16,79,38,58,81,73,53,21,13,18,49,72,66,58,74,4,78,19,73,51,97,93,53,53,57,34,89,57,49,13,7,16,44,42,49,26,85,31,72,13,19,30,22,12,39,92,98,26,17,46,25,78,77,94,40,74,90,52,2,51,33,16,6,55,66,82,10,6,7,96,98,43,10,42,34,15,9,92,64,15,18,13,8,72,37,20,76,72,90,48,65,55,5,65,66,50,44,76,97,61,72,24,23,33,91,68,31,29,63,51,98,83,6,53,43,14,71,98,50,5,81,49,72,56,58,77,14,74,51,66,77,31,2,3,45,37,25,53,78,3,74,76,26,72,74,86,96,98,90,71,61,95,85,68,68,89,85,47,82,59,28,60,6,44,33,97,67,51,13,90,77,63,49,27,22,6,49,68,33,15,39,83,51,66,85,57,8,75,13,37,39,78,52,31,83,8,26,35,65,25,11,69,71,3,91,6,66,88,82,10,59,28,30,66,60,26,19,87,62,14,97,9,94,42,27,5,90,73,81,67,13,71,67,77,28,48,36,17,29,91,53,87,9,23,20,77,61,76,549350
"""
+ String(repeating: ",0", count: 10000)

var program = Program(memory: memoryString)

struct Point: Hashable {
    let x: Int
    let y: Int
}

enum Tile: Int {
    case empty = 0
    case wall = 1
    case block = 2
    case paddle = 3
    case ball = 4
    
    func toCharacter() -> Character {
        switch self {
            case .empty: return " "
            case .wall: return "\u{25AE}"
            case .block: return "\u{25A0}"
            case .paddle: return "\u{25AD}"
            case .ball: return "\u{25CF}"
        }
    }
}

var screen = Dictionary<Point, Tile>()

while true {
    if let x = program.run(input: 0),
        let y = program.run(input: 0),
        let tileId = program.run(input: 0) {
        
        let vector = Point(x: x, y: y)
        let tile = Tile(rawValue: tileId)
        screen[vector] = tile
    } else {
        break
    }
}

print(screen.values.filter{ $0 == .block }.count)

// -------------------

enum Joystick: Int {
    case neutral = 0
    case left = -1
    case right = 1
}

func printScreen(_ screen: Dictionary<Point,Tile>) {
    let minX = screen.min(by: {$0.key.x < $1.key.x })!.key.x
    let maxX = screen.min(by: {$0.key.x > $1.key.x })!.key.x
    let minY = screen.min(by: {$0.key.y < $1.key.y })!.key.y
    let maxY = screen.min(by: {$0.key.y > $1.key.y })!.key.y

    for y in (minY...maxY).reversed() {
        for x in minX...maxX {
            let tile = screen[Point(x: x, y: y)] ?? .empty
            print(tile.toCharacter(), terminator: "")
        }
        print()
    }
}


screen = Dictionary<Point, Tile>()
let freePlayMemoryString = "2" + memoryString.dropFirst()
var score: Int?

program = Program(memory: freePlayMemoryString)
var input = 0

while true {
    if let parameter1 = program.run(input: input),
        let parameter2 = program.run(input: input),
        let parameter3 = program.run(input: input) {
        
        if parameter1 == -1 && parameter2 == 0 {
            score = parameter3
        } else {
            let vector = Point(x: parameter1, y: parameter2)
            let tile = Tile(rawValue: parameter3)
            screen[vector] = tile
            
            let ballKeyValue = screen.filter{ $0.value == .ball }.first
            if let bk = ballKeyValue {
                let paddleKeyValue = screen.filter{ $0.value == .paddle }.first
                if let pk = paddleKeyValue {
                    if bk.key.x < pk.key.x {
                        input = -1
                    } else if bk.key.x > pk.key.x {
                        input = 1
                    } else {
                        input = 0
                    }
                }
            }
            
            printScreen(screen)
        }
    } else {
        break
    }
}

print(score)

