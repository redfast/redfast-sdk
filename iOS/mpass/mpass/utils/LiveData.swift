import Foundation

public class LiveData<T> {
    init(_ t: T? = nil) {
        data = t
    }

    var data: T? {
        willSet(newValue) {
            DispatchQueue.main.async {
                if let val = newValue {
                    self.onNext?(val)
                }
            }
        }
    }
    
    var error: Error? {
        willSet(newValue) {
            DispatchQueue.main.async {
                if let err = newValue {
                    self.onError?(err)
                }
            }
        }
    }
    
    func subscribe(onNext: @escaping (T) -> Void, onError: ((Error) -> Void)? = nil) {
        self.onNext = onNext
        self.onError = onError
        if let data = self.data {
            onNext(data)
        }
        if let error = self.error {
            onError?(error)
        }
    }
    
    var onNext: ((T) -> Void)?
    var onError: ((Error) -> Void)?
    
    deinit {
        onNext = nil
        onError = nil
    }
}
