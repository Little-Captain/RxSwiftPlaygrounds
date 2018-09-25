import UIKit
import RxSwift
import RxCocoa

// Support code -- DO NOT REMOVE
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
    static func make() -> TimelineView<E> {
        return TimelineView(width: 400, height: 100)
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

//: Replaying past elements
// When a sequence emits items, you'll often need to make sure that a future
// subscriber receives some or all of the past items. This is the purpose of
// the replay(_:) and replayAll() operators.
// 当序列发出元素时，您通常需要确保将来的订阅者收到的是部分或全部过去的项目.
// 这是 replay(_:) 和 replayAll() 运算符的目的.

// This operator(replay(_:)) creates a new sequence which records the last n emitted
// by the source observable. Every time a new observer subscribes, it immediately
// receives the buffered elements (if any) and keeps receiving any new element like a
// normal subscription does.
// replay(_:) 创建一个新序列, 它记录最近的 n 个从源 observable 发出的元素
// 每次新的观察者订阅时, 它立即收到缓存的 n 个元素(如果有)
// 然后继续接收任何新元素, 就像普通订阅一样
// 使用 replay(_:) 后在有新的的订阅时, observable 不会重复调用它的 create 闭包生成元素

// Since replay(_:) creates a connectable observable, you need to connect it to
// its underlying source to start receiving items. If you forget this, subscribers
// will never receive anything.
// 因为 replay(_:) 创建了一个 connectable observable, 在开始接收元素前, 你需要将它和它的源连接
// 如果你忘记了, 订阅者将永远不会收到任何元素

// Note: Connectable observables are a special class of observables. Regardless of their
// number of subscribers, they won't start emitting items until you call their connect()
// method. Remember that a few operators return ConnectableObservable<E>, not Observable<E>.
// These operators are:
// replay(_:)
// replayAll()
// multicast(_:)
// publish()
// 注意: Connectable observables 是一类特殊的 observables. 不管它们有多少订阅者, 在你调用它们的
// connect() 方法前, 它们不会发出任何元素.
// 请记住: 有少量 operators 返回的类型是 ConnectableObservable<E>, 而不是 Observable<E>
// 这些 operators 有:
// replay(_:)
// replayAll()
// multicast(_:)
// publish()

// Unlimited replay
// The second replay operator you can use is replayAll(). This one should be used with caution:
// only use it in scenarios where you know the total number of buffered elements will stay
// reasonable. Using replayAll() on a sequence that may not terminate and may produce
// a lot of data will quickly clog your memory. This could grow to the point where the OS
// jettisons your application!
// 无限回放
// replayAll()
// 小心使用 replayAll(): 仅当你知道缓存元素总数总是合理的情况下使用它
// 对可能无法终止并可能产生大量数据的序列使用 replayAll() 将很快阻塞您的内存.
// 这可能会增长到操作系统杀死你的应用程序的程度!!!

let elementsPerSecond = 1
let maxElements = 100
let replayedElements = 3
let replayDelay: TimeInterval = 5

//let sourceObservable = Observable<Int>
//    .create { observer in
//        var value = 1
//        let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
//            if value <= maxElements {
//                print("create \(value)")
//                observer.onNext(value)
//                value += 1
//            }
//        }
//        return Disposables.create { timer.suspend() }
//    }
////    .replay(replayedElements)
//    .replayAll()

// Intervals
// RxSwift's Observable.interval(_:scheduler:) function.
// It produces an infinite observable sequence on Int values (effectively a counter)
// sent at the selected interval on the specified scheduler.
// Observable.interval(_:scheduler:) 函数
// 它在指定 scheduler 上间隔指定时间发出无限可观察整数序列(实际上是一个计数器)

// Interval timers are incredibly easy to create with RxSwift. Not only that,
// but they are also easy to cancel: since Observable.interval(_:scheduler:)
// generates an observable sequence, subscriptions can simply dispose() the returned
// disposable to cancel the subscription and stop the timer. Very cool!
// 使用 RxSwift 非常容易创建 Interval timer
// 不仅如此, 它也非常容易取消: 因为 Observable.interval(_:scheduler:) 生成一个 observable,
// 订阅后可以简单的使用 disposable 调用其 dispose() 方法来取消订阅和停止 timer. 非常酷!

// It is notable that the first value is emitted at the specified duration after
// a subscriber starts observing the sequence. Also, the timer won't start before
// this point. The subscription is the trigger that kicks it off.
// 值得注意的是: 在订阅者订阅后经历指定时间间隔后, observable 才会发出第一个值
// 也就是, timer 不会在订阅前发出元素. 订阅是启动它的触发器.

// Note: Values emitted by Observable.interval(_:scheduler:)
// are signed integers starting from 0.
// Should you need different values, you can simply map(_:) them.
// 注意: Observable.interval(_:scheduler:) 发出的值是从 0 开始的.
// 如果你需要不同的值, 你可以简单的 map(_:) 它们.

let sourceObservable = Observable<Int>
    .interval(RxTimeInterval(1.0 / Double(elementsPerSecond)), scheduler: MainScheduler.instance)
    .replay(replayedElements)

let sourceTimeline = TimelineView<Int>.make()
let replayedTimeline = TimelineView<Int>.make()

let stack = UIStackView.makeVertical([
    UILabel.makeTitle("replay"),
    UILabel.makeTitle("Emit \(elementsPerSecond) per second:"),
    sourceTimeline,
    UILabel.makeTitle("Replay \(replayedElements) after \(replayDelay) sec:"),
    replayedTimeline])

_ = sourceObservable.subscribe(sourceTimeline)

DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
    _ = sourceObservable.subscribe(replayedTimeline)
}

_ = sourceObservable.connect()


let hostView = setupHostView()
hostView.addSubview(stack)
hostView







