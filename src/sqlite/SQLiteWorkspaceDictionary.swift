import Atomics
import Dflat
import Dispatch
import FlatBuffers
import Foundation

struct SQLiteWorkspaceDictionary: WorkspaceDictionary {
  enum None {
    case none
  }
  final class Storage {
    static let size = 12
    let namespace: String
    var locks: UnsafeMutablePointer<os_unfair_lock_s>
    var dictionaries: [[String: Any]]
    var subscriptions: [[String: [ObjectIdentifier: (Any?) -> Void]]]
    var disableDiskFetch = UnsafeAtomic<Bool>.Storage(false)
    init(namespace: String) {
      self.namespace = namespace
      locks = UnsafeMutablePointer.allocate(capacity: Self.size)
      locks.assign(repeating: os_unfair_lock(), count: Self.size)
      dictionaries = Array(repeating: [String: Any](), count: Self.size)
      subscriptions = Array(
        repeating: [String: [ObjectIdentifier: (Any?) -> Void]](), count: Self.size)
    }
    deinit {
      locks.deallocate()
    }
  }
  let workspace: SQLiteWorkspace
  let storage: Storage
  subscript<T: Codable & Equatable>(key: String, _: T.Type) -> T? {
    get {
      let tuple = storage.getAndLock(key)
      if let value = tuple.0 {
        storage.unlock(tuple.1)
        return value is None ? nil : (value as! T)
      }  // Otherwise, try to load from disk.
      storage.unlock(tuple.1)
      if let value = workspace.fetch(for: DictItem.self).where(
        DictItem.key == key && DictItem.namespace == storage.namespace
      ).first {
        assert(value.valueType == .codableValue)
        let object: T? = value.codable.withUnsafeBytes {
          guard let baseAddress = $0.baseAddress else { return nil }
          let decoder = PropertyListDecoder()
          var format = PropertyListSerialization.PropertyListFormat.binary
          return try? decoder.decode(
            T.self,
            from: Data(
              bytesNoCopy: UnsafeMutableRawPointer(mutating: baseAddress), count: $0.count,
              deallocator: .none), format: &format)
        }
        storage.lock(tuple.1)
        // If no one else populated the cache, do that now.
        if storage.get(key, hashValue: tuple.1) == nil {
          storage.set(key, hashValue: tuple.1, value: object ?? None.none)
        }
        storage.unlock(tuple.1)
        return object
      } else {
        storage.lock(tuple.1)
        // If no one else populated the cache, do that now.
        if storage.get(key, hashValue: tuple.1) == nil {
          storage.set(key, hashValue: tuple.1, value: None.none)
        }
        storage.unlock(tuple.1)
      }
      return nil
    }
    set {
      let (oldValue, hashValue) = storage.setAndLock(
        key, value: newValue ?? None.none)
      assert((oldValue == nil) || (oldValue is None) || (oldValue is T))
      guard (oldValue as? T) != newValue else {
        storage.unlock(hashValue)
        return
      }
      if let value = newValue {
        // Encode on current thread. Codable can be customized, hence, there is no guarantee it is thread-safe.
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        do {
          let data = try encoder.encode(value)
          storage.upsert(
            workspace,
            item: DictItem(
              key: key, namespace: storage.namespace, valueType: .codableValue, codable: Array(data)
            ))
        } catch {
          // TODO: Log the error.
        }
      } else {
        storage.remove(workspace, key: key)
      }
      let subscribers = storage.subscriber(key, hashValue: hashValue)
      storage.unlock(hashValue)
      for subscriber in subscribers {
        subscriber(newValue)
      }
    }
  }
  subscript<T: FlatBuffersCodable & Equatable>(key: String, _: T.Type) -> T? {
    get {
      let tuple = storage.getAndLock(key)
      if let value = tuple.0 {
        storage.unlock(tuple.1)
        return value is None ? nil : (value as! T)
      }  // Otherwise, try to load from disk.
      storage.unlock(tuple.1)
      // Don't need to fetch from disk if it is disabled.
      guard
        !(withUnsafeMutablePointer(to: &storage.disableDiskFetch) {
          UnsafeAtomic(at: $0).load(ordering: .acquiring)
        })
      else { return nil }
      if let value = workspace.fetch(for: DictItem.self).where(
        DictItem.key == key && DictItem.namespace == storage.namespace
      ).first {
        assert(value.valueType == .flatBuffersValue)
        let object: T?
        if value.version == T.flatBuffersSchemaVersion {
          object = value.codable.withUnsafeBytes {
            guard let baseAddress = $0.baseAddress else { return nil }
            return T.from(
              byteBuffer: ByteBuffer(
                assumingMemoryBound: UnsafeMutableRawPointer(mutating: baseAddress),
                capacity: $0.count))
          }
        } else {
          object = nil
        }
        storage.lock(tuple.1)
        // If no one else populated the cache, do that now.
        if storage.get(key, hashValue: tuple.1) == nil {
          storage.set(key, hashValue: tuple.1, value: object ?? None.none)
        }
        storage.unlock(tuple.1)
        return object
      } else {
        storage.lock(tuple.1)
        // If no one else populated the cache, do that now.
        if storage.get(key, hashValue: tuple.1) == nil {
          storage.set(key, hashValue: tuple.1, value: None.none)
        }
        storage.unlock(tuple.1)
        return nil
      }
    }
    set {
      let (oldValue, hashValue) = storage.setAndLock(
        key, value: newValue ?? None.none)
      assert((oldValue == nil) || (oldValue is None) || (oldValue is T))
      guard (oldValue as? T) != newValue else {
        storage.unlock(hashValue)
        return
      }
      if let value = newValue {
        let namespace = storage.namespace
        storage.upsert(workspace) {
          var fbb = FlatBufferBuilder()
          let offset = value.to(flatBufferBuilder: &fbb)
          fbb.finish(offset: offset)
          return DictItem(
            key: key, namespace: namespace, version: T.flatBuffersSchemaVersion,
            valueType: .flatBuffersValue, codable: fbb.sizedByteArray)
        }
      } else {
        storage.remove(workspace, key: key)
      }
      let subscribers = storage.subscriber(key, hashValue: hashValue)
      storage.unlock(hashValue)
      for subscriber in subscribers {
        subscriber(newValue)
      }
    }
  }
  subscript(key: String, _: Bool.Type) -> Bool? {
    get {
      let tuple = storage.getAndLock(key)
      if let value = tuple.0 {
        storage.unlock(tuple.1)
        return value is None ? nil : (value as! Bool)
      }  // Otherwise, try to load from disk.
      storage.unlock(tuple.1)
      // Don't need to fetch from disk if it is disabled.
      guard
        !(withUnsafeMutablePointer(to: &storage.disableDiskFetch) {
          UnsafeAtomic(at: $0).load(ordering: .acquiring)
        })
      else { return nil }
      if let value = workspace.fetch(for: DictItem.self).where(
        DictItem.key == key && DictItem.namespace == storage.namespace
      ).first {
        assert(value.valueType == .boolValue)
        let object = value.boolValue
        storage.lock(tuple.1)
        // If no one else populated the cache, do that now.
        if storage.get(key, hashValue: tuple.1) == nil {
          storage.set(key, hashValue: tuple.1, value: object)
        }
        storage.unlock(tuple.1)
        return object
      } else {
        storage.lock(tuple.1)
        // If no one else populated the cache, do that now.
        if storage.get(key, hashValue: tuple.1) == nil {
          storage.set(key, hashValue: tuple.1, value: None.none)
        }
        storage.unlock(tuple.1)
        return nil
      }
    }
    set {
      let (oldValue, hashValue) = storage.setAndLock(
        key, value: newValue ?? None.none)
      assert((oldValue == nil) || (oldValue is None) || (oldValue is Bool))
      guard (oldValue as? Bool) != newValue else {
        storage.unlock(hashValue)
        return
      }
      if let value = newValue {
        storage.upsert(
          workspace,
          item: DictItem(
            key: key, namespace: storage.namespace, valueType: .boolValue, boolValue: value))
      } else {
        storage.remove(workspace, key: key)
      }
      let subscribers = storage.subscriber(key, hashValue: hashValue)
      storage.unlock(hashValue)
      for subscriber in subscribers {
        subscriber(newValue)
      }
    }
  }
  subscript(key: String, _: Int.Type) -> Int? {
    get {
      let tuple = storage.getAndLock(key)
      if let value = tuple.0 {
        storage.unlock(tuple.1)
        return value is None ? nil : (value as! Int)
      }  // Otherwise, try to load from disk.
      storage.unlock(tuple.1)
      // Don't need to fetch from disk if it is disabled.
      guard
        !(withUnsafeMutablePointer(to: &storage.disableDiskFetch) {
          UnsafeAtomic(at: $0).load(ordering: .acquiring)
        })
      else { return nil }
      if let value = workspace.fetch(for: DictItem.self).where(
        DictItem.key == key && DictItem.namespace == storage.namespace
      ).first {
        assert(value.valueType == .longValue)
        let object = Int(value.longValue)
        storage.lock(tuple.1)
        // If no one else populated the cache, do that now.
        if storage.get(key, hashValue: tuple.1) == nil {
          storage.set(key, hashValue: tuple.1, value: object)
        }
        storage.unlock(tuple.1)
        return object
      } else {
        storage.lock(tuple.1)
        // If no one else populated the cache, do that now.
        if storage.get(key, hashValue: tuple.1) == nil {
          storage.set(key, hashValue: tuple.1, value: None.none)
        }
        storage.unlock(tuple.1)
        return nil
      }
    }
    set {
      let (oldValue, hashValue) = storage.setAndLock(
        key, value: newValue ?? None.none)
      assert((oldValue == nil) || (oldValue is None) || (oldValue is Int))
      guard (oldValue as? Int) != newValue else {
        storage.unlock(hashValue)
        return
      }
      if let value = newValue {
        storage.upsert(
          workspace,
          item: DictItem(
            key: key, namespace: storage.namespace, valueType: .longValue, longValue: Int64(value)))
      } else {
        storage.remove(workspace, key: key)
      }
      let subscribers = storage.subscriber(key, hashValue: hashValue)
      storage.unlock(hashValue)
      for subscriber in subscribers {
        subscriber(newValue)
      }
    }
  }
  subscript(key: String, _: UInt.Type) -> UInt? {
    get {
      let tuple = storage.getAndLock(key)
      if let value = tuple.0 {
        storage.unlock(tuple.1)
        return value is None ? nil : (value as! UInt)
      }  // Otherwise, try to load from disk.
      storage.unlock(tuple.1)
      // Don't need to fetch from disk if it is disabled.
      guard
        !(withUnsafeMutablePointer(to: &storage.disableDiskFetch) {
          UnsafeAtomic(at: $0).load(ordering: .acquiring)
        })
      else { return nil }
      if let value = workspace.fetch(for: DictItem.self).where(
        DictItem.key == key && DictItem.namespace == storage.namespace
      ).first {
        assert(value.valueType == .unsignedLongValue)
        let object = UInt(value.unsignedLongValue)
        storage.lock(tuple.1)
        // If no one else populated the cache, do that now.
        if storage.get(key, hashValue: tuple.1) == nil {
          storage.set(key, hashValue: tuple.1, value: object)
        }
        storage.unlock(tuple.1)
        return object
      } else {
        storage.lock(tuple.1)
        // If no one else populated the cache, do that now.
        if storage.get(key, hashValue: tuple.1) == nil {
          storage.set(key, hashValue: tuple.1, value: None.none)
        }
        storage.unlock(tuple.1)
        return nil
      }
    }
    set {
      let (oldValue, hashValue) = storage.setAndLock(
        key, value: newValue ?? None.none)
      assert((oldValue == nil) || (oldValue is None) || (oldValue is UInt))
      guard (oldValue as? UInt) != newValue else {
        storage.unlock(hashValue)
        return
      }
      if let value = newValue {
        storage.upsert(
          workspace,
          item: DictItem(
            key: key, namespace: storage.namespace, valueType: .unsignedLongValue,
            unsignedLongValue: UInt64(value)))
      } else {
        storage.remove(workspace, key: key)
      }
      let subscribers = storage.subscriber(key, hashValue: hashValue)
      storage.unlock(hashValue)
      for subscriber in subscribers {
        subscriber(newValue)
      }
    }
  }
  subscript(key: String, _: Float.Type) -> Float? {
    get {
      let tuple = storage.getAndLock(key)
      if let value = tuple.0 {
        storage.unlock(tuple.1)
        return value is None ? nil : (value as! Float)
      }  // Otherwise, try to load from disk.
      storage.unlock(tuple.1)
      // Don't need to fetch from disk if it is disabled.
      guard
        !(withUnsafeMutablePointer(to: &storage.disableDiskFetch) {
          UnsafeAtomic(at: $0).load(ordering: .acquiring)
        })
      else { return nil }
      if let value = workspace.fetch(for: DictItem.self).where(
        DictItem.key == key && DictItem.namespace == storage.namespace
      ).first {
        assert(value.valueType == .floatValue)
        let object = value.floatValue
        storage.lock(tuple.1)
        // If no one else populated the cache, do that now.
        if storage.get(key, hashValue: tuple.1) == nil {
          storage.set(key, hashValue: tuple.1, value: object)
        }
        storage.unlock(tuple.1)
        return object
      } else {
        storage.lock(tuple.1)
        // If no one else populated the cache, do that now.
        if storage.get(key, hashValue: tuple.1) == nil {
          storage.set(key, hashValue: tuple.1, value: None.none)
        }
        storage.unlock(tuple.1)
        return nil
      }
    }
    set {
      let (oldValue, hashValue) = storage.setAndLock(
        key, value: newValue ?? None.none)
      assert((oldValue == nil) || (oldValue is None) || (oldValue is Float))
      guard (oldValue as? Float) != newValue else {
        storage.unlock(hashValue)
        return
      }
      if let value = newValue {
        storage.upsert(
          workspace,
          item: DictItem(
            key: key, namespace: storage.namespace, valueType: .floatValue, floatValue: value))
      } else {
        storage.remove(workspace, key: key)
      }
      let subscribers = storage.subscriber(key, hashValue: hashValue)
      storage.unlock(hashValue)
      for subscriber in subscribers {
        subscriber(newValue)
      }
    }
  }
  subscript(key: String, _: Double.Type) -> Double? {
    get {
      let tuple = storage.getAndLock(key)
      if let value = tuple.0 {
        storage.unlock(tuple.1)
        return value is None ? nil : (value as! Double)
      }  // Otherwise, try to load from disk.
      storage.unlock(tuple.1)
      // Don't need to fetch from disk if it is disabled.
      guard
        !(withUnsafeMutablePointer(to: &storage.disableDiskFetch) {
          UnsafeAtomic(at: $0).load(ordering: .acquiring)
        })
      else { return nil }
      if let value = workspace.fetch(for: DictItem.self).where(
        DictItem.key == key && DictItem.namespace == storage.namespace
      ).first {
        assert(value.valueType == .doubleValue)
        let object = value.doubleValue
        storage.lock(tuple.1)
        // If no one else populated the cache, do that now.
        if storage.get(key, hashValue: tuple.1) == nil {
          storage.set(key, hashValue: tuple.1, value: object)
        }
        storage.unlock(tuple.1)
        return object
      } else {
        storage.lock(tuple.1)
        // If no one else populated the cache, do that now.
        if storage.get(key, hashValue: tuple.1) == nil {
          storage.set(key, hashValue: tuple.1, value: None.none)
        }
        storage.unlock(tuple.1)
        return nil
      }
    }
    set {
      let (oldValue, hashValue) = storage.setAndLock(
        key, value: newValue ?? None.none)
      assert((oldValue == nil) || (oldValue is None) || (oldValue is Double))
      guard (oldValue as? Double) != newValue else {
        storage.unlock(hashValue)
        return
      }
      if let value = newValue {
        storage.upsert(
          workspace,
          item: DictItem(
            key: key, namespace: storage.namespace, valueType: .doubleValue, doubleValue: value))
      } else {
        storage.remove(workspace, key: key)
      }
      let subscribers = storage.subscriber(key, hashValue: hashValue)
      storage.unlock(hashValue)
      for subscriber in subscribers {
        subscriber(newValue)
      }
    }
  }
  subscript(key: String, _: String.Type) -> String? {
    get {
      let tuple = storage.getAndLock(key)
      if let value = tuple.0 {
        storage.unlock(tuple.1)
        return value is None ? nil : (value as! String)
      }  // Otherwise, try to load from disk.
      storage.unlock(tuple.1)
      // Don't need to fetch from disk if it is disabled.
      guard
        !(withUnsafeMutablePointer(to: &storage.disableDiskFetch) {
          UnsafeAtomic(at: $0).load(ordering: .acquiring)
        })
      else { return nil }
      if let value = workspace.fetch(for: DictItem.self).where(
        DictItem.key == key && DictItem.namespace == storage.namespace
      ).first {
        assert(value.valueType == .stringValue)
        let object = value.stringValue
        storage.lock(tuple.1)
        // If no one else populated the cache, do that now.
        if storage.get(key, hashValue: tuple.1) == nil {
          storage.set(key, hashValue: tuple.1, value: object ?? None.none)
        }
        storage.unlock(tuple.1)
        return object
      } else {
        storage.lock(tuple.1)
        // If no one else populated the cache, do that now.
        if storage.get(key, hashValue: tuple.1) == nil {
          storage.set(key, hashValue: tuple.1, value: None.none)
        }
        storage.unlock(tuple.1)
        return nil
      }
    }
    set {
      let (oldValue, hashValue) = storage.setAndLock(
        key, value: newValue ?? None.none)
      assert((oldValue == nil) || (oldValue is None) || (oldValue is String))
      guard (oldValue as? String) != newValue else {
        storage.unlock(hashValue)
        return
      }
      if let value = newValue {
        storage.upsert(
          workspace,
          item: DictItem(
            key: key, namespace: storage.namespace, valueType: .stringValue, stringValue: value))
      } else {
        storage.remove(workspace, key: key)
      }
      let subscribers = storage.subscriber(key, hashValue: hashValue)
      storage.unlock(hashValue)
      for subscriber in subscribers {
        subscriber(newValue)
      }
    }
  }

