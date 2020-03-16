import Head from "next/head";
import Elm from "react-elm-components";

import Timer from "../app/Timer.elm";

const App = () => (
    <div className="container">
        <Head>
            <title>Cronjob as a Service Application</title>
            <link rel="icon" href="/favicon.ico" />
        </Head>

        <main>
            <div>
                <Elm src={Timer.Elm.Main} />
            </div>
		</main>
	</div>
)

export default App;
