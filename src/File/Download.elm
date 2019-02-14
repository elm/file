module File.Download exposing
  ( string
  , bytes
  , url
  )


{-| Commands for downloading files.

**SECURITY NOTE:** Browsers require that all downloads are initiated by a user
event. So rather than allowing malicious sites to put files on your computer
however they please, the user at least have to click a button first. As a
result, the following commands only work when they are triggered by some user
event.

# Download
@docs string, bytes, url

-}


import Bytes exposing (Bytes)
import Elm.Kernel.File
import Task



-- DOWNLOAD


{-| Download a file from a URL on the same origin. So if you have a website
at `https://example.com`, you could download a math GIF like this:

    import File.Download as Download

    downloadMathGif : Cmd msg
    downloadMathGif =
      Download.url "https://example.com/math.gif"

The downloaded file will use whatever name the server suggests. So if you want
a different name, have your server add a [`Content-Disposition`][cd] header like
`Content-Disposition: attachment; filename="triangle.gif"` when it serves the
file.

**Warning:** The implementation uses `<a href="..." download></a>` which has
two important consequences:

1. **Cross-origin downloads are weird.** If you want a file from a different
domain (like `https://files.example.com` or `https://www.wikipedia.org`) this
function adds a `target="_blank"`, opening the file in a new tab. Otherwise
the link would just take over the current page, replacing your website with a
GIF or whatever. To make cross-origin downloads work differently, you can (1)
make the request same-origin by sending it to your server and then having your
server fetch the file or (2) fetch the file with `elm/http` and then go through
`File.Download.bytes`.
2. **Same-origin downloads are weird in IE10 and IE11.** These browsers do not
support the `download` attribute, so you should always get the `target="_blank"`
behavior where the URL opens in a new tab. Again, you can fetch the file with
`elm/http` and then use `File.Download.bytes` to get around this.

Things are quite tricky here between the intentional security constraints and
particularities of browser implementations, so remember that you can always
send the URL out a `port` and do something even more custom in JavaScript!

[cd]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Disposition
-}
url : String -> Cmd msg
url href =
  Task.perform never (Elm.Kernel.File.downloadUrl href)


{-| Download a `String` as a file. Maybe you markdown editor in the browser,
and you want to provide a button to download markdown files:

    import File.Download as Download

    save : String -> Cmd msg
    save markdown =
      Download.string "draft.md" "text/markdown" markdown

So the arguments are file name, MIME type, and then the file content. In this
case is is markdown, but it could be any string information.
-}
string : String -> String -> String -> Cmd msg
string name mime content =
  Task.perform never (Elm.Kernel.File.download name mime content)


{-| Download some `Bytes` as a file. Maybe you are creating custom images,
and you want a button to download them as PNG files. After using
[`elm/bytes`][bytes] to generate the file content, you can download it like
this:

    import Bytes exposing (Bytes)
    import File.Download as Download

    savePng : Bytes -> Cmd msg
    savePng bytes =
      Download.bytes "frog.png" "image/png" bytes

So the arguments are file name, MIME type, and then the file content. With the
ability to build any byte sequence you want with [`elm/bytes`][bytes], you can
create `.zip` files, `.jpg` files, or whatever else you might need!

[bytes]: /packages/elm/bytes/latest
-}
bytes : String -> String -> Bytes -> Cmd msg
bytes name mime content =
  Task.perform never <| Elm.Kernel.File.download name mime <|
    Elm.Kernel.File.makeBytesSafeForInternetExplorer content
