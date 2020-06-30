# Schema Upgrade

In [Schema Evolution](../schema.md), we briefly touched the general rules of schema upgrade. To be more precise, this note will discuss the exact rules with examples.

Consider a relatively simple schema:

```
table TextContent {
  text: string;
}

union Content {
  TextContent
}

table BlogPost {
  title: string (primary);
  datetime: int;
  content: Content;
}

root_type BlogPost;
```

It is OK to change names of any property, append new fields to the end and deprecate old field. However, you cannot change types of a field, or move them around.

```
table TextContent {
  text: string (deprecated);
  attributedText: string;
}

table ImageContent {
  images: [string];
}

union Content {
  TextContent,
  ImageContent
}

table BlogPost {
  permalink: string (primary);
  datetime: int (deprecated);
  multimediaContent: Content;
  title: string (indexed);
  unixTime: ulong;
}

root_type BlogPost;
```

As much different as the schemas looked, they are compatible. You can upgrade / downgrade them from one to another because they [follow the rules](https://google.github.io/flatbuffers/md__schemas.html#Gotchas).

In addition, remember: you can rename a primary key, but you cannot change or add a primary key. I may write a compatibility checker in the future, since rules can be more nuanced.
