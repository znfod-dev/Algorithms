import Foundation
import CoreFoundation

var totalComparisons = 0
var totalTime:Double = 0
struct Result {
    var compare:Int
    var time:Double
}
var results = Array<Result>()

func initArray(_ count: Int) -> Array<Int> {
    var array = Array(1...count)
    for _ in 0..<count*3 {
        let x = Int(arc4random_uniform(UInt32(count)))
        let y = Int(arc4random_uniform(UInt32(count)))
        
        if x != y {
            let temp = array[x]
            array[x] = array[y]
            array[y] = temp
        }
    }
    return array
}

// maxDigit = 최대 자리값
func Sort(queue: String, _ array:Array<Int>, _ maxDigit:Int) {
    var a = array
    let start=Date()
    print("queue [\(queue)] 정렬시작 : \(start)")
    var compares = 0
    
    let radix = 10  //Here we define our radix to be 10
    var done = false
    var index: Int
    var digit = 1  //Which digit are we on?
    while !done {  //While our  sorting is not completed
        done = true  //Assume it is done for now
        var buckets: [[Int]] = []  //Our sorting subroutine is bucket sort, so let us predefine our buckets
        for _ in 1...radix {
            buckets.append([])
        }
        
        for number in a {
            index = number / digit  //Which bucket will we access?
            buckets[index % radix].append(number)
            if done && index > 0 {  //If we arent done, continue to finish, otherwise we are done
                done = false
            }
        }
        
        var i = 0
        
        for j in 0..<radix {
            let bucket = buckets[j]
            for number in bucket {
                a[i] = number
                i += 1
            }
        }
        
        digit *= radix  //Move to the next digit
    }
    let end=Date()
    let time = start.distance(to: end)
    totalComparisons += compares
    totalTime += time
    results.append(Result.init(compare: compares, time: time))
    print("queue [\(queue)] 정렬 완료 : \(end)")
}


print("getUsedMemory : \(getUsedMemory())")
let myQueue = DispatchQueue.init(label: "MyQueue")
//let myQueue = DispatchQueue.init(label: "MyQueue", attributes: .concurrent)
let group = DispatchGroup()
let num = 10
for i in 0..<num {
    myQueue.async(group: group) {
        let array = initArray(1000)
        Sort(queue: String(i), array, 3)
    }
}
group.notify(queue: myQueue) {
    print("END")
    results.sorted(by: { $0.time > $1.time })
    
    print("평균 비교 : \(totalComparisons/num)")
    print("평균 걸린 시간 : \(totalTime/Double(num))")
    guard let first = results.first else {
        return
    }
    guard let last = results.last else {
        return
    }
    print("getUsedMemory : \(getUsedMemory())")
    print("최소 시간 : \(String(describing: first.time)) | 최대시간 : \(last.time)")
}
func getUsedMemory() -> UInt {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)
    let kerr = withUnsafeMutablePointer(to: &info) {
        infoPtr in return infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            (machPtr: UnsafeMutablePointer<integer_t>) in return task_info( mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), machPtr, &count )
        }
    }
    guard kerr == KERN_SUCCESS else {
        return 0
        
    }
    return UInt(info.resident_size)
}

