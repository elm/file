# Files

Select files. Download files. Work with file content.

Maybe you generate an SVG floorplan or a PDF legal document? You can use `File.Download` to save those files to disk. Maybe you want people to upload a GIF cat picture or a JPG waterfall? You can use `File.Select` to get those files into the browser.

**This package does not allow _arbitrary_ access to the file system though.** Browsers restrict access to the file system for security. Otherwise, any website on the internet could go try to read private keys out of `~/.ssh` or whatever else they want!


## Example

This program lets you load images into your application. Once you select an image, it will show the image and some metadata:

```elm
import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Task
import Time



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
  { file : Maybe File
  , preview : Maybe String
  }


init : () -> ( Model, Cmd Msg )
init () =
  ( Model Nothing Nothing, Cmd.none )



-- UPDATE


type Msg
  = ImageRequested
  | ImageLoaded File
  | GotPreview String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ImageRequested ->
      ( model
      , Select.file ["image/*"] ImageLoaded
      )

    ImageLoaded file ->
      ( { model | file = Just file }
      , Task.perform GotPreview (File.toUrl file)
      )

    GotPreview bytes ->
      ( { model | preview = Just bytes }
      , Cmd.none
      )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ button [ onClick ImageRequested ] [ text "LOAD" ]
    , viewMetadata model.file
    , viewPreview model.preview
    ]


viewMetadata : Maybe File -> Html msg
viewMetadata maybeUpload =
  case maybeUpload of
    Nothing ->
      text ""

    Just file ->
      pre []
        [ text <| String.join "\n" <|
            [ "Name: " ++ File.name file
            , "MIME: " ++ File.mime file
            , "Size: " ++ String.fromInt (File.size file) ++ " bytes"
            , "Last Modified: " ++ String.fromInt (Time.posixToMillis (File.lastModified file))
            ]
        ]


viewPreview : Maybe String -> Html msg
viewPreview preview =
  case preview of
    Nothing ->
      text ""

    Just url ->
      img [ src url ] []
```

If you want to drag-and-drop files into the browser, you can use `File.decoder` to handle drag events however makes sense for your particular scenario.
