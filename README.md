# Files

Select files. Download files. Work with file content.

Maybe you generate an SVG floorplan or a PDF legal document? You can use `File.Download` to save those files to disk. Maybe you want people to upload a GIF cat picture or a JPG waterfall? You can use `File.Select` to get those files into the browser.

**This package does not allow _arbitrary_ access to the file system though.** Browsers restrict access to the file system for security. Otherwise, any website on the internet could go try to read private keys out of `~/.ssh` or whatever else they want!


## Example

Maybe you want users to select a ZIP file for you:

```elm
import File.Select as Select

type Msg
  = ZipRequested
  | ZipLoaded File

selectZip : Cmd Msg
selectZip =
  Select.file ["application/zip"] ZipLoaded
```

Or maybe you want people to download the floorplan they just designed as an SVG file:

```elm
import File.Download as Download

download : String -> Cmd msg
download svgContent =
  Download.string "floorplan.svg" "image/svg+xml" svgContent
```
