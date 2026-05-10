import { Link } from "@inertiajs/react";
import React from "react";

export default function Home() {
  return (
    <div>
      <h1>Demo</h1>

      <ul>
        <li>
          <Link href="/about">About</Link>
        </li>
      </ul>
    </div>
  );
}
