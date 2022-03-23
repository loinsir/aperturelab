//let input = readLine()!.split(separator: " ").map { Int($0)! }
//let blocks = readLine()!.split(separator: " ").map { Int($0)! }

let input = [4, 8]
let blocks = [3, 1, 2, 3, 4, 1, 1, 2]

let H = input[0]
let W = input[1]

var stack: [Int] = []
var top = 0
var result = 0

for block in blocks {
    if stack.isEmpty {
        top = block
        stack.append(block)
    } else {
        if top > block {
            stack.append(block)
        } else {
            top = top > block ? block : top
            while stack.count > 1 {
                result += top - stack.last!
                stack.removeLast()
            }
            stack.removeAll()
            stack.append(block)
            top = block
        }
    }
}

print(result)
