#!/usr/bin/env bash

sourcedocs generate --spm-module Dflat
sourcedocs generate --spm-module SQLiteDflat

(cat Documentation/Reference/protocols/Queryable.md ; echo -e "\n" ; cat Documentation/Reference/protocols/WorkspaceDictionary.md ; echo -e "\n" ; cat Documentation/Reference/protocols/Workspace.md ; echo -e "\n" ; cat Documentation/Reference/classes/QueryBuilder.md ; echo -e "\n" ; cat Documentation/Reference/protocols/WorkspaceSubscription.md ; echo -e "\n" ; cat Documentation/Reference/enums/SubscribedObject.md ; echo -e "\n" ; cat Documentation/Reference/classes/QueryPublisherBuilder.md) > docs/reference/Workspace.md
(cat Documentation/Reference/protocols/TransactionContext.md ; echo -e "\n" ; cat Documentation/Reference/extensions/TransactionContext.md ; echo -e "\n" ; cat Documentation/Reference/enums/TransactionError.md) > docs/reference/TransactionContext.md
(cat Documentation/Reference/classes/SQLiteWorkspace.md ; echo -e "\n" ; cat Documentation/Reference/enums/SQLiteWorkspace.FileProtectionLevel.md ; echo -e "\n" ; cat Documentation/Reference/enums/SQLiteWorkspace.WriteConcurrency.md ; echo -e "\n" ; cat Documentation/Reference/enums/SQLiteWorkspace.Synchronous.md) > docs/reference/SQLiteWorkspace.md
