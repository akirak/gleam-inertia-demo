import React from "react";

export default function About({ systemVersion }) {
  return (
    <div>
      <h1>About</h1>

      <ul>
        <li>System Version: {systemVersion}</li>
      </ul>
    </div>
  );
}
