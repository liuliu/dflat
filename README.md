# Dflat: SQLite ❤️  FlatBuffers

If you are familiar with [Core Data](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/index.html) or [Realm](https://realm.io/), **Dflat** occupies the same space as these two in your application. Unlike these two, **Dflat** has a different set of features and makes very different trade-offs. These features and trade-offs are grounded from real-world experiences in writing some of the world largest apps. **Dflat** is also built from ground-up using Swift and hopefully, you will find it is natural to interact with in Swift.

## Features

I've been writing different structured data persistence systems on mobile for the past a few years. **Dflat** is an accumulation of lessons-learned when building these proprietary systems. On iOS particular, the go-to choice long has been **Core Data**. It works, and is the internal data persistence mechanism for many system apps.

But when deploying structured data persistence system to hundreds of millions mobile devices, there are certain challenges, both on the intrinsics of how data is persisted, and on a higher-level how the rest of the app interact with such system.

The **Dflat** codebase is still in a very young stage. However, the underlying principles have been proving successful in other proprietary systems. **Dflat** implemented the following features in no particular order:

 1. The system returns immutable data objects that can be passed down to other systems (such as your view model generators);

 2. All queries and objects can be observed. Updates will be published through either callbacks or Combine framework;

 3. Mutation can only happen on separate threads that caller has little control over, thus, asynchronously;

 4. Data fetching can happen concurrently and synchronously on any thread by caller's choice;

 5. [Strict serializable](https://jepsen.io/consistency/models/strict-serializable) multi-writer / multi-reader mode is supported but users can choose single-writer (thus, trivially S.S.) / multi-reader mode if they desire;

 6. Data queries are expressed with Swift code, and will be type-checked by the Swift compiler;

 7. Schema upgrades require no write-access to the underlying database (strict read-only is possible with SQLite 3.22 and above).

Unlike **Core Data**, **Dflat** is built from ground-up with Swift. You can express your data model by taking full advantage of the Swift language. Thus, a native support for `struct` (product-type), `enum` (sum-type), with type-checked queries and observing with [Combine](https://developer.apple.com/documentation/combine).
