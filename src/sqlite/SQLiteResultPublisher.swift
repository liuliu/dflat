import Dflat
import SwiftAtomics

enum SQLiteSubscriptionType {
  case object(_: Any.Type, _: Int64)
  case fetchedResult(_: Any.Type, _: ObjectIdentifier)
}

final class SQLiteSubscription: Workspace.Subscription {
  private let ofType: SQLiteSubscriptionType
  var cancelled = AtomicBool(false)
  let identifier: ObjectIdentifier
  weak var workspace: SQLiteWorkspace?
  init(ofType: SQLiteSubscriptionType, identifier: ObjectIdentifier, workspace: SQLiteWorkspace) {
    self.ofType = ofType
    self.identifier = identifier
    self.workspace = workspace
  }
  deinit {
    cancelled.store(true)
    workspace?.cancel(ofType: ofType, identifier: identifier)
  }
  public func cancel() {
    cancelled.store(true)
    workspace?.cancel(ofType: ofType, identifier: identifier)
  }
}

protocol ResultPublisher {
  func publishUpdates(_ updatedObjects: [Int64: UpdatedObject], reader: SQLiteConnectionPool.Borrowed, changesTimestamp: Int64)
  func cancel(object: Int64, identifier: ObjectIdentifier)
  func cancel(fetchedResult: ObjectIdentifier, identifier: ObjectIdentifier)
}

// The access to this class is protected at least one per table.
final class SQLiteResultPublisher<Element: Atom>: ResultPublisher {
  private var objectSubscribers = [Int64: [ObjectIdentifier: (_: UpdatedObject) -> Void]]()

  func subscribe(object: Element, changeHandler: @escaping (_: SubscribedObject<Element>) -> Void, subscription: SQLiteSubscription) {
    let rowid = object._rowid
    objectSubscribers[rowid, default: [ObjectIdentifier: (_: UpdatedObject) -> Void]()][subscription.identifier] = { [weak self, weak subscription] updatedObject in
      guard let subscription = subscription else { return }
      guard !subscription.cancelled.load() else { return }
      guard let self = self else { return }
      switch updatedObject {
      case .deleted(let rowid):
        // Unsubscribe itself. Once object is deleted, we cannot continue to observe it.
        self.objectSubscribers[rowid]![subscription.identifier] = nil
        if self.objectSubscribers[rowid]!.count == 0 {
          self.objectSubscribers[rowid] = nil
        }
        changeHandler(.deleted)
      case .updated(let atom):
        changeHandler(.updated(atom as! Element))
      case .identity(_):
        fatalError() // We shouldn't process identity updated objects.
      case .inserted(_):
        fatalError() // This is awkward. We shouldn't process inserted objects.
      }
    }
  }

  final class SQLiteFetchedResultPublisher {
    private var objects: Set<Int64>
    private var fetchedResult: SQLiteFetchedResult<Element>
    var subscribers = [ObjectIdentifier: (_: FetchedResult<Element>) -> Void]()
    init(fetchedResult: SQLiteFetchedResult<Element>) {
      self.fetchedResult = fetchedResult
      objects = Set(fetchedResult.map { $0._rowid })
    }