  func synchronize() {
    let group = DispatchGroup()
    group.enter()
    workspace.performChanges(
      [DictItem.self], changesHandler: { _ in },
      completionHandler: { _ in
        group.leave()
      })
    group.wait()
  }

  var keys: [String] {
    var keys = Set<String>()
    // Only need to fetch from disk if it is not disabled.
    if !(withUnsafeMutablePointer(to: &storage.disableDiskFetch) {
      UnsafeAtomic(at: $0).load(ordering: .acquiring)
    }) {
      let items = workspace.fetch(for: DictItem.self).where(DictItem.namespace == storage.namespace)
      keys = Set(items.map { $0.key })
    }
    for i in 0..<Storage.size {
      storage.lock(i)
      defer { storage.unlock(i) }
      for (key, value) in storage.dictionaries[i] {
        // Remove it, it doesn't exist any more from disk.
        if value is None {
          keys.remove(key)
        } else {
          keys.insert(key)
        }
      }
    }
    return Array(keys)
  }

  func removeAll() {
    var subscribers = [(Any?) -> Void]()
    for i in 0..<Storage.size {
      storage.lock(i)
      defer { storage.unlock(i) }
      // Set existing ones in the dictionaries to be None.
      for key in storage.dictionaries[i].keys {
        storage.dictionaries[i][key] = None.none
      }
      for value in storage.subscriptions[i].values {
        subscribers.append(contentsOf: value.values)
      }
    }
    for subscriber in subscribers {
      subscriber(nil)
    }
    // Since removed everything from disk. We no longer need to fetch from disk in case
    // of a miss any more (because the only thing accessible is write to the in-memory
    // data structure first).
    withUnsafeMutablePointer(to: &storage.disableDiskFetch) {
      UnsafeAtomic(at: $0).store(true, ordering: .releasing)
    }
    let workspace = self.workspace
    let namespace = storage.namespace
    workspace.performChanges(
      [DictItem.self],
      changesHandler: { txnContext in
        // Note that any insertions / updates after removeAll will be queued after this.
        // We need to fetch again because we may have pending writes that not available
        // when do the fetching in the beginning of removeAll.
        let items = workspace.fetch(for: DictItem.self).where(DictItem.namespace == namespace)
        for item in items {
          if let deletionRequest = DictItemChangeRequest.deletionRequest(item) {
            txnContext.try(submit: deletionRequest)
          }
        }
      })
  }

