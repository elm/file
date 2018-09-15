# Upload and Download Files

Do you want people to upload photos of mountains and rivers? Do you have an online editor for text, images, SVG, PDF, or something? And do you want people to be able to download their files? This will work well for cases like this.

**Note:** This package is not for arbitrary access to the file system. Browsers restrict access to the file system for the sake of security. Otherwise, any website on the internet could go try to read private keys out of `~/.ssh` or whatever else they want!


# Example

This program lets you upload images. Once you upload an image, it will show some metadata and the image itself:

```
import Browser
import File exposing (File)
import File.Upload as Upload
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
  { upload : Maybe File
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
      , Upload.file ["image/*"] ImageLoaded
      )

    ImageLoaded file ->
      ( { model | upload = Just file }
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
    [ button [ onClick ImageRequested ] [ text "UPLOAD" ]
    , viewMetadata model.upload
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

If you want a drag-and-drop way to upload files, you can use `File.decoder` to handle drag events however makes sense for your particular scenario.
