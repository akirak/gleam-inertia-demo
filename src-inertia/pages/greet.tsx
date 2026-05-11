import React from "react";
import Layout from "../components/Layout";
import { Head } from "@inertiajs/react";

export default function Greet({ name }) {
  return (
    <Layout>
      <Head title="Greet" />
      <h1>Hey there, {name}!</h1>
    </Layout>
  );
}
