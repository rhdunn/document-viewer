(: Copyright (C) 2021 Reece H. Dunn. SPDX-License-Identifier: Apache-2.0 :)
xquery version "3.1";
module namespace page = "http://basex.org/examples/web-page";

import module namespace epub = "http://www.idpf.org/2007/ops" at "../src/modules/epub/epub.xqy";
import module namespace file = "http://expath.org/ns/file";
import module namespace opf = "http://www.idpf.org/2007/opf" at "../src/modules/epub/opf.xqy";

declare namespace http = "http://expath.org/ns/http-client";
declare namespace ncx = "http://www.daisy.org/z3986/2005/ncx/";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rest = "http://exquery.org/ns/restxq";

declare %private function page:html(
  $lang as xs:string?,
  $title as xs:string?,
  $head-content as element()*,
  $body as element(body)
) as element(html) {
  <html>{
    if (exists($lang)) then attribute lang {$lang} else (),
    <head>{
      if (exists($title)) then <title>{$title}</title> else (),
      <meta charset="utf-8"/>,
      <link rel="shortcut icon" href="data:image/x-icon;," type="image/x-icon"/>,
      <meta name="viewport" content="width=device-width, initial-scale=1"/>,
      <link rel="stylesheet" type="text/css" href="/static/style.css"/>,
      $head-content
    }</head>,
    $body
  }</html>
};

declare %private function page:metadata-row($label, $metadata) {
  if (exists($metadata)) then
    <tr>
      <th>{$label}</th>
      <td>{
        if (count($metadata) > 1) then
          <ol class="inline-list">{$metadata ! <li>{?value}</li>}</ol>
        else
          $metadata?value
      }</td>
    </tr>
  else
    ()
};

declare %private function page:epub($epub as element(epub:archive)) as element(html) {
  let $opf := epub:package($epub)
  let $meta := opf:metadata($opf)
  return page:html($meta?language[1]?value, $meta?title[1]?value, epub:style($epub), <body>{
    <div class="toc">{
      for $navpoint in epub:toc($epub)/ncx:navMap/ncx:navPoint
      let $src := tokenize($navpoint/ncx:content/@src/string(), "#")
      return if (count($src) = 1) then
        let $item := opf:manifest-by-href($opf, $src)
        return <div><a href="#{$item/@id}">{$navpoint/ncx:navLabel/ncx:text/text()}</a></div>
      else
        <div><a href="#{$src[2]}">{$navpoint/ncx:navLabel/ncx:text/text()}</a></div>
    }</div>,
    <div class="nav-links">
      <a href="/?path={fn:encode-for-uri(file:parent($epub/@path))}" title="Go to the parent directory.">Back</a>
    </div>,
    <div class="info-pane">
      <table class="metadata">
        <tbody>{
          page:metadata-row("Title", $meta?title),
          page:metadata-row("Creator", $meta?creator),
          page:metadata-row("Contributor", $meta?contributor),
          page:metadata-row("Publisher", $meta?publisher),
          page:metadata-row("Description", $meta?description),
          page:metadata-row("Language", $meta?language),
          page:metadata-row("Date", $meta?date[1]),
          page:metadata-row("Subjects", $meta?subject),
          page:metadata-row("Coverage", $meta?coverage),
          page:metadata-row("Format", $meta?format),
          page:metadata-row("Rights", $meta?rights),
          page:metadata-row("Source", $meta?source),
          page:metadata-row("Type", $meta?type),
          ()
        }</tbody>
      </table>
    </div>,
    <main class="epub">{epub:contents($epub)}</main>
  }</body>)
};

declare %private function page:list-file(
  $path as xs:string,
  $file as xs:string,
  $query-params as xs:string
) as element() {
  if (file:is-dir($path)) then
    <div class="directory"><a href="/?path={fn:encode-for-uri($path)}{$query-params}">{$file}</a></div>
  else if (fn:ends-with($file, ".epub")) then
    <div class="file epub"><a href="/?path={fn:encode-for-uri($path)}{$query-params}">{$file}</a></div>
  else
    <div class="file">{$file}</div>
};

declare %private function page:list-dir(
  $path as xs:string,
  $sort-by as xs:string,
  $sort-order as xs:string
) as element(html) {
  let $query-params := (
    if ($sort-by ne "name") then "sort-by=" || $sort-by else (),
    if ($sort-order eq "descending") then "sort-order=descending" else ()
  )
  let $query-params :=
    if (empty($query-params)) then
      ""
    else
      "&amp;" || string-join($query-params, "&amp;")
  return page:html("en", file:name($path), (), <body>
    <div class="nav-links">
      <a href="/?path={fn:encode-for-uri(file:parent($path))}{$query-params}"
         title="Go to the parent directory.">Back</a>
    </div>
    <main>{
      if ($sort-order eq "ascending") then
        for $file in file:list($path)
        let $file := fn:replace($file, "[\\/]$", "")
        let $path := $path || "\" || $file
        let $order-key :=
          switch ($sort-by)
          case "date" return file:last-modified($path)
          case "size" return file:size($path)
          default return $file
        order by $order-key ascending
        return page:list-file($path, $file, $query-params)
      else
        for $file in file:list($path)
        let $file := fn:replace($file, "[\\/]$", "")
        let $path := $path || "\" || $file
        let $order-key :=
          switch ($sort-by)
          case "date" return file:last-modified($path)
          case "size" return file:size($path)
          default return $file
        order by $order-key descending
        return page:list-file($path, $file, $query-params)
    }</main>
  </body>)
};

declare
  %rest:GET
  %rest:path("/about")
  %output:method("html")
  %output:html-version("5.0")
function page:about() as element(html) {
  page:html("en", "Document Viewer", (), <body>
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
  </body>)
};

declare
  %rest:GET
  %rest:path("/entry")
  %rest:query-param("path", "{$path}", "")
  %rest:query-param("file", "{$filename}", "")
function page:entry($path as xs:string, $filename as xs:string) as item()* {
  let $entry := epub:load-entry($path, $filename)
  return if (exists($entry)) then (
    <rest:response>
      <http:response status="200">
        <http:header name="Content-Type" value="{epub:mimetype($filename)}"/>
      </http:response>
    </rest:response>,
    $entry
  ) else (
    <rest:response>
      <http:response status="404">
        <http:header name="Content-Type" value="text/plain"/>
      </http:response>
    </rest:response>,
    "Not Found"
  )
};

declare
  %rest:GET
  %rest:path("xml")
  %rest:query-param("path", "{$path}", "")
  %output:method("xml")
function page:xml($path as xs:string) as element()? {
  if (fn:ends-with($path, ".epub")) then
    epub:load($path)
  else
    ()
};

declare
  %rest:GET
  %rest:path("")
  %rest:query-param("path", "{$path}", "")
  %rest:query-param("sort-by", "{$sort-by}", "name")
  %rest:query-param("sort-order", "{$sort-order}", "ascending")
  %output:method("html")
  %output:html-version("5.0")
function page:start($path as xs:string, $sort-by as xs:string, $sort-order as xs:string) as element(html)? {
  if (fn:ends-with($path, ".epub")) then
    let $epub := epub:load($path)
    return page:epub($epub)
  else if ($path = "") then
    page:about()
  else if (file:is-dir($path)) then
    page:list-dir(fn:replace($path, "[\\/]$", ""), $sort-by, $sort-order)
  else
    page:about()
};
