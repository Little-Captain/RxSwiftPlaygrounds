import UIKit
import RxSwift
import RxCocoa

// Support code -- DO NOT REMOVE
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
  static func make() -> TimelineView<E> {
    let view = TimelineView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
    view.setup()
    return view
  }
  public func on(_ event: Event<E>) {
    switch event {
    case .next(let value):
      add(.Next(String(describing: value)))
    case .completed:
      add(.Completed())
    case .error(_):
      add(.Error())
    }
  }
}

//: Controlled buffering
// buffer(timeSpan:count:scheduler:)
// 1. You want to receive arrays of elements from the source observable.
// 2. Each array can hold at most `count` elements.
// 3. If that many elements are received before `timeSpan` expires,
//    the operator will emit buffered elements and reset its timer.
// 4. In a delay of `timeSpan` after the last emitted group, buffer will emit an array.
//    If no element has been received during this timeSpan, the array will be empty.
// 1. 你想从源 observable 中接收到数组
// 2. 每个数组最多持有 count 个元素
// 3. 如果在 timeSpan 时间跨度内收到了很多元素(> count),
//    这个 operator 将发出缓存的 count 个元素组成的数组, 并重置时间
// 4. 在上次发出元素组后再经历 timeSpan 后, buffer 将发出一个数组.
//    如果在这个 timeSpan 时间内没有收到任何元素, 这个数组将为空

// The buffer(timeSpan:count:scheduler:) operators emits empty arrays at regular intervals
// if nothing has been received from its source observable.
// 如果在经历 timeSpan 时间间隔后 buffer(timeSpan:count:scheduler:)
// 没有从源 observable 中收到任何元素, 它将发出空数组

// The buffer immediately emits an array of elements when it reaches full capacity,
// then waits for the specified delay, or until it's full again, before it emits a new array.
// buffer 在达到满容量时, 会立即发出这些元素组成的数组.
// 然后在它发出新数组前, 等待 timeSpan 时间间隔, 或再次达到满容量

let bufferTimeSpan: RxTimeInterval = 4
let bufferMaxCount = 2

let sourceObservable = PublishSubject<String>()

let sourceTimeline = TimelineView<String>.make()
let bufferedTimeline = TimelineView<String>.make()

let stack = UIStackView.makeVertical([
    UILabel.makeTitle("buffer"),
    UILabel.make("Emitted elements:"),
    sourceTimeline,
    UILabel.make("Buffered elements (at most \(bufferMaxCount)) every \(bufferTimeSpan) second):"),
    bufferedTimeline])

_ = sourceObservable.subscribe(sourceTimeline)

let bufferObservable = sourceObservable
    .buffer(timeSpan: bufferTimeSpan,
            count: bufferMaxCount,
            scheduler: MainScheduler.instance)
    .map { $0.count.description }
    
_ = bufferObservable.subscribe(bufferedTimeline)

let hostView = setupHostView()
hostView.addSubview(stack)
hostView

//DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//    sourceObservable.onNext("🐶")
//    sourceObservable.onNext("🐶")
//    sourceObservable.onNext("🐶")
//}

let elementsPerSecond = 0.4
let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
    sourceObservable.onNext("🐮")
}





















