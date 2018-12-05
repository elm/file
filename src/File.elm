module File exposing
  ( File
  , decoder
  , toString
  , toBytes
  , toUrl
  , name
  , mime
  , size
  , lastModified
  )


{-|

# Files
@docs File, decoder

# Extract Content
@docs toString, toBytes, toUrl

# Read Metadata
@docs name, mime, size, lastModified

-}

import Bytes exposing (Bytes)
import Elm.Kernel.File
import Json.Decode as Decode
import Task exposing (Task)
import Time



-- FILE


{-| Represents an uploaded file. From there you can read the content, check
the metadata, send it over [`elm/http`](/packages/elm/http/latest), etc.
-}
type File = File


{-| Decode `File` values. For example, if you want to create a drag-and-drop
file uploader, you can listen for `drop` events with a decoder like this:

    import File
    import Json.Decode exposing (Decoder, field, list)

    files : Decode.Decoder (List File)
    files =
      field "dataTransfer" (field "files" (list File.decoder))

Once you have the files, you can use functions like [`File.toString`](#toString)
to process the content. Or you can send the file along to someone else with the
[`elm/http`](/packages/elm/http/latest) package.
-}
decoder : Decode.Decoder File
decoder =
  Elm.Kernel.File.decoder



-- CONTENT


{-| Extract the content of a `File` as a `String`. So if you have a `notes.md`
file you could read the content like this:

    import File exposing (File)
    import Task

    type Msg
      = MarkdownLoaded String

    read : File -> Cmd Msg
    read file =
      Task.perform MarkdownLoaded (File.toString file)

Reading the content is asynchronous because browsers want to avoid allocating
the file content into memory if possible. (E.g. if you are just sending files
along to a server with [`elm/http`](/packages/elm/http/latest) there is no
point having their content in memory!)
-}
toString : File -> Task x String
toString =
  Elm.Kernel.File.toString


{-| Extract the content of a `File` as `Bytes`. So if you have an `archive.zip`
file you could read the content like this:

    import Bytes exposing (Bytes)
    import File exposing (File)
    import Task

    type Msg
      = ZipLoaded Bytes

    read : File -> Cmd Msg
    read file =
      Task.perform ZipLoaded (File.toBytes file)

From here you can use the [`elm/bytes`](/packages/elm/bytes/latest) package to
work with the bytes and turn them into whatever you want.
-}
toBytes : File -> Task x Bytes
toBytes =
  Elm.Kernel.File.toBytes


{-| The `File.toUrl` function will convert files into URLs like this:

- `data:*/*;base64,V2hvIGF0ZSBhbGwgdGhlIHBpZT8=`
- `data:*/*;base64,SXQgd2FzIG1lLCBXaWxleQ==`
- `data:*/*;base64,SGUgYXRlIGFsbCB0aGUgcGllcywgYm95IQ==`

This is using a [Base64](https://en.wikipedia.org/wiki/Base64) encoding to
turn arbitrary binary data into ASCII characters that safely fit in strings.

This is primarily useful when you want to show images that were just uploaded
because **an `<img>` tag expects its `src` attribute to be a URL.** So if you
have a website for selling furniture, using `File.toUrl` could make it easier
to create a screen to preview and reorder images. This way people can make
sure their old table looks great!
-}
toUrl : File -> Task x String
toUrl =
  Elm.Kernel.File.toUrl



-- METADATA


{-| Get the name of a file.

    name file1 == "README.md"
    name file2 == "math.gif"
    name file3 == "archive.zip"
-}
name : File -> String
name =
  Elm.Kernel.File.name

{-| Get the MIME type of a file.

    mime file1 == "text/markdown"
    mime file2 == "image/gif"
    mime file3 == "application/zip"
-}
mime : File -> String
mime =
  Elm.Kernel.File.mime


{-| Get the size of the file in bytes.

    size file1 == 395
    size file2 == 65813
    size file3 == 81481
-}
size : File -> Int
size =
  Elm.Kernel.File.size


{-| Get the time the file was last modified.

    lastModified file1 -- 1536872423
    lastModified file2 -- 860581394
    lastModified file3 -- 1340375405

Learn more about how time is represented by reading through the
[`elm/time`](/packages/elm/time/latest) package!
-}
lastModified : File -> Time.Posix
lastModified =
  Elm.Kernel.File.lastModified
