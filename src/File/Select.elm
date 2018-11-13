module File.Select exposing ( file, files )


{-| Ask the user to select some files.

**SECURITY NOTE:** Browsers will only open a file selector in reaction to a
user event. So rather than allowing malicious sites to ask for files whenever
they please, the user at least have to click a button first. As a result, the
following commands only work when they are triggered by some user event.

# Select Files
@docs file, files

# Limitations

The API here uses commands, but it seems like it could also provide tasks.
The trouble is that a `Task` is guaranteed to succeed or fail. There should
not be any cases where it just does neither. File selection makes this tricky
because there are two limitations in JavaScript as of this writing:

1. File selection must be a direct response to a user event. This is intended
to help with security. It is not clear how to reliably detect when these
commands were issued at invalid times, especially across browsers.
2. The user can always click `Cancel` on the file dialog. It is quite
difficult to reliably detect if someone has clicked this button across
browsers, especially when it is hard to know if the dialog is even open in the
first place.

I think it would be worth figuring out how to know these two things reliably
before exposing a `Task` API for things.

-}


import Bytes exposing (Bytes)
import Elm.Kernel.File
import File exposing (File)
import Json.Decode as Decode
import Task exposing (Task)
import Time



-- ONE FILE


{-| Ask the user to select **one** file. To ask for a single `.zip` file you
could say:

    import File.Select as Select

    type Msg
      = ZipRequested
      | ZipLoaded File

    requestZip : Cmd Msg
    requestZip =
      Select.file ["application/zip"] ZipLoaded

You provide (1) a list of acceptable MIME types and (2) a function to turn the
resulting file into a message for your `update` function. In this case, we only
want files with MIME type `application/zip`.

**Note:** This only works when the command is the direct result of a user
event, like clicking something.

**Note:** This command may not resolve, partly because it is unclear how to
reliably detect `Cancel` clicks across browsers. More about that in the
section on [limitations](#limitations) below.
-}
file : List String -> (File -> msg) -> Cmd msg
file mimes toMsg =
  Task.perform toMsg (Elm.Kernel.File.uploadOne mimes)



-- ONE OR MORE


{-| Ask the user to select **one or more** files. To ask for many image files,
you could say:

    import File.Select as Select

    type Msg
      = ImagesRequested
      | ImagesLoaded File (List File)

    requestImages : Cmd Msg
    requestImages =
      Select.files ["image/png","image/jpg"] ImagesLoaded

In this case, we only want PNG and JPG files.

Notice that the function that turns the resulting files into a message takes
two arguments: the first file selected and then a list of the other selected
files. This guarantees that one file (or more) is available. This way you do
not have to handle “no files loaded” in your code. That can never happen!

**Note:** This only works when the command is the direct result of a user
event, like clicking something.

**Note:** This command may not resolve, partly because it is unclear how to
reliably detect `Cancel` clicks across browsers. More about that in the
section on [limitations](#limitations) below.
-}
files : List String -> (File -> List File -> msg) -> Cmd msg
files mimes toMsg =
  Task.perform
    (\(f,fs) -> toMsg f fs)
    (Elm.Kernel.File.uploadOneOrMore mimes)
