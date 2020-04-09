import Head from "next/head";
import Link from "next/link";

const Home = () => (
    <div className="container">
        <Head>
            <title>CRON-SERVICE.COM</title>
            <link rel="icon" href="/favicon.ico" />
        </Head>

        <main>
            This will be the landing page
            <Link href="/app">
                <a>Go to app</a>
            </Link>
        </main>

        <style jsx>{`
            .container {
                min-height: 100vh;
                padding: 0 0.5rem;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
            }

            main {
                padding: 5rem 0;
                flex: 1;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
            }

            footer {
                width: 100%;
                height: 100px;
                border-top: 1px solid #eaeaea;
                display: flex;
                justify-content: center;
                align-items: center;
            }

            a {
                color: inherit;
                text-decoration: none;
            }
        `}</style>

        <style jsx global>{`
            html,
            body {
                padding: 0;
                margin: 0;
                font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto,
                    Oxygen, Ubuntu, Cantarell, Fira Sans, Droid Sans,
                    Helvetica Neue, sans-serif;
            }

            * {
                box-sizing: border-box;
            }
        `}</style>
    </div>
);

export default Home;
