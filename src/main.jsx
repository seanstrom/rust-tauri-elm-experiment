import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import { Elm } from "./Hello.elm";
import "./style.css";

console.log("test")

Elm.Hello.init({
  node: document.getElementById('root'),
  flags: "Initial Message"
});

// ReactDOM.createRoot(document.getElementById("root")).render(
//   <React.StrictMode>
//     <App />
//   </React.StrictMode>
// );
