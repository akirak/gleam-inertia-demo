import React from "react";
import Layout from "../components/Layout";
import { Head } from "@inertiajs/react";

export default function About({ systemVersion }) {
  return (
    <Layout>
      <Head title="About" />
      <h1>About</h1>

      <ul>
        <li>System Version: {systemVersion}</li>
      </ul>
    </Layout>
  );
}
