let serverDirect = "htts://localhost/images";

window.addEventListener("load", function () {
  errdiv = document.createElement("div");
  if (true) {
    errdiv.classList.add("console");
    document.body.appendChild(errdiv);
    window.onerror = function (errorMsg, url, lineNumber, column, errorObj) {
      errdiv.innerHTML +=
        "<br />Error: " +
        errorMsg +
        " Script: " +
        url +
        " Line: " +
        lineNumber +
        " Column: " +
        column +
        " StackTrace: " +
        errorObj;
    };
  }

  var dynamic_menu = new Menu();
  var wprompt = new WPrompt();
  var requestmgr = new RequestManager();

  requestmgr.onResponse = function (id, ok) {
    $.post(
      "http://vrp/request",
      JSON.stringify({ act: "response", id: id, ok: ok })
    );
  };
  wprompt.onClose = function () {
    $.post(
      "http://vrp/prompt",
      JSON.stringify({ act: "close", result: wprompt.result })
    );
  };
  dynamic_menu.onClose = function () {
    $.post(
      "http://vrp/menu",
      JSON.stringify({ act: "close", id: dynamic_menu.id })
    );
  };
  dynamic_menu.onValid = function (choice, mod) {
    $.post(
      "http://vrp/menu",
      JSON.stringify({
        act: "valid",
        id: dynamic_menu.id,
        choice: choice,
        mod: mod,
      })
    );
  };

  var current_menu = dynamic_menu;
  var pbars = {};
  var divs = {};

  window.addEventListener("message", function (evt) {
    var data = evt.data;

    if (data.act == "cfg") {
      cfg = data.cfg;
    } else if (data.act == "pause_change") {
      if (data.paused) $(document.body).hide();
      else $(document.body).show();
    } else if (data.act == "open_menu") {
      current_menu.close();
      dynamic_menu.open(data.menudata.name, data.menudata.choices);
      dynamic_menu.id = data.menudata.id;

      var css = data.menudata.css;
      if (css.top) dynamic_menu.div.style.top = css.top;
      if (css.header_color)
        dynamic_menu.div_header.style.backgroundColor = css.header_color;

      current_menu = dynamic_menu;
    } else if (data.act == "close_menu") {
      current_menu.close();
    } else if (data.act == "prompt") {
      wprompt.open(data.title, data.text);
    } else if (data.act == "request") {
      requestmgr.addRequest(data.id, data.text, data.time);
    } else if (data.act == "event") {
      if (data.event == "Y") {
        requestmgr.respond(true);
      } else if (data.event == "U") {
        requestmgr.respond(false);
      }
    } else if (data.act == "setDirect") {
      serverDirect = data.myDirect;
    }
  });
});
