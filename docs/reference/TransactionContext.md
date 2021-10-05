**PROTOCOL**

# `TransactionContext`

```swift
public protocol TransactionContext
```

## Methods
### `submit(_:)`

```swift
func submit(_: ChangeRequest) throws -> UpdatedObject
```

Submit a change request in a transaction. The change will be available immediately inside this
transaction and will be available once the transaction closure is done to everyone outside of
the transaction closure. It throws a `TransactionError` if there are errors. Otherwise, return
UpdatedObject to denote whether you inserted, updated or deleted an object.

### `abort()`

```swift
func abort() -> Bool
```

Abort the current transaction. This will cause whatever happened inside the current transaction
to rollback immediately, and anything submitted after abort will throw `TransactionError.aborted`
error.


**EXTENSION**

# `TransactionContext`
```swift
extension TransactionContext
```

## Methods
### `try(submit:)`

```swift
public func `try`(submit changeRequest: ChangeRequest) -> UpdatedObject?
```

Convenient method for submit change request. `submit()` may throw exceptions, but `try(submit:)` will
not. Rather, it will fatal in case of `TransactionError.objectAlreadyExists`. For any other types of
`TransactionError`, it will simply return nil.


**ENUM**

# `TransactionError`

```swift
public enum TransactionError: Error
```

## Cases
### `aborted`

```swift
case aborted
```

The transaction has been aborted already before submitting the request.

### `objectAlreadyExists`

```swift
case objectAlreadyExists
```

The object already exists. Conflict on either primary keys or unique properties.

### `diskFull`

```swift
case diskFull
```

We will rollback the whole transaction in case of disk full.

### `others`

```swift
case others
```

Other types of errors, in these cases, we will simply rollback the whole transaction.