  private final class SQLiteDictionarySubscription: Workspace.Subscription {
    var cancelled = UnsafeAtomic<Bool>.Storage(false)
    var identifier: ObjectIdentifier { ObjectIdentifier(self) }
    let key: String
    weak var storage: Storage?
    init(_ key: String, storage: Storage) {
      self.key = key
      self.storage = storage
    }
    deinit {
      withUnsafeMutablePointer(to: &cancelled) {
        UnsafeAtomic(at: $0).store(true, ordering: .releasing)
      }
      storage?.cancel(key, identifier: identifier)
    }
    func cancel() {
      withUnsafeMutablePointer(to: &cancelled) {
        UnsafeAtomic(at: $0).store(true, ordering: .releasing)
      }
      storage?.cancel(key, identifier: identifier)
    }
  }
}

extension SQLiteWorkspaceDictionary.Storage {
  @inline(__always)
  func getAndLock(_ key: String) -> (Any?, Int) {
    var hasher = Hasher()
    key.hash(into: &hasher)
    let hashValue = Int(UInt(bitPattern: hasher.finalize()) % UInt(Self.size))
    os_unfair_lock_lock(locks + hashValue)
    return (dictionaries[hashValue][key], hashValue)
  }
  @inline(__always)
  func hashAndLock(_ key: String) -> Int {
    var hasher = Hasher()
    key.hash(into: &hasher)
    let hashValue = Int(UInt(bitPattern: hasher.finalize()) % UInt(Self.size))
    os_unfair_lock_lock(locks + hashValue)
    return hashValue
  }
  @inline(__always)
  func setAndLock(_ key: String, value: Any) -> (Any?, Int) {
    var hasher = Hasher()
    key.hash(into: &hasher)
    let hashValue = Int(UInt(bitPattern: hasher.finalize()) % UInt(Self.size))
    os_unfair_lock_lock(locks + hashValue)
    let oldValue = dictionaries[hashValue].updateValue(value, forKey: key)
    return (oldValue, hashValue)
  }
  @inline(__always)
  func get(_ key: String, hashValue: Int) -> Any? {
    return dictionaries[hashValue][key]
  }
  @inline(__always)
  func set(_ key: String, hashValue: Int, value: Any) {
    dictionaries[hashValue][key] = value
  }
  @inline(__always)
  func upsert(_ workspace: SQLiteWorkspace, item: @escaping () -> DictItem) {
    workspace.performChanges([DictItem.self]) {
      let upsertRequest = DictItemChangeRequest.upsertRequest(item())
      $0.try(submit: upsertRequest)
    }
  }
  @inline(__always)
  func upsert(_ workspace: SQLiteWorkspace, item: DictItem) {
    workspace.performChanges([DictItem.self]) {
      let upsertRequest = DictItemChangeRequest.upsertRequest(item)
      $0.try(submit: upsertRequest)
    }
  }
  @inline(__always)
  func remove(_ workspace: SQLiteWorkspace, key: String) {
    let namespace = self.namespace
    workspace.performChanges([DictItem.self]) {
      if let deletionRequest = DictItemChangeRequest.deletionRequest(
        DictItem(key: key, namespace: namespace))
      {
        $0.try(submit: deletionRequest)
      }
    }
  }
  @inline(__always)
  func lock(_ hashValue: Int) {
    os_unfair_lock_lock(locks + hashValue)
  }
  @inline(__always)
  func unlock(_ hashValue: Int) {
    os_unfair_lock_unlock(locks + hashValue)
  }
}

