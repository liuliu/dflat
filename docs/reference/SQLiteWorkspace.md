**CLASS**

# `SQLiteWorkspace`

```swift
public final class SQLiteWorkspace: Workspace
```

## Properties
### `dictionary`

```swift
public var dictionary: WorkspaceDictionary
```

## Methods
### `init(filePath:fileProtectionLevel:synchronous:writeConcurrency:targetQueue:)`

```swift
public required init(
  filePath: String, fileProtectionLevel: FileProtectionLevel, synchronous: Synchronous = .normal,
  writeConcurrency: WriteConcurrency = .concurrent, targetQueue: DispatchQueue? = nil
)
```

 Return a SQLite backed Workspace instance.

 - Parameters:
    - filePath: The path to the SQLite file. There will be 3 files named filePath, "\(filePath)-wal" and "\(filePath)-shm" created.
    - fileProtectionLevel: The expected protection level for the database file.
    - synchronous: The SQLite synchronous mode, read: https://www.sqlite.org/wal.html#performance_considerations
    - writeConcurrency: Either `.concurrent` or `.serial`.
    - targetQueue: If nil, we will create a queue based on writeConcurrency settings. If you supply your own queue, please read
                   about WriteConcurrency before proceed.

#### Parameters

| Name | Description |
| ---- | ----------- |
| filePath | The path to the SQLite file. There will be 3 files named filePath, “(filePath)-wal” and “(filePath)-shm” created. |
| fileProtectionLevel | The expected protection level for the database file. |
| synchronous | The SQLite synchronous mode, read: https://www.sqlite.org/wal.html#performance_considerations |
| writeConcurrency | Either `.concurrent` or `.serial`. |
| targetQueue | If nil, we will create a queue based on writeConcurrency settings. If you supply your own queue, please read about WriteConcurrency before proceed. |

### `shutdown(completion:)`

```swift
public func shutdown(completion: (() -> Void)?)
```

### `performChanges(_:changesHandler:completionHandler:)`

```swift
public func performChanges(
  _ transactionalObjectTypes: [Any.Type], changesHandler: @escaping Workspace.ChangesHandler,
  completionHandler: Workspace.CompletionHandler? = nil
)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| transactionalObjectTypes | A list of object types you are going to transact with. If you If you fetch or mutation an object outside of this list, it will fatal. |
| changesHandler | The transaction closure where you will give a transactionContext and safe to do data mutations through submission of change requests. |
| completionHandler | If supplied, will be called once the transaction committed. It will be called with success / failure. You don’t need to handle failure cases specifically (such as retry), but rather to surface and log such error. |

### `performChanges(_:changesHandler:)`

```swift
public func performChanges(
  _ transactionalObjectTypes: [Any.Type], changesHandler: @escaping ChangesHandler
) async -> Bool
```

 Perform a transaction for given object types and await either success or failure boolean.

 - Parameters:
    - transactionalObjectTypes: A list of object types you are going to transact with. If you
                                If you fetch or mutation an object outside of this list, it will fatal.
    - changesHandler: The transaction closure where you will give a transactionContext and safe to do
                      data mutations through submission of change requests.

### `fetch(for:)`

```swift
public func fetch<Element: Atom>(for ofType: Element.Type) -> QueryBuilder<Element>
```

### `fetchWithinASnapshot(_:)`

```swift
public func fetchWithinASnapshot<T>(_ closure: () -> T) -> T
```

### `subscribe(fetchedResult:changeHandler:)`

```swift
public func subscribe<Element: Atom & Equatable>(
  fetchedResult: FetchedResult<Element>,
  changeHandler: @escaping (_: FetchedResult<Element>) -> Void
) -> Workspace.Subscription
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| fetchedResult | The original fetchedResult. If it is outdated already, you will get an updated callback soon after. |
| changeHandler | The callback where you will receive an update if anything changed. |

### `subscribe(object:changeHandler:)`

```swift
public func subscribe<Element: Atom & Equatable>(
  object: Element, changeHandler: @escaping (_: SubscribedObject<Element>) -> Void
) -> Workspace.Subscription
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| object | The object to be observed. If it is outdated already, you will get an updated callback soon after. |
| changeHandler | The callback where you will receive an update if anything changed. |

### `publisher(for:)`

```swift
public func publisher<Element: Atom & Equatable>(for object: Element) -> AtomPublisher<Element>
```

### `publisher(for:)`

```swift
public func publisher<Element: Atom & Equatable>(for fetchedResult: FetchedResult<Element>)
  -> FetchedResultPublisher<Element>
```

### `publisher(for:)`

```swift
public func publisher<Element: Atom & Equatable>(for: Element.Type) -> QueryPublisherBuilder<
  Element
>
```

### `subscribe(object:bufferingPolicy:)`

```swift
public func subscribe<Element: Atom & Equatable>(
  object: Element, bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy
) -> AsyncStream<Element>
```

### `subscribe(fetchedResult:bufferingPolicy:)`

```swift
public func subscribe<Element: Atom & Equatable>(
  fetchedResult: FetchedResult<Element>,
  bufferingPolicy: AsyncStream<FetchedResult<Element>>.Continuation.BufferingPolicy
) -> AsyncStream<FetchedResult<Element>>
```


**ENUM**

# `SQLiteWorkspace.FileProtectionLevel`

```swift
public enum FileProtectionLevel: Int32
```

## Cases
### `noProtection`

```swift
case noProtection = 4
```

Class D: No protection. If the device is booted, in theory, you can access the content.
When it is not booted, the content is protected by the Secure Enclave's hardware key.

### `completeFileProtection`

```swift
case completeFileProtection = 1
```

Class A: The file is accessible if the phone is unlocked and the app is in foreground.
You will lose the file access if the app is backgrounded or the phone is locked.

### `completeFileProtectionUnlessOpen`

```swift
case completeFileProtectionUnlessOpen = 2
```

Class B: The file is accessible if the phone is unlocked. You will lose the file access
if the phone is locked.

### `completeFileProtectionUntilFirstUserAuthentication`

```swift
case completeFileProtectionUntilFirstUserAuthentication = 3
```

Class C: The file is accessible once user unlocked the phone once. The file cannot be
accessed prior to that. For example, if you received a notification before first device
unlock, the underlying database cannot be open successfully.


**ENUM**

# `SQLiteWorkspace.WriteConcurrency`

```swift
public enum WriteConcurrency
```

## Cases
### `concurrent`

```swift
case concurrent
```

Enable strict serializable multi-writer / multi-reader mode. Note that SQLite under the
hood still writes serially. It only means the transaction closures can be executed
concurrently. If you provided a targetQueue, please make sure it is a concurrent queue
otherwise it will still execute transaction closure serially. The targetQueue is supplied
by you, should be at reasonable priority, at least `.default`, because it sets the ceiling
for any sub-queues targeting that, and we may need to bump the sub-queues depending on
where you `performChanges`.

### `serial`

```swift
case serial
```

Enable single-writer / multi-reader mode. This will execute transaction closures serially.
If you supply a targetQueue, please make sure it is serial. It is safe for this serial queue
to have lower priority such as `.utility`, because we can bump the priority based on where
you call `performChanges`.


**ENUM**

# `SQLiteWorkspace.Synchronous`

```swift
public enum Synchronous
```

The synchronous mode of SQLite. We defaults to `.normal`. Read more on: [https://www.sqlite.org/wal.html#performance_considerations](https://www.sqlite.org/wal.html#performance_considerations)

## Cases
### `normal`

```swift
case normal
```

### `full`

```swift
case full
```
