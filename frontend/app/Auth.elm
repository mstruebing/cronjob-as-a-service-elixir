module Auth exposing (..)

import Api.Mutation as Mutation
import Api.Object
import Api.Object.Session as Session
import Api.Object.User
import Api.ScalarCodecs
import Graphql.Http exposing (mutationRequest, send)
import Graphql.Operation exposing (RootMutation)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (Html)
import Html.Attributes exposing (placeholder, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Shared exposing (graphqlServerUrl)


type alias Model =
    { token : String
    , password : String
    , email : String
    , registerPassword : String
    , registerEmail : String
    }


type Msg
    = Login
    | Logout
    | LoggedOut (Result (Graphql.Http.Error Bool) Bool)
    | LoggedIn (Result (Graphql.Http.Error (Maybe String)) (Maybe String))
    | UpdateEmail String
    | UpdatePassword String
    | Register
    | UpdateRegisterPassword String
    | UpdateRegisterEmail String
    | Registered (Result (Graphql.Http.Error User) User)


emptyModel : Model
emptyModel =
    { token = ""
    , password = ""
    , email = ""
    , registerPassword = ""
    , registerEmail = ""
    }


init : ( Model, Cmd Msg )
init =
    ( emptyModel
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Logout ->
            ( model, logout model )

        LoggedOut bool ->
            ( emptyModel, Cmd.none )

        Login ->
            ( model, login model )

        LoggedIn (Ok (Just token)) ->
            ( { model | token = token }, Cmd.none )

        LoggedIn (Ok Nothing) ->
            ( model, Cmd.none )

        LoggedIn (Err _) ->
            ( model, Cmd.none )

        UpdateEmail email ->
            ( { model | email = email }, Cmd.none )

        UpdatePassword password ->
            ( { model | password = password }, Cmd.none )

        Register ->
            ( model, Cmd.batch [ register model ] )

        Registered (Ok user) ->
            ( model, Cmd.none )

        Registered (Err _) ->
            ( model, Cmd.none )

        UpdateRegisterEmail email ->
            ( { model | registerEmail = email }, Cmd.none )

        UpdateRegisterPassword password ->
            ( { model | registerPassword = password }, Cmd.none )


login : Model -> Cmd Msg
login model =
    loginMutation model
        |> mutationRequest graphqlServerUrl
        |> send LoggedIn


loginMutation : Model -> SelectionSet (Maybe String) RootMutation
loginMutation { email, password } =
    Mutation.login { email = email, password = password } loginSelection


loginSelection : SelectionSet String Api.Object.Session
loginSelection =
    SelectionSet.map
        (\maybeToken ->
            case maybeToken of
                Just token ->
                    token

                Nothing ->
                    ""
        )
        Session.token


register : Model -> Cmd Msg
register model =
    registerMutation model
        |> mutationRequest graphqlServerUrl
        |> send Registered


type alias User =
    { id : Api.ScalarCodecs.Id
    , email : String
    }


registerMutation : Model -> SelectionSet User RootMutation
registerMutation { registerEmail, registerPassword } =
    Mutation.createUser { email = registerEmail, password = registerPassword } registerSelection


registerSelection : SelectionSet User Api.Object.User
registerSelection =
    SelectionSet.map2 User
        Api.Object.User.id
        Api.Object.User.email


logoutMutation : Model -> SelectionSet Bool RootMutation
logoutMutation _ =
    Mutation.logout


logout : Model -> Cmd Msg
logout model =
    logoutMutation model
        |> mutationRequest graphqlServerUrl
        |> send LoggedOut


view : Model -> Html Msg
view model =
    if model.token == "" then
        Html.div []
            [ viewLogin
            , viewRegister
            ]

    else
        viewLoggedIn model


viewLogin : Html Msg
viewLogin =
    Html.form [ onSubmit Login ]
        [ Html.input [ onInput UpdateEmail, placeholder "email" ] []
        , Html.input [ onInput UpdatePassword, type_ "password", placeholder "password" ] []
        , Html.button [] [ Html.text "Login" ]
        ]


viewLoggedIn : Model -> Html Msg
viewLoggedIn model =
    Html.div []
        [ Html.p [] [ Html.text <| "logged in as: " ++ model.email ]
        , Html.button [ onClick Logout ] [ Html.text "Logout" ]
        ]


viewRegister : Html Msg
viewRegister =
    Html.form [ onSubmit Register ]
        [ Html.input [ onInput UpdateRegisterEmail, placeholder "email" ] []
        , Html.input [ onInput UpdateRegisterPassword, type_ "password", placeholder "password" ] []
        , Html.button [] [ Html.text "Register" ]
        ]
