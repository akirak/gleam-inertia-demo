import { Link } from "@inertiajs/react";
import React from "react";
import { Head } from "@inertiajs/react";
import Layout from "../components/Layout";

export default function Home() {
  return (
    <Layout>
      <Head title="Demo Home" />

      <h1>Demo</h1>

      <ul>
        <li>
          <Link href="/about">About</Link>
        </li>
      </ul>
    </Layout>
  );
}