extension SQLiteWorkspaceDictionary {
  func subscribe<Element: Codable & Equatable>(
    _ key: String,
    of: Element.Type, changeHandler: @escaping (_: SubscribedDictionaryValue<Element>) -> Void
  ) -> Workspace.Subscription {
    let subscription = SQLiteDictionarySubscription(key, storage: storage)
    let tuple = storage.getAndLock(key)
    storage.subscribe(
      key, hashValue: tuple.1, identifier: subscription.identifier, of: Element.self,
      changeHandler: changeHandler)
    let fetchedValue: Element?
    if let value = tuple.0 {
      storage.unlock(tuple.1)
      fetchedValue = value is None ? nil : (value as! Element)
    } else {  // Otherwise, try to load from disk.
      storage.unlock(tuple.1)
      // Don't need to fetch from disk if it is disabled.
      if !(withUnsafeMutablePointer(to: &storage.disableDiskFetch) {
        UnsafeAtomic(at: $0).load(ordering: .acquiring)
      }) {
        if let value = workspace.fetch(for: DictItem.self).where(
          DictItem.key == key && DictItem.namespace == storage.namespace
        ).first {
          assert(value.valueType == .codableValue)
          let object: Element? = value.codable.withUnsafeBytes {
            guard let baseAddress = $0.baseAddress else { return nil }
            let decoder = PropertyListDecoder()
            var format = PropertyListSerialization.PropertyListFormat.binary
            return try? decoder.decode(
              Element.self,
              from: Data(
                bytesNoCopy: UnsafeMutableRawPointer(mutating: baseAddress), count: $0.count,
                deallocator: .none), format: &format)
          }
          storage.lock(tuple.1)
          // If no one else populated the cache, do that now.
          if storage.get(key, hashValue: tuple.1) == nil {
            storage.set(key, hashValue: tuple.1, value: object ?? None.none)
          }
          storage.unlock(tuple.1)
          fetchedValue = object
        } else {
          storage.lock(tuple.1)
          // If no one else populated the cache, do that now.
          if storage.get(key, hashValue: tuple.1) == nil {
            storage.set(key, hashValue: tuple.1, value: None.none)
          }
          storage.unlock(tuple.1)
          fetchedValue = nil
        }
      } else {
        fetchedValue = nil
      }
    }
    changeHandler(.initial(fetchedValue))
    return subscription
  }
  func subscribe<Element: FlatBuffersCodable & Equatable>(
    _ key: String,
    of: Element.Type, changeHandler: @escaping (_: SubscribedDictionaryValue<Element>) -> Void
  ) -> Workspace.Subscription {
    let subscription = SQLiteDictionarySubscription(key, storage: storage)
    let tuple = storage.getAndLock(key)
    storage.subscribe(
      key, hashValue: tuple.1, identifier: subscription.identifier, of: Element.self,
      changeHandler: changeHandler)
    let fetchedValue: Element?
    if let value = tuple.0 {
      storage.unlock(tuple.1)
      fetchedValue = value is None ? nil : (value as! Element)
    } else {  // Otherwise, try to load from disk.
      storage.unlock(tuple.1)
      // Don't need to fetch from disk if it is disabled.
      if !(withUnsafeMutablePointer(to: &storage.disableDiskFetch) {
        UnsafeAtomic(at: $0).load(ordering: .acquiring)
      }) {
        if let value = workspace.fetch(for: DictItem.self).where(
          DictItem.key == key && DictItem.namespace == storage.namespace
        ).first {
          assert(value.valueType == .flatBuffersValue)
          let object: Element?
          if value.version == Element.flatBuffersSchemaVersion {
            object = value.codable.withUnsafeBytes {
              guard let baseAddress = $0.baseAddress else { return nil }
              return Element.from(
                byteBuffer: ByteBuffer(
                  assumingMemoryBound: UnsafeMutableRawPointer(mutating: baseAddress),
                  capacity: $0.count))
            }
          } else {
            object = nil
          }
          storage.lock(tuple.1)
          // If no one else populated the cache, do that now.
          if storage.get(key, hashValue: tuple.1) == nil {
            storage.set(key, hashValue: tuple.1, value: object ?? None.none)
          }
          storage.unlock(tuple.1)
          fetchedValue = object
        } else {
          storage.lock(tuple.1)
          // If no one else populated the cache, do that now.
          if storage.get(key, hashValue: tuple.1) == nil {
            storage.set(key, hashValue: tuple.1, value: None.none)
          }
          storage.unlock(tuple.1)
          fetchedValue = nil
        }
      } else {
        fetchedValue = nil
      }
    }
    changeHandler(.initial(fetchedValue))
    return subscription
  }
  func subscribe(
    _ key: String,
    of: Bool.Type, changeHandler: @escaping (_: SubscribedDictionaryValue<Bool>) -> Void
  ) -> Workspace.Subscription {
    let subscription = SQLiteDictionarySubscription(key, storage: storage)
    let tuple = storage.getAndLock(key)
    storage.subscribe(
      key, hashValue: tuple.1, identifier: subscription.identifier, of: Bool.self,
      changeHandler: changeHandler)
    let fetchedValue: Bool?
    if let value = tuple.0 {
      storage.unlock(tuple.1)
      fetchedValue = value is None ? nil : (value as! Bool)
    } else {  // Otherwise, try to load from disk.
      storage.unlock(tuple.1)
      // Don't need to fetch from disk if it is disabled.
      if !(withUnsafeMutablePointer(to: &storage.disableDiskFetch) {
        UnsafeAtomic(at: $0).load(ordering: .acquiring)
      }) {
        if let value = workspace.fetch(for: DictItem.self).where(
          DictItem.key == key && DictItem.namespace == storage.namespace
        ).first {
          assert(value.valueType == .boolValue)
          let object = value.boolValue
          storage.lock(tuple.1)
          // If no one else populated the cache, do that now.
          if storage.get(key, hashValue: tuple.1) == nil {
            storage.set(key, hashValue: tuple.1, value: object)
          }
          storage.unlock(tuple.1)
          fetchedValue = object
        } else {
          storage.lock(tuple.1)
          // If no one else populated the cache, do that now.
          if storage.get(key, hashValue: tuple.1) == nil {
            storage.set(key, hashValue: tuple.1, value: None.none)
          }
          storage.unlock(tuple.1)
          fetchedValue = nil
        }
      } else {
        fetchedValue = nil
      }
    }
    changeHandler(.initial(fetchedValue))
    return subscription
  }
  func subscribe(
    _ key: String,
    of: Int.Type, changeHandler: @escaping (_: SubscribedDictionaryValue<Int>) -> Void
  ) -> Workspace.Subscription {
    let subscription = SQLiteDictionarySubscription(key, storage: storage)
    let tuple = storage.getAndLock(key)
    storage.subscribe(
      key, hashValue: tuple.1, identifier: subscription.identifier, of: Int.self,
      changeHandler: changeHandler)
    let fetchedValue: Int?
    if let value = tuple.0 {
      storage.unlock(tuple.1)
      fetchedValue = value is None ? nil : (value as! Int)
    } else {  // Otherwise, try to load from disk.
      storage.unlock(tuple.1)
      // Don't need to fetch from disk if it is disabled.
      if !(withUnsafeMutablePointer(to: &storage.disableDiskFetch) {
        UnsafeAtomic(at: $0).load(ordering: .acquiring)
      }) {
        if let value = workspace.fetch(for: DictItem.self).where(
          DictItem.key == key && DictItem.namespace == storage.namespace
        ).first {
          assert(value.valueType == .longValue)
          let object = Int(value.longValue)
          storage.lock(tuple.1)
          // If no one else populated the cache, do that now.
          if storage.get(key, hashValue: tuple.1) == nil {
            storage.set(key, hashValue: tuple.1, value: object)
          }
          storage.unlock(tuple.1)
          fetchedValue = object
        } else {
          storage.lock(tuple.1)
          // If no one else populated the cache, do that now.
          if storage.get(key, hashValue: tuple.1) == nil {
            storage.set(key, hashValue: tuple.1, value: None.none)
          }
          storage.unlock(tuple.1)
          fetchedValue = nil
        }
      } else {
        fetchedValue = nil
      }
    }
    changeHandler(.initial(fetchedValue))
    return subscription
  }
  func subscribe(
    _ key: String,
    of: UInt.Type, changeHandler: @escaping (_: SubscribedDictionaryValue<UInt>) -> Void
  ) -> Workspace.Subscription {
    let subscription = SQLiteDictionarySubscription(key, storage: storage)
    let tuple = storage.getAndLock(key)
    storage.subscribe(
      key, hashValue: tuple.1, identifier: subscription.identifier, of: UInt.self,
      changeHandler: changeHandler)
    let fetchedValue: UInt?
    if let value = tuple.0 {
      storage.unlock(tuple.1)
      fetchedValue = value is None ? nil : (value as! UInt)
    } else {  // Otherwise, try to load from disk.
      storage.unlock(tuple.1)
      // Don't need to fetch from disk if it is disabled.
      if !(withUnsafeMutablePointer(to: &storage.disableDiskFetch) {
        UnsafeAtomic(at: $0).load(ordering: .acquiring)
      }) {
        if let value = workspace.fetch(for: DictItem.self).where(
          DictItem.key == key && DictItem.namespace == storage.namespace
        ).first {
          assert(value.valueType == .unsignedLongValue)
          let object = UInt(value.unsignedLongValue)
          storage.lock(tuple.1)
          // If no one else populated the cache, do that now.
          if storage.get(key, hashValue: tuple.1) == nil {
            storage.set(key, hashValue: tuple.1, value: object)
          }
          storage.unlock(tuple.1)
          fetchedValue = object
        } else {
          storage.lock(tuple.1)
          // If no one else populated the cache, do that now.
          if storage.get(key, hashValue: tuple.1) == nil {
            storage.set(key, hashValue: tuple.1, value: None.none)
          }
          storage.unlock(tuple.1)
          fetchedValue = nil
        }
      } else {
        fetchedValue = nil
      }
    }
    changeHandler(.initial(fetchedValue))
    return subscription
  }
  func subscribe(
    _ key: String,
    of: Float.Type, changeHandler: @escaping (_: SubscribedDictionaryValue<Float>) -> Void
  ) -> Workspace.Subscription {
    let subscription = SQLiteDictionarySubscription(key, storage: storage)
    let tuple = storage.getAndLock(key)
    storage.subscribe(
      key, hashValue: tuple.1, identifier: subscription.identifier, of: Float.self,
      changeHandler: changeHandler)
    let fetchedValue: Float?
    if let value = tuple.0 {
      storage.unlock(tuple.1)
      fetchedValue = value is None ? nil : (value as! Float)
    } else {  // Otherwise, try to load from disk.
      storage.unlock(tuple.1)
      // Don't need to fetch from disk if it is disabled.
      if !(withUnsafeMutablePointer(to: &storage.disableDiskFetch) {
        UnsafeAtomic(at: $0).load(ordering: .acquiring)
      }) {
        if let value = workspace.fetch(for: DictItem.self).where(
          DictItem.key == key && DictItem.namespace == storage.namespace
        ).first {
          assert(value.valueType == .floatValue)
          let object = value.floatValue
          storage.lock(tuple.1)
          // If no one else populated the cache, do that now.
          if storage.get(key, hashValue: tuple.1) == nil {
            storage.set(key, hashValue: tuple.1, value: object)
          }
          storage.unlock(tuple.1)
          fetchedValue = object
        } else {
          storage.lock(tuple.1)
          // If no one else populated the cache, do that now.
          if storage.get(key, hashValue: tuple.1) == nil {
            storage.set(key, hashValue: tuple.1, value: None.none)
          }
          storage.unlock(tuple.1)
          fetchedValue = nil
        }
      } else {
        fetchedValue = nil
      }
    }
    changeHandler(.initial(fetchedValue))
    return subscription
  }
  func subscribe(
    _ key: String,
    of: Double.Type, changeHandler: @escaping (_: SubscribedDictionaryValue<Double>) -> Void
  ) -> Workspace.Subscription {
    let subscription = SQLiteDictionarySubscription(key, storage: storage)
    let tuple = storage.getAndLock(key)
    storage.subscribe(
      key, hashValue: tuple.1, identifier: subscription.identifier, of: Double.self,
      changeHandler: changeHandler)
    let fetchedValue: Double?
    if let value = tuple.0 {
      storage.unlock(tuple.1)
      fetchedValue = value is None ? nil : (value as! Double)
    } else {  // Otherwise, try to load from disk.
      storage.unlock(tuple.1)
      // Don't need to fetch from disk if it is disabled.
      if !(withUnsafeMutablePointer(to: &storage.disableDiskFetch) {
        UnsafeAtomic(at: $0).load(ordering: .acquiring)
      }) {
        if let value = workspace.fetch(for: DictItem.self).where(
          DictItem.key == key && DictItem.namespace == storage.namespace
        ).first {
          assert(value.valueType == .doubleValue)
          let object = value.doubleValue
          storage.lock(tuple.1)
          // If no one else populated the cache, do that now.
          if storage.get(key, hashValue: tuple.1) == nil {
            storage.set(key, hashValue: tuple.1, value: object)
          }
          storage.unlock(tuple.1)
          fetchedValue = object
        } else {
          storage.lock(tuple.1)
          // If no one else populated the cache, do that now.
          if storage.get(key, hashValue: tuple.1) == nil {
            storage.set(key, hashValue: tuple.1, value: None.none)
          }
          storage.unlock(tuple.1)
          fetchedValue = nil
        }
      } else {
        fetchedValue = nil
      }
    }
    changeHandler(.initial(fetchedValue))
    return subscription
  }
  func subscribe(
    _ key: String,
    of: String.Type, changeHandler: @escaping (_: SubscribedDictionaryValue<String>) -> Void
  ) -> Workspace.Subscription {
    let subscription = SQLiteDictionarySubscription(key, storage: storage)
    let tuple = storage.getAndLock(key)
    storage.subscribe(
      key, hashValue: tuple.1, identifier: subscription.identifier, of: String.self,
      changeHandler: changeHandler)
    let fetchedValue: String?
    if let value = tuple.0 {
      storage.unlock(tuple.1)
      fetchedValue = value is None ? nil : (value as! String)
    } else {  // Otherwise, try to load from disk.
      storage.unlock(tuple.1)
      // Don't need to fetch from disk if it is disabled.
      if !(withUnsafeMutablePointer(to: &storage.disableDiskFetch) {
        UnsafeAtomic(at: $0).load(ordering: .acquiring)
      }) {
        if let value = workspace.fetch(for: DictItem.self).where(
          DictItem.key == key && DictItem.namespace == storage.namespace
        ).first {
          assert(value.valueType == .stringValue)
          let object = value.stringValue
          storage.lock(tuple.1)
          // If no one else populated the cache, do that now.
          if storage.get(key, hashValue: tuple.1) == nil {
            storage.set(key, hashValue: tuple.1, value: object ?? None.none)
          }
          storage.unlock(tuple.1)
          fetchedValue = object
        } else {
          storage.lock(tuple.1)
          // If no one else populated the cache, do that now.
          if storage.get(key, hashValue: tuple.1) == nil {
            storage.set(key, hashValue: tuple.1, value: None.none)
          }
          storage.unlock(tuple.1)
          fetchedValue = nil
        }
      } else {
        fetchedValue = nil
      }
    }
    changeHandler(.initial(fetchedValue))
    return subscription
  }
  #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func publisher<Element: Codable & Equatable>(_ key: String, of: Element.Type)
      -> DictionaryValuePublisher<Element>
    {
      return SQLiteDictionaryCodableValuePublisher<Element>(dictionary: self, key: key)
    }
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func publisher<Element: FlatBuffersCodable & Equatable>(_ key: String, of: Element.Type)
      -> DictionaryValuePublisher<Element>
    {
      return SQLiteDictionaryFlatBuffersCodableValuePublisher<Element>(dictionary: self, key: key)
    }
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func publisher(_ key: String, of: Bool.Type) -> DictionaryValuePublisher<Bool> {
      return SQLiteDictionaryBoolValuePublisher(dictionary: self, key: key)
    }
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func publisher(_ key: String, of: Int.Type) -> DictionaryValuePublisher<Int> {
      return SQLiteDictionaryIntValuePublisher(dictionary: self, key: key)
    }
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func publisher(_ key: String, of: UInt.Type) -> DictionaryValuePublisher<UInt> {
      return SQLiteDictionaryUIntValuePublisher(dictionary: self, key: key)
    }
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func publisher(_ key: String, of: Float.Type) -> DictionaryValuePublisher<Float> {
      return SQLiteDictionaryFloatValuePublisher(dictionary: self, key: key)
    }
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func publisher(_ key: String, of: Double.Type) -> DictionaryValuePublisher<Double> {
      return SQLiteDictionaryDoubleValuePublisher(dictionary: self, key: key)
    }
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func publisher(_ key: String, of: String.Type) -> DictionaryValuePublisher<String> {
      return SQLiteDictionaryStringValuePublisher(dictionary: self, key: key)
    }
  #endif

