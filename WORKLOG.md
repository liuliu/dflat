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
