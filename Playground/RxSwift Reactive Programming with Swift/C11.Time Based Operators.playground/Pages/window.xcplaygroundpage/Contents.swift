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

//: Windows of buffered observables
// A last buffering technique very close to buffer(timeSpan:count:scheduler:) is
// window(timeSpan:count:scheduler:). It has roughly the same signature and nearly
// does the same thing. The only difference is that it emits an Observable of the
// buffered items, instead of emitting an array.
// If the source observable emits more than count elements during the window time(timeSpan),
// a new observable is produced, and the cycle starts again.
// 缓存的窗口 observables
// buffer(timeSpan:count:scheduler:) 和 window(timeSpan:count:scheduler:) 非常相似
// 几乎一样的签名和几乎做了相同的事情
// 唯一的区别是:
// window: 发出缓存元素的 Observable, 这个 Observable 会与源 Observable 同步发出元素
//         timeSpan 和 count 任何之一达到限制, 这个 Observable 会完成, 然后发出新的 Observable
// buffer: 发出的是元素的数组
// 如果源 observable 在 timeSpan 时间内发出多于 count 个元素.
// 一个新的 observable 将产生, 且一个新的时间循环将开始. 类似 buffer 操作符

// do(onNext:) 操作符通常用于执行副作用

let elementsPerSecond = 0.4
let windowTimeSpan: RxTimeInterval = 4
let windowMaxCount = 10
let sourceObservable = PublishSubject<String>()

let sourceTimeline = TimelineView<String>.make()

let stack = UIStackView.makeVertical([
    UILabel.makeTitle("window"),
    UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
    sourceTimeline,
    UILabel.make("Windowed observables (at most \(windowMaxCount) every \(windowTimeSpan) sec):")])

let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
    sourceObservable.onNext("🦊")
}

_ = sourceObservable.subscribe(sourceTimeline)
_ = sourceObservable
    .window(timeSpan: windowTimeSpan,
            count: windowMaxCount,
            scheduler: MainScheduler.instance)
    .flatMap { windowedObservable -> Observable<(TimelineView<Int>, String?)> in
        let timeline = TimelineView<Int>.make()
        stack.insert(timeline, at: 4)
        stack.keep(atMost: 8)
        return windowedObservable
            .map { (timeline, $0) }
            .concat(Observable.just((timeline, nil)))
    }
    .subscribe(onNext: { tuple in
        let (timeline, value) = tuple
        if let value = value {
            timeline.add(.Next(value))
        } else {
            timeline.add(.Completed(true))
        }
    })

let hostView = setupHostView()
hostView.addSubview(stack)
hostView
