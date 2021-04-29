(: Copyright (C) 2021 Reece H. Dunn.
 : SPDX-License-Identifier: Apache-2.0
 :)
xquery version "3.1";
module namespace page = "http://basex.org/examples/web-page";

import module namespace epub = "http://www.idpf.org/2007/ops" at "../src/modules/epub/epub.xqy";
import module namespace file = "http://expath.org/ns/file";
import module namespace opf = "http://www.idpf.org/2007/opf" at "../src/modules/epub/opf.xqy";

declare namespace ncx = "http://www.daisy.org/z3986/2005/ncx/";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rest = "http://exquery.org/ns/restxq";

declare %private function page:epub($path as xs:string) as element(html) {
  let $epub := epub:load($path)
  let $opf := epub:package($epub)
  return <html lang="{opf:language($opf)}">
    <head>{
      <title>{opf:title($opf)}</title>,
      <meta name="viewport" content="width=device-width, initial-scale=1"/>,
      <link rel="stylesheet" type="text/css" href="/static/style.css"/>,
      epub:style($epub)
    }</head>
    <body>{
      <div class="toc">{
        for $navpoint in epub:toc($epub)/ncx:navMap/ncx:navPoint
        return <div><a href="#{$navpoint/@id}">{$navpoint/ncx:navLabel/ncx:text/text()}</a></div>
      }</div>,
      <div class="nav-links">
        <a href="/?path={fn:encode-for-uri(file:parent($path))}" title="Go to the parent directory.">Back</a>
      </div>,
      <main class="epub">{epub:contents($epub)}</main>
    }</body>
  </html>
};

declare %private function page:list-dir($path as xs:string) as element(html) {
  <html lang="en">
    <head>
      <title>{file:name($path)}</title>
      <link rel="stylesheet" type="text/css" href="/static/style.css"/>
    </head>
    <body>
      <div class="nav-links">
        <a href="/?path={fn:encode-for-uri(file:parent($path))}" title="Go to the parent directory.">Back</a>
      </div>
      <main>{
        for $file in file:list($path)
        let $file := fn:replace($file, "[\\/]$", "")
        let $path := $path || "\" || $file
        return if (file:is-dir($path)) then
          <div class="directory"><a href="/?path={fn:encode-for-uri($path)}">{$file}</a></div>
        else if (fn:ends-with($file, ".epub")) then
          <div class="file epub"><a href="/?path={fn:encode-for-uri($path)}">{$file}</a></div>
        else
          <div class="file">{$file}</div>
      }</main>
    </body>
  </html>
};

declare
  %rest:GET
  %rest:path("/about")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
function page:about() as element(html) {
  <html lang="en">
    <head>
      <title>Document Viewer</title>
      <link rel="stylesheet" type="text/css" href="/static/style.css"/>
    </head>
    <body>
      <main>
        <h1>Document Viewer</h1>
        <p>This is a web-based document viewer for the following document formats:</p>
        <ol>
          <li>ePub 2 and ePub 3</li>
        </ol>
        <h2>License</h2>
        <p>Copyright (C) 2021 Reece H. Dunn</p>
        <p>The document viewer project is licensed under the Apache 2.0 license.</p>
      </main>
    </body>
  </html>
};

declare
  %rest:GET
  %rest:path("")
  %rest:query-param("path", "{$path}", "")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
function page:start($path as xs:string) as element(html)? {
  if (fn:ends-with($path, ".epub")) then
    page:epub($path)
  else if ($path = "") then
    page:about()
  else if (file:is-dir($path)) then
    page:list-dir(fn:replace($path, "[\\/]$", ""))
  else
    page:about()
};
