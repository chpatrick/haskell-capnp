{- |
Module: Capnp.Tutorial
Description: Tutorial for the Haskell Cap'N Proto library.

This module provides a tutorial on the overall usage of the library. Note that
it does not aim to provide a thorough introduction to capnproto itself; see
<https://capnproto.org> for general information.

-}
{-# OPTIONS_GHC -Wno-unused-imports #-}
module Capnp.Tutorial (
    -- * Overview
    -- $overview

    -- * High Level API
    -- $highlevel

    -- ** Example
    -- $highlevel-example

    -- ** Code Generation Rules
    -- $highlevel-codegen-rules

    -- * Low Level API
    -- $lowlevel

    -- ** Example
    -- $lowlevel-example

    -- ** Write Support
    -- $lowlevel-write
    ) where

-- So haddock references work:
import System.IO (stdout)

import qualified Data.ByteString as BS
import qualified Data.Text       as T

import Capnp

import Capnp.Classes (FromStruct)

{- $overview

The API is roughly divided into two parts: a low level API and a high
level API. The high level API eschews some of the benefits of the wire
format in favor of a more convenient interface.
-}

{- $highlevel

The high level API exposes capnproto values as regular algebraic data
types.

On the plus side:

* This makes it easier to work with capnproto values using idiomatic
  Haskell code
* Because we have to parse the data up-front we can *validate* the data
  up front, so (unlike the low level API), you will not have to deal with
  errors while traversing the message.

Both of these factors make the high level API generally more pleasant
to work with and less error-prone than the low level API.

The downside is that you can't take advantage of some of the novel
properties of the wire format. In particular:

* It is theoretically slower, as there is a marshalling step involved
  (actual performance has not been measured).
* You can't mmap a file and read in only part of it.
* You can't modify a message in-place.

-}

{- $highlevel-example

As a running example, we'll use the following schema (borrowed from the
C++ implementation's documentation):

> # addressbook.capnp
> @0xcd6db6afb4a0cf5c;
>
> struct Person {
>   id @0 :UInt32;
>   name @1 :Text;
>   email @2 :Text;
>   phones @3 :List(PhoneNumber);
>
>   struct PhoneNumber {
>     number @0 :Text;
>     type @1 :Type;
>
>     enum Type {
>       mobile @0;
>       home @1;
>       work @2;
>     }
>   }
>
>   employment :union {
>     unemployed @4 :Void;
>     employer @5 :Text;
>     school @6 :Text;
>     selfEmployed @7 :Void;
>     # We assume that a person is only one of these.
>   }
> }
>
> struct AddressBook {
>   people @0 :List(Person);
> }

Once the @capnp@ and @capnpc-haskell@ executables are installed and in
your @$PATH@, you can generate code for this schema by running:

> capnp compile -ohaskell addressbook.capnp

This will create the following files relative to the current directory:

* Capnp\/Gen\/Addressbook.hs
* Capnp\/Gen\/Addressbook\/Pure.hs
* Capnp\/Gen\/ById\/Xcd6db6afb4a0cf5c/Pure.hs
* Capnp\/Gen\/ById\/Xcd6db6afb4a0cf5c.hs

The modules under @ById@ are an implementation detail.
@Capnp\/Gen\/Addressbook.hs@ is generated code for use with the low level API.
@Capnp\/Gen\/Addressbook\/Pure.hs@ is generated code for use with the high
level API. The latter will export the following data declarations (cleaned up
for readability).

> module Capnp.Gen.Addressbook.Pure where
>
> import Data.Int
> import Data.Text   (Text)
> import Data.Vector (Vector)
> import Data.Word
>
> data AddressBook = AddressBook
>     { people :: Vector Person
>     }
>
> data Person = Person
>     { id         :: Word32
>     , name       :: Text
>     , email      :: Text
>     , phones     :: Vector Person'PhoneNumber
>     , employment :: Person'employment
>     }
>
> data Person'PhoneNumber = Person'PhoneNumber
>     { number :: Text
>     , type_  :: Person'PhoneNumber'Type
>     }
>
> data Person'employment
>     = Person'employment'unemployed
>     | Person'employment'employer Text
>     | Person'employment'school Text
>     | Person'employment'selfEmployed
>     | Person'employment'unknown' Word16
>
> data Person'PhoneNumber'Type
>     = Person'PhoneNumber'Type'mobile
>     | Person'PhoneNumber'Type'home
>     | Person'PhoneNumber'Type'work
>     | Person'PhoneNumber'Type'unknown' Word16

Note that we use the single quote character as a namespace separator for
namespaces within a single capnproto schema.

The module also exports instances of several type classes:

* 'Show'
* 'Read'
* 'Eq'
* 'Generic' from "GHC.Generics"
* 'Default' from the @data-default@ package.
* A number of type classes defined by the @capnp@ package.
* Capnproto enums additionally implement the 'Enum' type class.

Using the @Default@ instance to construct values means that your
existing code will continue to work if new fields are added in the
schema, but it also makes it easier to forget to set a field if you had
intended to. The instance maps @'def'@ to the default value as defined by
capnproto, so leaving out newly-added fields will do The Right Thing.

The module "Capnp" exposes the most frequently used
functionality from the capnp package. We can write an address book
message to standard output using the high-level API like so:

> {-# LANGUAGE OverloadedStrings     #-}
> -- Note that DuplicateRecordFields is usually needed, as the generated
> -- code relys on it to resolve collisions in capnproto struct field
> -- names:
> {-# LANGUAGE DuplicateRecordFields #-}
> import Capnp.Gen.Addressbook.Pure
>
> -- Note that Capnp re-exports `def`, as a convienence
> import Capnp (putValue, def)
>
> import qualified Data.Vector as V
>
> main = putValue AddressBook
>     { people = V.fromList
>         [ Person
>             { id = 123
>             , name = "Alice"
>             , email = "alice@example.com"
>             , phones = V.fromList
>                 [ def
>                     { number = "555-1212"
>                     , type_ =  Person'PhoneNumber'Type'mobile
>                     }
>                 ]
>             , employment = Person'employment'school "MIT"
>             }
>         , Person
>             { id = 456
>             , name = "Bob"
>             , email = "bob@example.com"
>             , phones = V.fromList
>                 [ def
>                     { number = "555-4567"
>                     , type_ = Person'PhoneNumber'Type'home
>                     }
>                 , def
>                     { number = "555-7654"
>                     , type_ = Person'PhoneNumber'Type'work
>                     }
>                 ]
>             , employment = Person'employment'selfEmployed
>             }
>         ]
>     }

'putValue' is equivalent to @'hPutValue' 'stdout'@; 'hPutValue' may be used
to write to an arbitrary handle.

We can use 'getValue' (or alternately 'hGetValue') to read in a message:

> -- ...
>
> import Capnp (getValue, defaultLimit)
>
> -- ...
>
> main = do
>     value <- getValue defaultLimit
>     print (value :: AddressBook)

Note the type annotation; there are a number of interfaces in the
library which dispatch on return types, and depending on how they are
used you may have to give GHC a hint for type inference to succeed.
The type of 'getValue' is:

@'getValue' :: 'FromStruct' 'ConstMsg' a => 'Int' -> 'IO' a@

...and so it may be used to read in any struct type.

'defaultLimit' is a default value for the traversal limit, which acts to
prevent denial of service vulnerabilities; See the documentation in
"Capnp.TraversalLimit" for more information. 'getValue' uses this
argument both to catch values that would cause excessive resource usage,
and to simply limit the overall size of the incoming message. The
default is approximately 64 MiB.

If an error occurs, an exception will be thrown of type 'Error' from the
"Capnp.Errors" module.

-}

{- $highlevel-codegen-rules

The complete rules for how capnproto types map to Haskell are as follows:

* Integer types and booleans map to the obvious corresponding Haskell
  types.
* @Float32@ and @Float64@ map to 'Float' and 'Double', respectively.
* @Void@ maps to the unit type, @()@.
* Lists map to 'Vector's from the Haskell vector package. Note that
  right now we use boxed vectors for everything; at some point this will
  likely change for performance reasons. Using the functions from
  "Data.Vector.Generic" will probably decrease the amount of code you
  will need to modify when upgrading.
* @Text@ maps to (strict) 'T.Text' from the Haskell `text` package.
* @Data@ maps to (strict) 'BS.ByteString's
* Type constructor names are the fully qualified (within the schema file)
  capnproto name, using the single quote character as a namespace
  separator.
* Structs map to record types. The name of the data constructor is the
  same as the name of the type constructor.
* Field names map to record fields with the same names. Names that are
  Haskell keywords have an underscore appended to them, e.g. @type_@ in
  the above example. These names are not qualified; we use the
  @DuplicateRecordFields@ extension to disambiguate them.
* Union fields result in an auxiliary type definition named
  @\<containing type's name>'\<union field name>@. For an example, see the
  mapping of the `employment` field above.
* Unions and enums map to sum types, each of which has a special
  `unknown'` variant (note the trailing single quote). This variant will
  be returned when parsing a message which contains a union tag greater
  than what was defined in the schema. This is most likely to happen
  when dealing with data generated by software using a newer version
  of the same schema. The argument to the data constructor is the value
  of the tag.
* Union variants with arguments of type `Void` map to data constructors
  with no arguments.
* The type for an anonymous union has the same name as its containing
  struct with an extra single quote on the end. You can think of this as
  being like a field with the empty string as its name. The Haskell
  record accessor for this field is named `union'` (note the trailing
  single quote).
* As a special case, if a struct consists entirely of one anonymous
  union, the type for the struct itself is omitted, and the name of the
  type for the union does not have the trailing single quote (so its
  name is what the name of the struct type would be).
* Fields of type `AnyPointer` map to the types defined in
  @Capnp.Untyped.Pure@.
* No code is currently generated for interfaces; this will change once
  we implement RPC.
-}

{- $lowlevel

The low level API exposes a much more imperative interface than the
high-level API. Instead of algebraic data types, types are exposed as
opaque wrappers around references into a message, and accessors are
generated for the fields. This API is much closer in spirit to that of
the C++ reference implementation.

Because the low level interfaces do not parse and validate the message
up front, accesses to the message can result in errors. Furthermore, the
traversal limit needs to be tracked to avoid denial of service attacks.

Because of this, access to the message must occur inside of a monad
which is an instance of `MonadThrow` from the exceptions package, and
`MonadLimit`, which is defined in "Capnp.TraversalLimit". We define
a monad transformer `LimitT` for the latter.

-}

{- $lowlevel-example

We'll use the same schema as above for our example. Instead of standard
algebraic data types, the module `Capnp.Addressbook` primarily defines
newtype wrappers, which should be treated as opaque, and accessor
functions for the various fields.

@
newtype AddressBook msg = ...

get_Addressbook'people :: ReadCtx m msg => AddressBook msg -> m (List msg (Person msg))

newtype Person msg = ...

get_Person'id   :: ReadCtx m msg => Person msg -> m Word32
get_Person'name :: ReadCtx m msg => Person msg -> m (Text msg)
@

`ReadCtx` is a type synonym:

@
type ReadCtx m msg = (Message m msg, MonadThrow m, MonadLimit m)
@

Note the following:

* The generated data types are parametrized over a `msg` type. This is
  the type of the message in which the value is contained. This can be
  either 'ConstMsg' in the case of an immutable message, or @'MutMsg' s@
  for a mutable message (where `s` is the state token for the monad in
  which the message may be mutated).
* The `Text` and `List` types mentioned in the type signatures are types
  defined within the capnp library, and are similarly views into the
  underlying message.
* Access to the message happens in a monad which affords throwing
  exceptions, tracking the traversal limit, and of course reading the
  message.

The snippet below prints the names of each person in the address book:

> {-# LANGUAGE ScopedTypeVariables #-}
> import Prelude hiding (length)
>
> import Capnp.Gen.Addressbook
> import Capnp
>     (ConstMsg, defaultLimit, evalLimitT, getValue, index, length, textBytes)
>
> import           Control.Monad         (forM_)
> import           Control.Monad.Trans   (lift)
> import qualified Data.ByteString.Char8 as BS8
>
> main = do
>     addressbook :: AddressBook ConstMsg <- getValue defaultLimit
>     evalLimitT defaultLimit $ do
>         people <- get_AddressBook'people addressbook
>         forM_ [0..length people - 1] $ \i -> do
>             name <- index i people >>= get_Person'name >>= textBytes
>             lift $ BS8.putStrLn name

Note that we use the same `getValue` function as in the high-level
example above.
-}

{- $lowlevel-write

Writing messages using the low-level API has a similarly imperative feel.
The below constructs the same message as in our high-level example above:

> import Capnp.Gen.Addressbook
>
> import Capnp
>     ( MutMsg
>     , PureBuilder
>     , cerialize
>     , createPure
>     , defaultLimit
>     , index
>     , newMessage
>     , newRoot
>     , putMsg
>     )
>
> import qualified Data.Text as T
>
> main =
>     let Right msg = createPure defaultLimit buildMsg
>     in putMsg msg
>
> buildMsg :: PureBuilder s (MutMsg s)
> buildMsg = do
>     -- newMessage allocates a new, initially empty, mutable message:
>     msg <- newMessage
>
>     -- newRoot allocates a new struct as the root object of the message.
>     -- In this case the type of the struct can be inferred from our later
>     -- use of AddressBook's accessors:
>     addressbook <- newRoot msg
>
>     -- new_* accessors allocate a new value of the correct type for a
>     -- given field. These functions accordingly only exist for types
>     -- which are encoded as pointers (structs, lists, bytes...). In
>     -- the case of lists, these take an extra argument specifying a
>     -- the length of the list:
>     people <- new_AddressBook'people 2 addressbook
>
>     -- Index gets an object at a specified location in a list. Cap'N Proto
>     -- lists are flat arrays, and in the case of structs the structs are
>     -- unboxed, so there is no need to allocate each element:
>     alice <- index 0 people
>
>     -- set_* functions set the value of a field. For fields of non-pointer
>     -- types (integers, bools...), We can just pass the value we want to set_*,
>     -- rather than allocating via new_* first:
>     set_Person'id alice 123
>
>     -- 'cerialize' is used to marshal a value into a message. Below, we copy
>     -- the text for Alice's name and email address into the message, and then
>     -- use Person's set_* functions to attach the resulting objects to our
>     -- Person:
>     set_Person'name alice =<< cerialize msg (T.pack "Alice")
>     set_Person'email alice =<< cerialize msg (T.pack "alice@example.com")
>
>     phones <- new_Person'phones 1 alice
>     mobilePhone <- index 0 phones
>     set_Person'PhoneNumber'number mobilePhone =<< cerialize msg (T.pack "555-1212")
>     set_Person'PhoneNumber'type_ mobilePhone Person'PhoneNumber'Type'mobile
>
>     -- Setting union fields is slightly awkward; we have an auxiliary type
>     -- for the union field, which we must get_* first:
>     employment <- get_Person'employment alice
>
>     -- Then, we can use set_* to set both the tag of the union and the
>     -- value:
>     set_Person'employment'school employment =<< cerialize msg (T.pack "MIT")
>
>     bob <- index 1 people
>     set_Person'id bob 456
>     set_Person'name bob =<< cerialize msg (T.pack "Bob")
>     set_Person'email bob =<< cerialize msg (T.pack "bob@example.com")
>
>     phones <- new_Person'phones 2 bob
>     homePhone <- index 0 phones
>     set_Person'PhoneNumber'number homePhone =<< cerialize msg (T.pack "555-4567")
>     set_Person'PhoneNumber'type_ homePhone Person'PhoneNumber'Type'home
>     workPhone <- index 1 phones
>     set_Person'PhoneNumber'number workPhone =<< cerialize msg (T.pack "555-7654")
>     set_Person'PhoneNumber'type_ workPhone Person'PhoneNumber'Type'work
>     employment <- get_Person'employment bob
>     set_Person'employment'selfEmployed employment
>
>     pure msg
-}
