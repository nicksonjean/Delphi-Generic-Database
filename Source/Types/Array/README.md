# Source/Types/Array

Helper types and extensions for working with Delphi arrays — from generic dynamic arrays to specialized typed variants.

---

## Units

### `Type.Array.Helper` (`Type.Array.Helper.pas`)

**Extends the native `TArray` class helper** and provides `TArrayRecord<T>`, a lightweight record wrapper for dynamic arrays that behaves like a managed collection without the need to `Free` anything.

#### TArrayNativeHelper — class helper for TArray

| Method | Description |
|---|---|
| `Add<T>` | Appends an item and returns its index |
| `Delete<T>` | Removes item at index |
| `Insert<T>` | Inserts item at index |
| `AddRange<T>` | Appends an array |
| `InsertRange<T>` | Inserts an array at index |
| `IndexOf<T>` | Linear search, returns index or -1 |
| `IndexOfMax<T>` | Returns index of largest item |
| `IndexOfMin<T>` | Returns index of smallest item |
| `Contains<T>` | Returns true if item exists |
| `Compare<T>` | Deep comparison of two arrays |
| `ForEach<T>` | Iterates with a callback `(var Value; Index)` |
| `Find<T>` | Returns index of first matching item via callback |
| `Map<T>` | Filters/transforms array using a callback |

All overloads accept an optional `IComparer<T>` for custom ordering/equality.

#### TArrayRecord&lt;T&gt; — value-type array container

Wraps `TArray<T>` in a record so you can pass it by value or store it in a field without managing heap memory.

```delphi
var
  A: TArrayRecord<string>;
begin
  A.SetItems(['a', 'b', 'c']);
  A.Add('d');
  Assert(A.Count = 4);
  Assert(A[1] = 'b');
  Assert(A.IndexOf('a') = 0);
  for S in A do
    ...
```

Operator overloads: `=` and `<>` (deep equality via `Compare`).

---

### `Type.Array` (`Type.Array.pas`)

Core generic array types and foundational definitions shared by the other units in this folder.

---

### `Type.Array.String` (`Type.Array.String.pas`)

Specialization for `TArray<string>` — typed alias and utilities optimised for string arrays.

#### Usage

```delphi
uses &Type.&Array.&String;

var
  Names: TArrayString;
begin
  Names := TArrayString.From(['Alice', 'Bob', 'Carol']);
  Names.Sort;
```

---

### `Type.Array.String.Helper` (`Type.Array.String.Helper.pas`)

Class helper that augments `TArrayString` with convenience methods:

- `Join(Separator)` — concatenates items into a single string
- `Contains(Value)` — case-sensitive membership check
- `Filter(Callback)` — returns a new `TArrayString` with matching items
- `Map(Callback)` — transforms each item

---

### `Type.Array.Variant` (`Type.Array.Variant.pas`)

Specialization for `TArray<Variant>`, useful when interacting with database field values or heterogeneous data sets.

```delphi
uses &Type.&Array.Variant;

var
  Row: TArrayVariant;
begin
  Row := TArrayVariant.From([42, 'hello', True]);
```

---

### `Type.Array.Variant.Helper` (`Type.Array.Variant.Helper.pas`)

Class helper for `TArrayVariant`:

- `AsString(Index)` — safe cast to string
- `AsInteger(Index)` — safe cast to integer
- `IsNull(Index)` — checks for Null/Unassigned

---

### `Type.Array.Field` (`Type.Array.Field.pas`)

Represents an ordered list of database field descriptors (`TFieldItem`), mapping column names to values in query results or parameter lists.

```delphi
uses &Type.&Array.Field;

var
  Fields: TArrayField;
begin
  Fields.Add(TFieldItem.Create('Name', 'Alice'));
  Fields.Add(TFieldItem.Create('Age', 30));
```

---

### `Type.Array.Field.Helper` (`Type.Array.Field.Helper.pas`)

Class helper for `TArrayField`:

- `FindByName(Name)` — returns the index of a field by name
- `ValueOf(Name)` — returns the value for a given field name
- `ToVariantArray` — converts to `TArrayVariant` for generic handling

---

### `Type.Array.Assoc` (`Type.Array.Assoc.pas`)

An associative (key→value) array built on top of `TArrayField`.  Useful as a lightweight ordered map when you want named access without the overhead of a `TDictionary`.

```delphi
uses &Type.&Array.Assoc;

var
  Map: TArrayAssoc;
begin
  Map['host'] := 'localhost';
  Map['port'] := '5432';
  WriteLn(Map['host']);  // 'localhost'
```

---

### `Type.Array.Guard.Intf` (`Type.Array.Guard.Intf.pas`)

Interface definition for array guard objects — Smart Pointer integration for arrays that must be released automatically when they leave scope.

---

## Array Type Quick-Reference

| Type | Unit | Element type | Best for |
|---|---|---|---|
| `TArray<T>` | RTL (extended by Helper) | any | General-purpose dynamic array |
| `TArrayRecord<T>` | `Type.Array.Helper` | any | Value-type array, no Free needed |
| `TArrayString` | `Type.Array.String` | `string` | Lists of text values |
| `TArrayVariant` | `Type.Array.Variant` | `Variant` | DB rows, heterogeneous data |
| `TArrayField` | `Type.Array.Field` | `TFieldItem` | Ordered field descriptor lists |
| `TArrayAssoc` | `Type.Array.Assoc` | key→value pair | Named-access ordered map |

---

## Adding to your project

Include all array types at once via the aggregate unit:

```delphi
uses &Type.All;
```

Or pick only what you need:

```delphi
uses
  &Type.&Array,
  &Type.&Array.Helper,
  &Type.&Array.&String,
  &Type.&Array.Variant;
```

---

## Credits

`Type.Array.Helper` is derived from **ArrayHelper v1.3** by Willi Commer (GNU Licence).  
Original: https://github.com/WilliCommer/ArrayHelper