    func publishUpdates(_ updatedObjects: [Int64: UpdatedObject], reader: SQLiteConnectionPool.Borrowed, changesTimestamp: Int64) {
      var underlyingArray = fetchedResult.underlyingArray
      let query = fetchedResult.query
      let orderBy = fetchedResult.orderBy
      let limit = fetchedResult.limit
      var elementsToBeInserted = [Element]()
      var rowidsToBeRemoved = Set<Int64>()
      var resultUpdated = false
      for (rowid, updatedObject) in updatedObjects {
        switch updatedObject {
        case .identity(_):
          fatalError() // We shouldn't process identity updated objects.
        case .inserted(let object):
          let element = object as! Element
          let retval = fetchedResult.query.evaluate(object: .object(element))
          if retval.result && !retval.unknown {
            elementsToBeInserted.append(element)
          }
          break
        case .updated(let object):
          let element = object as! Element
          let retval = query.evaluate(object: .object(element))
          if retval.result && !retval.unknown {
            // It belongs to the output.
            if objects.contains(rowid) {
              // This object is in the list, now just need to check whether we need to update the order.
              let index = underlyingArray.indexSorted(element, orderBy: orderBy)
              if underlyingArray[index]._rowid == rowid {
                underlyingArray[index] = element // Inplace replacement
                resultUpdated = true
              } else {
                elementsToBeInserted.append(element)
                rowidsToBeRemoved.insert(rowid)
              }
            } else {
              // This hasn't been added before, add it now.
              elementsToBeInserted.append(element)
            }
          } else if objects.contains(rowid) {
            rowidsToBeRemoved.insert(rowid)
          }
          break
        case .deleted(let rowid):
          if objects.contains(rowid) {
            rowidsToBeRemoved.insert(rowid)
          }
        }
      }
      resultUpdated = resultUpdated || rowidsToBeRemoved.count > 0 || elementsToBeInserted.count > 0
      // First, remove objects.
      if rowidsToBeRemoved.count > 0 {
        objects.subtract(rowidsToBeRemoved)
        underlyingArray.removeAll { rowidsToBeRemoved.contains($0._rowid) }
      }
      // Then insert relevant elements back.
      for element in elementsToBeInserted {
        underlyingArray.insertSorted(element, orderBy: orderBy)
        objects.insert(element._rowid)
        if case .limit(let limit) = limit {
          if underlyingArray.count > limit {
            precondition(underlyingArray.count == limit + 1)
            objects.remove(underlyingArray[limit]._rowid)
            underlyingArray.removeLast()
          }
        }
      }
      if resultUpdated {
        if case .limit(let numLimit) = limit {
          if fetchedResult.count == numLimit && underlyingArray.count < numLimit {
            // If previously it is full, we need to fetch the database again to fill in the rest.
            SQLiteQueryWhere(reader: reader, workspace: nil, transactionContext: nil, changesTimestamp: changesTimestamp, query: query, limit: limit, orderBy: orderBy, offset: underlyingArray.count, result: &underlyingArray)
          }
        }
        fetchedResult = SQLiteFetchedResult(underlyingArray, changesTimestamp: changesTimestamp, query: query, limit: limit, orderBy: orderBy)
        for (_, changeHandler) in subscribers {
          changeHandler(fetchedResult)
        }
      }
    }
  }
  private var fetchedResultSubscribers = [ObjectIdentifier: SQLiteFetchedResultPublisher]()

  func subscribe(fetchedResult: SQLiteFetchedResult<Element>, resultIdentifier: ObjectIdentifier, changeHandler: @escaping (_: FetchedResult<Element>) -> Void, subscription: SQLiteSubscription) {
    let resultPublisher: SQLiteFetchedResultPublisher
    if let pub = fetchedResultSubscribers[resultIdentifier] {
      resultPublisher = pub
    } else {
      resultPublisher = SQLiteFetchedResultPublisher(fetchedResult: fetchedResult)
      fetchedResultSubscribers[resultIdentifier] = resultPublisher
    }
    resultPublisher.subscribers[subscription.identifier] = { [weak subscription] fetchedResult in
      guard let subscription = subscription else { return }
      guard !subscription.cancelled.load() else { return }
      changeHandler(fetchedResult)
    }
  }
  
  func publishUpdates(_ updatedObjects: [Int64: UpdatedObject], reader: SQLiteConnectionPool.Borrowed, changesTimestamp: Int64) {
    // First, publish updates to object observer
    for (rowid, updatedObject) in updatedObjects {
      guard let subscribers = objectSubscribers[rowid] else { continue }
      for (_, changeHandler) in subscribers {
        changeHandler(updatedObject)
      }
    }
    // Second, check whether this object should be in a fetched result, if so, update fetchedResult array
    for (_, resultPublisher) in fetchedResultSubscribers {
      resultPublisher.publishUpdates(updatedObjects, reader: reader, changesTimestamp: changesTimestamp)
    }
  }

  func cancel(object rowid: Int64, identifier: ObjectIdentifier) {
    guard objectSubscribers[rowid] != nil else { return }
    objectSubscribers[rowid]![identifier] = nil
    if objectSubscribers[rowid]!.count == 0 {
      objectSubscribers[rowid] = nil
    }
  }

  func cancel(fetchedResult: ObjectIdentifier, identifier: ObjectIdentifier) {
    guard let resultPublisher = fetchedResultSubscribers[fetchedResult] else { return }
    resultPublisher.subscribers[identifier] = nil
    if resultPublisher.subscribers.count == 0 {
      fetchedResultSubscribers[fetchedResult] = nil
    }
  }
}
