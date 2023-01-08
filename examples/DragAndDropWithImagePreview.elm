module  DragAndDropWithImagePreview exposing (..)

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as D
import Task



-- MAIN


main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL


type alias Model =
  { hover : Bool
  , previews : List String
  }


init : () -> (Model, Cmd Msg)
init _ =
  (Model False [], Cmd.none)



-- UPDATE


type Msg
  = Pick
  | DragEnter
  | DragLeave
  | GotFiles File (List File)
  | GotPreviews (List String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Pick ->
      ( model
      , Select.files ["image/*"] GotFiles
      )

    DragEnter ->
      ( { model | hover = True }
      , Cmd.none
      )

    DragLeave ->
      ( { model | hover = False }
      , Cmd.none
      )

    GotFiles file files ->
      ( { model | hover = False }
      , Task.perform GotPreviews <| Task.sequence <|
          List.map File.toUrl (file :: files)
      )

    GotPreviews urls ->
      ( { model | previews = urls }
      , Cmd.none
      )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  div
    [ style "border" (if model.hover then "6px dashed purple" else "6px dashed #ccc")
    , style "border-radius" "20px"
    , style "width" "480px"
    , style "margin" "100px auto"
    , style "padding" "40px"
    , style "display" "flex"
    , style "flex-direction" "column"
    , style "justify-content" "center"
    , style "align-items" "center"
    , hijackOn "dragenter" (D.succeed DragEnter)
    , hijackOn "dragover" (D.succeed DragEnter)
    , hijackOn "dragleave" (D.succeed DragLeave)
    , hijackOn "drop" dropDecoder
    ]
    [ button [ onClick Pick ] [ text "Upload Images" ]
    , div
        [ style "display" "flex"
        , style "align-items" "center"
        , style "height" "60px"
        , style "padding" "20px"
        ]
        (List.map viewPreview model.previews)
    ]


viewPreview : String -> Html msg
viewPreview url =
  div
    [ style "width" "60px"
    , style "height" "60px"
    , style "background-image" ("url('" ++ url ++ "')")
    , style "background-position" "center"
    , style "background-repeat" "no-repeat"
    , style "background-size" "contain"
    ]
    []


dropDecoder : D.Decoder Msg
dropDecoder =
  D.at ["dataTransfer","files"] (D.oneOrMore GotFiles File.decoder)


hijackOn : String -> D.Decoder msg -> Attribute msg
hijackOn event decoder =
  preventDefaultOn event (D.map hijack decoder)


hijack : msg -> (msg, Bool)
hijack msg =
  (msg, True)
