(: Copyright (C) 2021 Reece H. Dunn.
 : SPDX-License-Identifier: Apache-2.0
 :)
xquery version "3.1";
module namespace epub = "http://www.idpf.org/2007/ops";

declare namespace err = "http://www.w3.org/2005/xqt-errors";
declare namespace ncx = "http://www.daisy.org/z3986/2005/ncx/";
declare namespace ocf = "urn:oasis:names:tc:opendocument:xmlns:container";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

import module namespace archive = "http://basex.org/modules/archive";
import module namespace file = "http://expath.org/ns/file";
import module namespace html = "http://www.w3.org/1999/xhtml" at "../html.xqy";
import module namespace htmlparser = "http://basex.org/modules/html";
import module namespace opf = "http://www.idpf.org/2007/opf" at "opf.xqy";

declare %private variable $epub:extension-to-mimetype := map {
  "apng": "image/apng",
  "avif": "image/avif",
  "css": "text/css",
  "gif": "image/gif",
  "htm": "application/xhtml+xml",
  "html": "application/xhtml+xml",
  "jpeg": "image/jpeg",
  "jpg": "image/jpeg",
  "ncx": "application/x-dtbncx+xml",
  "opf": "application/oebps-package+xml",
  "png": "image/png",
  "svg": "image/svg+xml",
  "webp": "image/webp",
  "xhtml": "application/xhtml+xml",
  "xml": "application/xml"
};

declare function epub:mimetype($filename as xs:string) as xs:string {
  let $extension := tokenize($filename, "\.")[last()]
  return if ($filename = "mimetype") then
    "text/plain"
  else
    ($epub:extension-to-mimetype?($extension), "application/octet-stream")[1]
};

declare %private function epub:extract-xhtml(
  $archive as xs:base64Binary,
  $entry as element(archive:entry)
) as document-node() {
  try {
    let $text := archive:extract-text($archive, $entry)
    return fn:parse-xml($text)
  } catch * {
    if (epub:mimetype($entry/string()) = "application/xhtml+xml") then
      let $data := archive:extract-binary($archive, $entry)
      return htmlparser:parse($data)
    else
      fn:error($err:code, $err:description)
  }
};

declare %private function epub:entry($archive as xs:base64Binary, $entry as element(archive:entry)) as element(epub:entry) {
  let $filename := $entry/string()
  let $mimetype := epub:mimetype($filename)
  return <epub:entry>{
    $entry/@*,
    attribute filename { $filename },
    attribute mimetype { $mimetype },
    if (starts-with($mimetype, "text/")) then
      archive:extract-text($archive, $entry)
    else if ($mimetype = ("application/xml", "image/svg+xml")
         or (starts-with($mimetype, "application") and ends-with($mimetype, "+xml"))) then
      epub:extract-xhtml($archive, $entry)
    else
      archive:extract-binary($archive, $entry),
    ()
  }</epub:entry>
};

declare function epub:create-from-binary($archive as xs:base64Binary) as element(epub:archive) {
  epub:create-from-binary($archive, ())
};

declare function epub:create-from-binary($archive as xs:base64Binary, $path as xs:string?) as element(epub:archive) {
  <epub:archive>{
    $path ! attribute path { $path },
    archive:entries($archive) ! epub:entry($archive, .)
  }</epub:archive>
};

declare function epub:load($path as xs:string) as element(epub:archive) {
  let $archive := file:read-binary($path)
  return epub:create-from-binary($archive, $path)
};

declare function epub:load-entry($path as xs:string, $filename as xs:string) as xs:base64Binary? {
  let $archive := file:read-binary($path)
  let $entry := archive:entries($archive)[text() = $filename]
  return archive:extract-binary($archive, $entry)
};

declare function epub:container($epub as element(epub:archive)) as element(ocf:container)? {
  $epub/epub:entry[@filename = "META-INF/container.xml"]/ocf:container
};

declare function epub:package($epub as element(epub:archive)) as element(opf:package)? {
  let $package-root := epub:container($epub)/ocf:rootfiles/ocf:rootfile[
    @media-type = $epub:extension-to-mimetype?("opf")
  ]
  return $epub/epub:entry[@filename = $package-root/@full-path]/opf:package
};

declare function epub:normalize-path($path as xs:string*) as xs:string* {
  if ($path = "..") then
    let $normalized :=
      for tumbling window $part in $path
        start at $s when true()
        only end $end at $e when $e - $s le 2
      where $end ne ".."
      return $part
    return epub:normalize-path($normalized)
  else
    $path
};

declare function epub:resolve-path(
  $epub as element(epub:archive),
  $opf as element(opf:package),
  $href as xs:string
) as xs:string {
  let $filenames := $epub/epub:entry/@filename
  return if ($href = $filenames) then
    $href
  else
    let $path := (
        tokenize($opf/../@filename, "/")[position() != last()],
        tokenize($href, "/")
      )
    return string-join(epub:normalize-path($path), "/")
};

declare function epub:entry(
  $epub as element(epub:archive),
  $opf as element(opf:package),
  $href as xs:string
) as element(epub:entry)? {
  $epub/epub:entry[@filename = epub:resolve-path($epub, $opf, $href)]
};

declare function epub:toc($epub as element(epub:archive)) as element()? {
  let $opf := epub:package($epub)
  let $toc := opf:toc($opf)
  return epub:entry($epub, $opf, $toc/@href)/*
};

declare function epub:spine($epub as element(epub:archive)) as element(epub:entry)* {
  let $opf := epub:package($epub)
  for $item in opf:spine($opf)
  let $entry := epub:entry($epub, $opf, $item/@href)
  return <epub:entry id="{$item/@id}">{$entry/@*, $entry/*}</epub:entry>
};

declare function epub:style($epub as element(epub:archive)) as element(style)? {
  let $links := epub:spine($epub)/html:html/html:head/html:link[@rel = "stylesheet" and @type = "text/css"]
  let $link-hrefs := fn:distinct-values($links/@href)
  return if (exists($link-hrefs)) then
    <style type="text/css">{epub:entry($epub, epub:package($epub), $link-hrefs[1])/text()}</style>
  else
    ()
};

declare function epub:contents($epub as element(epub:archive)) as node()* {
  let $resource-uri := $epub/@path ! ("/entry?path=" || . || "&amp;file=")
  let $opf := epub:package($epub)
  for $entry in epub:spine($epub)
  return <section id="{$entry/@id}">{
    for $node in $entry/*:html/*:body/node()
    return html:simplify($node, $resource-uri, function ($href) {
      epub:resolve-path($epub, $opf, $href)
    })
  }</section>
};
