# Dflat: {PLACEHOLDER}

I've been writing different structured data persistence systems on mobile for the past a few years. Dflat is an accumulation of lessons-learned when building these proprietary systems. On iOS particular, the go-to choice long has been Core Data. It works, and is the internal data persistence mechanism for many system apps.

But when deploying structured data persistence system to hundreds of millions mobile devices, there are certain challenges, both on the intrinsics of how data is persisted, and on high level how the rest of the app interact with such system.

The Dflat codebase is still in a very young stage, however, the underlying principles have been proving successful in other proprietary systems. In no particular order:

 1. The system defaults to return immutable data objects that can be passed down to other systems (such as the view model generators);

 2. All queries and objects can be observed, updates will be published through either callbacks or Combine framework;

 3. Mutation can only happen on separate threads that caller has little control over, thus, asynchronously;

 4. Data fetching can happen concurrently and synchronously on any thread;

 5. Multi-writer / multi-reader mode is supported and can choose single-writer / multi-reader mode if desire;

 6. Data queries can be expressed with Swift code, and will be type-checked;

 7. Schema upgrades require no write-access to the underlying database.

Unlike Core Data, Dflat is built from ground-up with Swift. You can express your data model by taking full advantage of the Swift language. Thus, a native support for `struct` (product-type), `enum` (sum-type), type-checked query and Combine framework.
