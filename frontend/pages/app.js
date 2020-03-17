import Head from "next/head";

import wrap from "@elm-react/component";

import ElmApp from "../app/Main.elm";

const WrappedApp = wrap(ElmApp);

const App = () => (
    <div className="container">
        <Head>
            <title>Cronjob as a Service Application</title>
            <link rel="icon" href="/favicon.ico" />
        </Head>

        <main>
            <div>
                <WrappedApp />
            </div>
        </main>
    </div>
);

export default App;
