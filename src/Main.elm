module Main (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Effects exposing (Effects)


-- official 'Elm Architecture' package
-- https://github.com/evancz/start-app

import StartApp
import Components.SelectionList exposing (..)
import Components.CreateEventForm as CEF exposing (..)
import Components.GuestList as GL exposing (..)
import Components.CreateAccountForm as CAF exposing (..)
import Components.Summary as S exposing (..)
import Components.Thanks as T exposing (..)


-- APP KICK OFF!


app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }


main =
  app.html



-- HOT-SWAPPING


port swap : Signal.Signal Bool



-- MODEL


type Page
  = CreateAccountForm
  | CreateEventForm
  | GuestList
  | Summary
  | Thanks


type alias Model =
  { createEventForm : CEF.Model
  , guestList : GL.Model
  , createAccountForm : CAF.Model
  , pages : SelectionList Page
  }



-- INIT


pureInit =
  { createEventForm = CEF.init
  , guestList = GL.init
  , createAccountForm = CAF.init
  , pages = newSelectionList CreateAccountForm [ CreateEventForm, GuestList, Summary, Thanks ]
  }


init =
  ( pureInit, Effects.none )



-- UPDATE


type Action
  = UpdateCreateEventForm CEF.Action
  | UpdateGuestList GL.Action
  | UpdateCreateAccountForm CAF.Action
  | NextPage
  | PrevPage


update action model =
  case action of
    UpdateCreateEventForm a ->
      ( { model | createEventForm = CEF.update a model.createEventForm }, Effects.none )

    UpdateGuestList a ->
      ( { model | guestList = GL.update a model.guestList }, Effects.none )

    UpdateCreateAccountForm a ->
      ( { model | createAccountForm = CAF.update a model.createAccountForm }, Effects.none )

    NextPage ->
      if curPageIsValid model.pages.current model then
        ( { model | pages = forward model.pages }, Effects.none )
      else
        ( model, Effects.none )

    PrevPage ->
      ( { model | pages = back model.pages }, Effects.none )


curPageIsValid : Page -> Model -> Bool
curPageIsValid page model =
  case page of
    CreateAccountForm ->
      CAF.isComplete model.createAccountForm

    CreateEventForm ->
      CEF.isComplete model.createEventForm

    GuestList ->
      True

    Summary ->
      True

    Thanks ->
      True



-- VIEW


view dispatcher model =
  let
    forwardWith =
      Signal.forwardTo dispatcher

    header =
      fnOfPage
        (text "Hi! Tell me a little bit about yourself!")
        (text "Hi! Tell me a little bit about your event.")
        (text "Who's invited?")
        (text "Please review your information.")
        (text "")

    curPage =
      fnOfPage
        (CAF.view (forwardWith UpdateCreateAccountForm) model.createAccountForm)
        (CEF.view (forwardWith UpdateCreateEventForm) model.createEventForm)
        (GL.view (forwardWith UpdateGuestList) model.guestList)
        (S.view (forwardWith UpdateCreateEventForm) model.createEventForm (forwardWith UpdateGuestList) model.guestList)
        T.view

    visible =
      [ ( "visibility", "visible" ) ]

    hidden =
      [ ( "visibility", "hidden" ) ]

    prevBtnStyle =
      fnOfPage hidden visible visible visible hidden

    nextBtnStyle =
      fnOfPage visible visible visible visible hidden

    nextBtnText =
      fnOfPage "Next" "Next" "Next" "Finish" ""
  in
    -- Html.form [ autocomplete True ]
    Html.div
      [ class "container" ]
      [ -- Header
        div
          [ class "row" ]
          [ h3 [] [ header model.pages.current ] ]
        -- Main content
      , curPage model.pages.current
        -- Buttons
      , div
          [ class "row" ]
          [ button
              [ class "waves-effect waves-light btn col s2"
              , style (prevBtnStyle model.pages.current)
              , onClick dispatcher PrevPage
              ]
              [ text "Prev" ]
          , button
              [ class "waves-effect waves-light btn col s2 offset-s8"
              , style (nextBtnStyle model.pages.current)
              , onClick dispatcher NextPage
              ]
              [ text (nextBtnText model.pages.current) ]
          ]
      ]


fnOfPage : a -> a -> a -> a -> a -> Page -> a
fnOfPage onCreateAccountForm onCreateEventForm onGuestList onSummary onThanks page =
  case page of
    CreateAccountForm ->
      onCreateAccountForm

    CreateEventForm ->
      onCreateEventForm

    GuestList ->
      onGuestList

    Summary ->
      onSummary

    Thanks ->
      onThanks
