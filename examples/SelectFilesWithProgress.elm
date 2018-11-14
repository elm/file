import Browser
import File exposing (File)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D



-- MAIN


main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL


type Model
  = Waiting
  | Uploading Float
  | Done
  | Fail


init : () -> (Model, Cmd Msg)
init _ =
  ( Waiting
  , Cmd.none
  )



-- UPDATE


type Msg
  = GotFiles (List File)
  | GotProgress Http.Progress
  | Uploaded (Result Http.Error ())


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotFiles files ->
      ( Uploading 0
      , Http.request
          { method = "POST"
          , url = "/"
          , headers = []
          , body = Http.multipartBody (List.map (Http.filePart "files[]") files)
          , expect = Http.expectWhatever Uploaded
          , timeout = Nothing
          , tracker = Just "upload"
          }
      )

    GotProgress progress ->
      case progress of
        Http.Sending p ->
          (Uploading (Http.fractionSent p), Cmd.none)

        Http.Receiving _ ->
          (model, Cmd.none)

    Uploaded result ->
      case result of
        Ok _ ->
          (Done, Cmd.none)

        Err _ ->
          (Fail, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Http.track "upload" GotProgress



-- VIEW


view : Model -> Html Msg
view model =
  case model of
    Waiting ->
      input
        [ type_ "file"
        , multiple True
        , on "change" (D.map GotFiles filesDecoder)
        ]
        []

    Uploading fraction ->
      h1 [] [ text (String.fromInt (round (100 * fraction)) ++ "%") ]

    Done ->
      h1 [] [ text "DONE" ]

    Fail ->
      h1 [] [ text "FAIL" ]


filesDecoder : D.Decoder (List File)
filesDecoder =
  D.at ["target","files"] (D.list File.decoder)
