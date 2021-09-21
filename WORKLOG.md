2021-09-21
----------

Strict serializable bugs require more tests than we currently have. Right now, it doesn't impose significant penalties because in real world, few people cared about `performChanges([A.self, B.self]` `performChanges([B.self]` and which change block should be executed first in simple apps. These updates can be interleaved and still yield correct result. At the end of the day, if you really care about that, you should use the completion handler. However, having this done correctly can avoid subtle bugs people don't aware previously.

Yesterday, while pondering what can I do to support transactions with dictionary, I looked at our performChanges and found more strict serializable bugs. It comes down to how `DispatchQueue` and `DispatchGroup` may not be the best abstraction to express stream operations, and now I appreciate more CUDA's event / stream model.

What I want to achieve, is to schedule my work on to queues such that when there is a dependency on previous items on the queue, it can be expressed. With DispatchQueue / DispatchGroup, it is possible, but to do that, requires to track every item dispatch to the queue and either use `DispatchWorkItem.notify` or `DispatchGroup.notify`. These are not compatible with `DispatchQueue.async` in the sense that `DispatchGroup.notify(queue: queue` will be dispatched after `queue.async` if the group currently is blocked. To put it simply, there is no API to allow us to manipulate items on the queue. This is in contrast with CUDA's stream / event API, where `EventSignal(stream`, `StreamWait(event` will tap into exactly the point where the work items queued up at that point in time, or any items dispatched after will wait for that particular event. There is no such API on Dispatch side. I am currently end up with a what I believe *correct* but cumbersome way to do this, the good part is if you do this with no cross-table transactions, there is no penality, otherwise, it looks like this:

 1. Pick the primary queue (by sorting the transaction-table identifier), for other queues, we will dispatch async with a new group, and inside that, we will suspend these queues;

 2. DispatchQueue.async on the primary queue, and explicitly wait that group inside the block. This makes sure any blocks dispatched on this queue or any other queues won't get executed until the current block is done;

 3. At the end of the current block, resume other queues.

It is pretty heavy-handed, but it guarantees the correctness in the strict-serializable sense.


2021-09-20
----------

Started to add a key-value store into Dflat. It is a nice, quite useful thing to replace UserDefaults. The implementation uses Dflat as the backing store. The API is really just Dictionary API and supports to persist both Codable and FlatBuffersCodable. FlatBuffersCodable is a new protocol I recently added that all Dflat generated objects conform to. It allows using FlatBuffers format, rather than PlistBinary format (which is the default for Codable we use).

On implementation side, since it is a persisted, thread-safe dictionary, we first partitioned the key space into 8 to avoid lock contentions (if there is any). It is optimistic, thus, we assumes Dflat always succeed in persisting. This allows us to do aggressive caching in-memory. In fact, this thread-safe dictionary never evicts any objects.

One thing I remember is problematic with UserDefaults, is that on first load, it loads the whole world. Our key-value store only loads object by first access. After that, it is served from memory.

This kind of implementation requires closer benchmark to be useful. There are a lot of benchmarks need to make it production-ready.

There are some more considerations:

 1. The current implementation allows to further partition by namespace. This seems to be useful. I've seen people use prefixes for similar thing so that they can group some keys together and remove them together. To support that use case, I also need to add support for .keys.

 2. This is harder. Currently the dictionary doesn't fall into the same transaction context. Thus, if you have perform changes -> updates some other entities, updates the dictionary -> fail the transaction, the updates dictionary part still succeed. This may not be desirable if these data want to be updated together. Potentially, I can make this in one transaction. However, because dictionary have a in-memory cache part, it also means I somehow need to make sure the in-memory part updated properly according to SQLite. This is possible. To some extents, FetchedResult observation already maintains consistency in-memory.

For now, I will address the first while still pondering the second.


2021-04-19
----------

I started the work on GraphQL support in March, but the work started only for 2 days and then interleaved with other works (on both NNC side and some other things). I only got back to work on this yesterday.

The design goal of Dflat's GraphQL (or more precisely, Apollo GraphQL) support is not another its normalized cache layer. Their normalized cache layer is interesting, however, significantly at the mercy of the upper query layer from Apollo GraphQL. That means you cannot have custom query logic to the Dflat directly, nor you cannot merge any any local states with remote states in Dflat transaction / snapshotted fetching.

Our design supports converting from GraphQL fetched objects to Dflat objects through initializers. Thus, you can initialize and upsert / insert Dflat objects into Dflat workspace. The Dflat object itself are shared between different queries (because in GraphQL schema, the represent the same object). This keeps them fresh. That also means the GraphQL schema will be the source-of-truth for the flatbuffers schema for Dflat, hence the "v:" versioning support introduced a few weeks ago (GraphQL schema updates cannot result backward compatible flatbuffers schema upgrade).

While we can *shrink* the schema based on the queries (removing unused properties), GraphQL queries are inevitably recursive. For example, you can have a "Tweet -> Creator -> Recent Tweets", and Flatbuffers schema, or any schema-based serialization format won't be happy with that (this probably is new to anyone starts with Apple's NSArchiver-based serialization, as these supports recursive objects just fine).

On high-level, our schema generator / object initializer generator takes a root object type (the object to be serialized into Dflat), if encountered another reference, will simply replace that with the primary key directly.

On the detailed design though, there are much more choices need to be made.

 1. Will there be namespaces? Yes. But unlike Apollo GraphQL, only object types referenced from the root object type will be namespaced by the root object type name. Thus, if you have root object type Character and have references to object type Human, we can access Human through Character.Human.

 2. How do we represent recursive object reference exactly? It seems more GraphQL-ish if we have `var Character.friends: [Character.Character]`. However, Swift name resolver is not exactly happy with resolving that name, and it only works if you can reference with `var <package name>.Character.friends: [<package name>.Character.Character]`. I elect to just go with raw `String` with no wrapper for the reference. This may well turn out to be a mistake.

 3. How to support interface types? Flatbuffers schema only support union types. Interface types are different from union types because any object types can conform to a interface type as long as they have the same field. However, because interface types in GraphQL can be the type to be queried, for Dflat schema, it cannot just be a protocol. It has to be something that can be concretely constructed and persisted. Thus, for practical reasons, it then has to be represented as union types with helper accessors. This does create some weirdness. For example, we may need to generate helper query too that effectively is `Character.asHuman.name == "abc" || Character.asDroid.name == "abc"`.
