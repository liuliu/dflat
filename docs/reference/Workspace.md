**PROTOCOL**

# `Queryable`

```swift
public protocol Queryable
```

## Methods
### `fetchFor(_:)`

```swift
func fetchFor<Element: Atom>(_ ofType: Element.Type) -> QueryBuilder<Element>
```

Return a QueryBuilder that you can make `where` or `all` queries against.

### `fetchWithinASnapshot(_:)`

```swift
func fetchWithinASnapshot<T>(_: () -> T) -> T
```

Provide a consistent view for fetching multiple objects at once.


**PROTOCOL**

# `Workspace`

```swift
public protocol Workspace: Queryable
```

## Methods
### `shutdown(completion:)`

```swift
func shutdown(completion: (() -> Void)?)
```

Shutdown the Workspace. All transactions made to Dflat after this call will fail.
Transactions initiated before this will finish normally. Data fetching after this
will return empty results. Any data fetching triggered before this call will finish
normally, hence the `completion` part. The `completion` closure, if supplied, will
be called once all transactions and data fetching initiated before shutdown finish.

### `performChanges(_:changesHandler:completionHandler:)`

```swift
func performChanges(_ transactionalObjectTypes: [Any.Type], changesHandler: @escaping ChangesHandler, completionHandler: CompletionHandler?)
```

 Perform a transaction for given object types.

 - Parameters:
    - transactionalObjectTypes: A list of object types you are going to transact with. If you
                                If you fetch or mutation an object outside of this list, it will fatal.
    - changesHandler: The transaction closure where you will give a transactionContext and safe to do
                      data mutations through submission of change requests.
    - completionHandler: If supplied, will be called once the transaction committed. It will be called
                         with success / failure. You don't need to handle failure cases specifically
                         (such as retry), but rather to surface and log such error.

#### Parameters

| Name | Description |
| ---- | ----------- |
| transactionalObjectTypes | A list of object types you are going to transact with. If you If you fetch or mutation an object outside of this list, it will fatal. |
| changesHandler | The transaction closure where you will give a transactionContext and safe to do data mutations through submission of change requests. |
| completionHandler | If supplied, will be called once the transaction committed. It will be called with success / failure. You don’t need to handle failure cases specifically (such as retry), but rather to surface and log such error. |

### `subscribe(fetchedResult:changeHandler:)`

```swift
func subscribe<Element: Atom>(fetchedResult: FetchedResult<Element>, changeHandler: @escaping (_: FetchedResult<Element>) -> Void) -> Subscription where Element: Equatable
```

 Subscribe to changes of a fetched result. You queries fetched result with
 `fetchFor().where()` method and the result can be observed. If any object
 created / updated meet the query criterion, the callback will happen and you
 will get a updated fetched result.

 - Parameters:
    - fetchedResult: The original fetchedResult. If it is outdated already, you will get an updated
                     callback soon after.
    - changeHandler: The callback where you will receive an update if anything changed.

 - Returns: A subscription object that you can cancel the subscription. If no one hold the subscription
            object, it will cancel automatically.

#### Parameters

| Name | Description |
| ---- | ----------- |
| fetchedResult | The original fetchedResult. If it is outdated already, you will get an updated callback soon after. |
| changeHandler | The callback where you will receive an update if anything changed. |

### `subscribe(object:changeHandler:)`

```swift
func subscribe<Element: Atom>(object: Element, changeHandler: @escaping (_: SubscribedObject<Element>) -> Void) -> Subscription where Element: Equatable
```

 Subscribe to changes of an object. If anything in the object changed or
 the object itself is deleted. Deletion is a terminal event for subscription.
 Even if later you inserted an object with the same primary key, the subscription
 callback won't be triggered. This is different from fetched result subscription
 above where if you query by primary key, you will get subscription update if
 a new object with the same primary key later created.

 - Parameters:
    - object: The object to be observed. If it is outdated already, you will get an updated callback
              soon after.
    - changeHandler: The callback where you will receive an update if anything changed.

 - Returns: A subscription object that you can cancel on. If no one hold the subscription, it will cancel
            automatically.

#### Parameters

| Name | Description |
| ---- | ----------- |
| object | The object to be observed. If it is outdated already, you will get an updated callback soon after. |
| changeHandler | The callback where you will receive an update if anything changed. |

### `publisher(for:)`

```swift
func publisher<Element: Atom>(for: Element) -> AtomPublisher<Element> where Element: Equatable
```

Return a publisher for object subscription in Combine.

### `publisher(for:)`

```swift
func publisher<Element: Atom>(for: FetchedResult<Element>) -> FetchedResultPublisher<Element> where Element: Equatable
```

