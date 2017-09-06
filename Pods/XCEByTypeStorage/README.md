# ByTypeStorage
Data container that allows to store values using type as a key.



It's Dictionary-like (and Dictionary-based) key-value storage where key is derived from a type provided. Internally keyas are just strings generated from a given key type full name (that includes module name, and all parent types in case of nested types). This feature allows to avoid the need of hard-coded string-based keys, improves type-safety, simplifies usage. Obviously, this data container is supposed to be used with custom data types that have some domain-specific semantics in their names and every value associated with this type supposed to be unique within each given storage.