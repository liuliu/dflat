# Features & Trade Offs

If you are familiar with [Core Data](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/index.html) or [Realm](https://realm.io/), you may find **Dflat** rather different. The mutation in Core Data is pretty straight-forward: just assign new values to properties on a subclass of `NSManagedObject`.

In **Dflat**, you need to `performChanges(_:)`, get change request, and then submit to a `TransactionContext`. It is quite a dance. In return though, you can pass the fetched objects around, without worrying whether you need to `object.MR_inContext()`. This, coupled with change subscription mechanism, makes [one-way data flow](https://reactjs.org/docs/thinking-in-react.html) design straight-forward.

On your component, you simply need to subscribe the object and update the UI accordingly.

On your action handler, you call `performChanges(_:)` and submit changes to **Dflat** without worrying about when update will be triggered.

In real-world, this can be a bit more complicated because you want to merge some in-memory states when data propagate to the UI. Thus, the subscriber of object changes likely will be some components sit in the middle, i.e. a view model generator. This [Combine](https://developer.apple.com/documentation/combine)s nicely with Rx programming paradigm.

It also feels limiting that you don't control which thread the mutation happens. **Dflat** does expose some kind of control to you. You can set the `targetQueue` for `SQLiteWorkspace`. Anything beyond that, can only bite you in longer-term. You don't really want any of your queue to be *blocked* because some data persistence happening. As long as there is no coroutine support from Swift side, a completion callback is a necessary evil.

Another criticism, which IMHO is more legit, is the lack of projection support. You can absolutely *join* tables by cleverly use `fetchWithinASnapshot`. But projection, i.e. only selecting a few columns to fetch, can be helpful, especially on Android, where object creation is more expensive (it doesn't help much on data fetching from disk unless [all you fetch is covered by index](https://www.sqlite.org/optoverview.html#covering_indices)). This is doable thanks to flatbuffers' zero-copy implementation. However, it requires a rather different syntax on the IDL (interface description language) to describe the projection concisely. Something like:

```
table Title <- BlogPost {
  permalink <- BlogPost.permalink
  title <- BlogPost.title
}
```

May work, and we can generate the corresponding `Title` object. It just diverges too much from flatbuffers schema to justify the learning curve at the moment.