Return a publisher for fetched result subscription in Combine.

### `publisher(for:)`

```swift
func publisher<Element: Atom>(for: Element.Type) -> QueryPublisherBuilder<Element> where Element: Equatable
```

Return a publisher builder for query subscription in Combine.


**CLASS**

# `QueryBuilder`

```swift
open class QueryBuilder<Element: Atom>
```

## Methods
### `init()`

```swift
public init()
```

### `where(_:limit:orderBy:)`

```swift
open func `where`<T: Expr>(_ query: T, limit: Limit = .noLimit, orderBy: [OrderBy] = []) -> FetchedResult<Element> where T.ResultType == Bool
```

 Make query against the Workspace. This is coupled with `fetchFor()` method and shouldn't be used independently.

 - Parameters:
    - query: The query such as `Post.title == "some title" && Post.color == .red`
    - limit: The limit. Default to `.noLimit`, you can supply `.limit(number)`
    - orderBy: The array of keys to order the result. Such as `[Post.priority.descending]`

 - Returns: Return a fetched result which interacts just like normal array.

#### Parameters

| Name | Description |
| ---- | ----------- |
| query | The query such as `Post.title == "some title" && Post.color == .red` |
| limit | The limit. Default to `.noLimit`, you can supply `.limit(number)` |
| orderBy | The array of keys to order the result. Such as `[Post.priority.descending]` |

### `all(limit:orderBy:)`

```swift
open func all(limit: Limit = .noLimit, orderBy: [OrderBy] = []) -> FetchedResult<Element>
```

 Return all objects for a class.

 - Parameters:
    - limit: The limit. Default to `.noLimit`, you can supply `.limit(number)`
    - orderBy: The array of keys to order the result. Such as `[Post.priority.descending]`

 - Returns: Return a fetched result which interacts just like normal array.

#### Parameters

| Name | Description |
| ---- | ----------- |
| limit | The limit. Default to `.noLimit`, you can supply `.limit(number)` |
| orderBy | The array of keys to order the result. Such as `[Post.priority.descending]` |

**PROTOCOL**

# `WorkspaceSubscription`

```swift
public protocol WorkspaceSubscription
```

## Methods
### `cancel()`

```swift
func cancel()
```

Cancel an existing subscription. It is guaranteed that no callback will happen
immediately after `cancel`.


**ENUM**

# `SubscribedObject`

```swift
public enum SubscribedObject<Element: Atom>
```

## Cases
### `updated(_:)`

```swift
case updated(_: Element)
```

Giving the updated object.

### `deleted`

```swift
case deleted
```

The object is deleted. This denotes the end of a subscription.


**CLASS**

# `QueryPublisherBuilder`

```swift
open class QueryPublisherBuilder<Element: Atom> where Element: Equatable
```

## Methods
### `init()`

```swift
public init()
```

### `where(_:limit:orderBy:)`

```swift
open func `where`<T: Expr>(_ query: T, limit: Limit = .noLimit, orderBy: [OrderBy] = []) -> QueryPublisher<Element> where T.ResultType == Bool
```

 Subscribe to a query against the Workspace. This is coupled with `publisher(for: Element.self)` method
 and shouldn't be used independently.

 - Parameters:
    - query: The query such as `Post.title == "some title" && Post.color == .red`
    - limit: The limit. Default to `.noLimit`, you can supply `.limit(number)`
    - orderBy: The array of keys to order the result. Such as `[Post.priority.descending]`

 - Returns: A publisher object that can be interacted with Combine.

#### Parameters

| Name | Description |
| ---- | ----------- |
| query | The query such as `Post.title == "some title" && Post.color == .red` |
| limit | The limit. Default to `.noLimit`, you can supply `.limit(number)` |
| orderBy | The array of keys to order the result. Such as `[Post.priority.descending]` |

### `all(limit:orderBy:)`

```swift
open func all(limit: Limit = .noLimit, orderBy: [OrderBy] = []) -> QueryPublisher<Element>
```

 Subscribe to all changes to a class. This is coupled with `publisher(for: Element.self)` method
 and shouldn't be used independently.

 - Parameters:
   - limit: The limit. Default to `.noLimit`, you can supply `.limit(number)`
   - orderBy: The array of keys to order the result. Such as `[Post.priority.descending]`

 - Returns: A publisher object that can be interacted with Combine.

#### Parameters

| Name | Description |
| ---- | ----------- |
| limit | The limit. Default to `.noLimit`, you can supply `.limit(number)` |
| orderBy | The array of keys to order the result. Such as `[Post.priority.descending]` |