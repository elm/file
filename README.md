# Files

Select files. Download files. Work with file content.

Maybe you generate an SVG floorplan or a PDF legal document? You can use [`File.Download`](https://package.elm-lang.org/packages/elm/file/latest/File-Download) to save those files to disk. Maybe you want people to upload a CSV of microbe data or a JPG of their face? You can use [`File.Select`](https://package.elm-lang.org/packages/elm/file/latest/File-Select) to get those files into the browser.

**This package does not allow _arbitrary_ access to the file system though.** Browsers restrict access to the file system for security. Otherwise, any website on the internet could go try to read private keys out of `~/.ssh` or whatever else they want!


## Download Example

Maybe you want people to download the floorplan they just designed as an SVG file? You could use [`File.Download.string`](https://package.elm-lang.org/packages/elm/file/latest/File-Download#string) like this:

```elm
import File.Download as Download

download : String -> Cmd msg
download svgContent =
  Download.string "floorplan.svg" "image/svg+xml" svgContent
```


## Upload Example

Maybe you want to help scientists explore and visualize data? Maybe they need to upload [CSV files](https://en.wikipedia.org/wiki/Comma-separated_values) like this:

```
Name,Age,Weight,Height
Tom,22,63,1.8
Sue,55,50,1.6
Bob,35,75,1.85
```

You could use [`File.Select.file`](https://package.elm-lang.org/packages/elm/file/latest/File-Select#file) and [`File.toString`](https://package.elm-lang.org/packages/elm/file/latest/File#toString) to create a program like this:

```elm
import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (Html, button, p, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Task



-- MAIN


main : Program () Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL


type alias Model =
  { csv : Maybe String
  }


init : () -> (Model, Cmd Msg)
init _ =
  ( Model Nothing, Cmd.none )



-- UPDATE


type Msg
  = CsvRequested
  | CsvSelected File
  | CsvLoaded String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    CsvRequested ->
      ( model
      , Select.file ["text/csv"] CsvSelected
      )

    CsvSelected file ->
      ( model
      , Task.perform CsvLoaded (File.toString file)
      )

    CsvLoaded content ->
      ( { model | csv = Just content }
      , Cmd.none
      )



-- VIEW


view : Model -> Html Msg
view model =
  case model.csv of
    Nothing ->
      button [ onClick CsvRequested ] [ text "Load CSV" ]

    Just content ->
      p [ style "white-space" "pre" ] [ text content ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none

```

From there you could parse the CSV file, start showing scatter plots, etc.