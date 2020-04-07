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
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Shared exposing (errorToString, graphqlServerUrl)


type alias Model =
    { token : String
    , register : UserInput
    , login : UserInput
    }


type alias UserInput =
    { email : String, password : String, error : String }


type Msg
    = Login
    | Logout
    | LoggedOut (Result (Graphql.Http.Error Bool) Bool)
    | LoggedIn (Result (Graphql.Http.Error (Maybe String)) (Maybe String))
    | UpdateLoginEmail String
    | UpdateLoginPassword String
    | Register
    | UpdateRegisterPassword String
    | UpdateRegisterEmail String
    | Registered (Result (Graphql.Http.Error User) User)


emptyModel : Model
emptyModel =
    { token = ""
    , login = emptyUserInput
    , register = emptyUserInput
    }


emptyUserInput : UserInput
emptyUserInput =
    { email = ""
    , password = ""
    , error = ""
    }


init : ( Model, Cmd Msg )
init =
    ( emptyModel
    , Cmd.none
    )


type UserInputType
    = Email
    | Password
    | Error


updateUserInput : UserInputType -> UserInput -> String -> UserInput
updateUserInput userInputType userInput value =
    case userInputType of
        Email ->
            { userInput | email = value }

        Password ->
            { userInput | password = value }

        Error ->
            { userInput | error = value }


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

        LoggedIn (Err err) ->
            ( { model | login = updateUserInput Error model.login <| errorToString err }, Cmd.none )

        UpdateLoginEmail email ->
            ( { model | login = updateUserInput Email model.login email }, Cmd.none )

        UpdateLoginPassword password ->
            ( { model | login = updateUserInput Password model.login password }, Cmd.none )

        Register ->
            ( model, Cmd.batch [ register model ] )

        Registered (Ok user) ->
            let
                registerModel =
                    model.register

                updatedRegisterModel =
                    { registerModel | email = "", password = "", error = "successfull registered" }
            in
            ( { model | register = updatedRegisterModel }, Cmd.none )

        Registered (Err err) ->
            ( { model | register = updateUserInput Error model.register <| errorToString err }, Cmd.none )

        UpdateRegisterEmail email ->
            ( { model | register = updateUserInput Email model.register email }, Cmd.none )

        UpdateRegisterPassword password ->
            ( { model | register = updateUserInput Password model.register password }, Cmd.none )


login : Model -> Cmd Msg
login model =
    loginMutation model.login
        |> mutationRequest graphqlServerUrl
        |> send LoggedIn


loginMutation : UserInput -> SelectionSet (Maybe String) RootMutation
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
    registerMutation model.register
        |> mutationRequest graphqlServerUrl
        |> send Registered


type alias User =
    { id : Api.ScalarCodecs.Id
    , email : String
    }


registerMutation : UserInput -> SelectionSet User RootMutation
registerMutation { email, password } =
    Mutation.createUser { email = email, password = password } registerSelection


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
        Html.div [ class "auth" ]
            [ viewRegister model.register
            , viewLogin model.login
            ]

    else
        viewLoggedIn model


viewLogin : UserInput -> Html Msg
viewLogin { error } =
    Html.div [ class "login" ]
        [ Html.h1 [] [ Html.text "Login" ]
        , viewErrors error
        , Html.form [ onSubmit Login ]
            [ Html.input [ onInput UpdateLoginEmail, placeholder "email" ] []
            , Html.input [ onInput UpdateLoginPassword, type_ "password", placeholder "password" ] []
            , Html.button [] [ Html.text "Login" ]
            ]
        ]


viewRegister : UserInput -> Html Msg
viewRegister { error, email, password } =
    Html.div [ class "register" ]
        [ Html.h1 [] [ Html.text "Register" ]
        , viewErrors error
        , Html.form [ onSubmit Register ]
            [ Html.input [ onInput UpdateRegisterEmail, placeholder "email", value email ] []
            , Html.input [ onInput UpdateRegisterPassword, type_ "password", placeholder "password", value password ] []
            , Html.button [] [ Html.text "Register" ]
            ]
        ]


viewLoggedIn : Model -> Html Msg
viewLoggedIn model =
    Html.div []
        [ Html.p [] [ Html.text <| "logged in as: " ++ model.login.email ]
        , Html.button [ onClick Logout ] [ Html.text "Logout" ]
        ]


viewErrors : String -> Html Msg
viewErrors error =
    if String.length error > 0 then
        String.split
            "\n"
            error
            |> List.map (\err -> Html.li [] [ Html.text err ])
            |> Html.ul [ class "error" ]

    else
        Html.text ""
