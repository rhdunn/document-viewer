(: Copyright (C) 2021 Reece H. Dunn.
 : SPDX-License-Identifier: Apache-2.0
 :)
xquery version "3.1";
module namespace epub = "http://www.idpf.org/2007/ops";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace ncx = "http://www.daisy.org/z3986/2005/ncx/";
declare namespace ocf = "urn:oasis:names:tc:opendocument:xmlns:container";

import module namespace archive = "http://basex.org/modules/archive";
import module namespace file = "http://expath.org/ns/file";
import module namespace html = "http://www.w3.org/1999/xhtml" at "../html.xqy";
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
      let $text := archive:extract-text($archive, $entry)
      return fn:parse-xml($text)
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
  let $entry := archive:entries($archive)[ends-with(text(), $filename)]
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

declare function epub:entry(
  $epub as element(epub:archive),
  $opf as element(opf:package),
  $href as xs:string
) as element(epub:entry)? {
  let $root := tokenize($opf/../@filename, "/")[position() != last()]
  let $root-href := string-join(($root, $href), "/")
  return $epub/epub:entry[@filename = ($href, $root-href)]
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
  for $entry in epub:spine($epub)
  return (
    <a class="epub-spine" id="{$entry/@id}"/>,
    for $node in $entry/html:html/html:body/node()
    return html:simplify($node, $resource-uri)
  )
};