  #if compiler(>=5.5) && canImport(_Concurrency)
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func subscribe<Element: Codable & Equatable>(
      _ key: String, of: Element.Type,
      bufferingPolicy: AsyncStream<Element?>.Continuation.BufferingPolicy
    ) -> AsyncStream<Element?> {
      AsyncStream(bufferingPolicy: bufferingPolicy) { continuation in
        let cancellable = self.subscribe(key, of: Element.self) { value in
          switch value {
          case .deleted:
            continuation.yield(nil)
          case .initial(let value):
            continuation.yield(value)
          case .updated(let value):
            continuation.yield(value)
          }
        }
        continuation.onTermination = { @Sendable _ in
          cancellable.cancel()
        }
      }
    }
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func subscribe<Element: FlatBuffersCodable & Equatable>(
      _ key: String, of: Element.Type,
      bufferingPolicy: AsyncStream<Element?>.Continuation.BufferingPolicy
    ) -> AsyncStream<Element?> {
      AsyncStream(bufferingPolicy: bufferingPolicy) { continuation in
        let cancellable = self.subscribe(key, of: Element.self) { value in
          switch value {
          case .deleted:
            continuation.yield(nil)
          case .initial(let value):
            continuation.yield(value)
          case .updated(let value):
            continuation.yield(value)
          }
        }
        continuation.onTermination = { @Sendable _ in
          cancellable.cancel()
        }
      }
    }
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func subscribe(
      _ key: String, of: Bool.Type, bufferingPolicy: AsyncStream<Bool?>.Continuation.BufferingPolicy
    ) -> AsyncStream<Bool?> {
      AsyncStream(bufferingPolicy: bufferingPolicy) { continuation in
        let cancellable = self.subscribe(key, of: Bool.self) { value in
          switch value {
          case .deleted:
            continuation.yield(nil)
          case .initial(let value):
            continuation.yield(value)
          case .updated(let value):
            continuation.yield(value)
          }
        }
        continuation.onTermination = { @Sendable _ in
          cancellable.cancel()
        }
      }
    }
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func subscribe(
      _ key: String, of: Int.Type, bufferingPolicy: AsyncStream<Int?>.Continuation.BufferingPolicy
    ) -> AsyncStream<Int?> {
      AsyncStream(bufferingPolicy: bufferingPolicy) { continuation in
        let cancellable = self.subscribe(key, of: Int.self) { value in
          switch value {
          case .deleted:
            continuation.yield(nil)
          case .initial(let value):
            continuation.yield(value)
          case .updated(let value):
            continuation.yield(value)
          }
        }
        continuation.onTermination = { @Sendable _ in
          cancellable.cancel()
        }
      }
    }
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func subscribe(
      _ key: String, of: UInt.Type, bufferingPolicy: AsyncStream<UInt?>.Continuation.BufferingPolicy
    ) -> AsyncStream<UInt?> {
      AsyncStream(bufferingPolicy: bufferingPolicy) { continuation in
        let cancellable = self.subscribe(key, of: UInt.self) { value in
          switch value {
          case .deleted:
            continuation.yield(nil)
          case .initial(let value):
            continuation.yield(value)
          case .updated(let value):
            continuation.yield(value)
          }
        }
        continuation.onTermination = { @Sendable _ in
          cancellable.cancel()
        }
      }
    }
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func subscribe(
      _ key: String, of: Float.Type,
      bufferingPolicy: AsyncStream<Float?>.Continuation.BufferingPolicy
    ) -> AsyncStream<Float?> {
      AsyncStream(bufferingPolicy: bufferingPolicy) { continuation in
        let cancellable = self.subscribe(key, of: Float.self) { value in
          switch value {
          case .deleted:
            continuation.yield(nil)
          case .initial(let value):
            continuation.yield(value)
          case .updated(let value):
            continuation.yield(value)
          }
        }
        continuation.onTermination = { @Sendable _ in
          cancellable.cancel()
        }
      }
    }
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func subscribe(
      _ key: String, of: Double.Type,
      bufferingPolicy: AsyncStream<Double?>.Continuation.BufferingPolicy
    ) -> AsyncStream<Double?> {
      AsyncStream(bufferingPolicy: bufferingPolicy) { continuation in
        let cancellable = self.subscribe(key, of: Double.self) { value in
          switch value {
          case .deleted:
            continuation.yield(nil)
          case .initial(let value):
            continuation.yield(value)
          case .updated(let value):
            continuation.yield(value)
          }
        }
        continuation.onTermination = { @Sendable _ in
          cancellable.cancel()
        }
      }
    }
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func subscribe(
      _ key: String, of: String.Type,
      bufferingPolicy: AsyncStream<String?>.Continuation.BufferingPolicy
    ) -> AsyncStream<String?> {
      AsyncStream(bufferingPolicy: bufferingPolicy) { continuation in
        let cancellable = self.subscribe(key, of: String.self) { value in
          switch value {
          case .deleted:
            continuation.yield(nil)
          case .initial(let value):
            continuation.yield(value)
          case .updated(let value):
            continuation.yield(value)
          }
        }
        continuation.onTermination = { @Sendable _ in
          cancellable.cancel()
        }
      }
    }
  #endif
}

extension SQLiteWorkspaceDictionary.Storage {
  func cancel(_ key: String, identifier: ObjectIdentifier) {
    let hashValue = hashAndLock(key)
    subscriptions[hashValue][key]?[identifier] = nil
    unlock(hashValue)
  }
  func subscribe<Element>(
    _ key: String, hashValue: Int, identifier: ObjectIdentifier, of: Element.Type,
    changeHandler: @escaping (_: SubscribedDictionaryValue<Element>) -> Void
  ) {
    subscriptions[hashValue][key, default: [:]][identifier] = { value in
      if let value = value {
        assert(value is Element)
        if let value = value as? Element {
          changeHandler(.updated(value))
        } else {
          changeHandler(.deleted)
        }
      } else {
        changeHandler(.deleted)
      }
    }
  }
  @inline(__always)
  func subscriber(_ key: String, hashValue: Int) -> [(Any?) -> Void] {
    if let dictionary = subscriptions[hashValue][key] {
      return Array(dictionary.values)
    }
    return []
  }
}
