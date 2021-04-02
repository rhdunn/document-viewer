(: Copyright (C) 2021 Reece H. Dunn.
 : SPDX-License-Identifier: Apache-2.0
 :)
xquery version "3.1";

module  namespace epub = "http://www.idpf.org/2007/ops";
declare namespace ncx = "http://www.daisy.org/z3986/2005/ncx/";
declare namespace ocf = "urn:oasis:names:tc:opendocument:xmlns:container";
declare namespace opf = "http://www.idpf.org/2007/opf";

import module namespace archive = "http://basex.org/modules/archive";
import module namespace file = "http://expath.org/ns/file";

declare %private variable $epub:extension-to-mimetype := map {
  "css": "text/css",
  "htm": "application/xhtml+xml",
  "html": "application/xhtml+xml",
  "ncx": "application/x-dtbncx+xml",
  "opf": "application/oebps-package+xml",
  "xhtml": "application/xhtml+xml",
  "xml": "application/xml"
};

declare %private function epub:mimetype-from-extension($filename as xs:string) as xs:string {
  let $extension := tokenize($filename, "\.")[last()]
  return if ($filename = "mimetype") then
    "text/plain"
  else
    ($epub:extension-to-mimetype?($extension), "application/octet-stream")[1]
};

declare %private function epub:entry($archive as xs:base64Binary, $entry as element(archive:entry)) as element(epub:entry) {
  let $filename := $entry/string()
  let $mimetype := epub:mimetype-from-extension($filename)
  return <epub:entry>{
    $entry/@*,
    attribute filename { $filename },
    attribute mimetype { $mimetype },
    if (starts-with($mimetype, "text/")) then
      archive:extract-text($archive, $entry)
    else if ($mimetype = "application/xml" or (starts-with($mimetype, "application") and ends-with($mimetype, "+xml"))) then
      let $text := archive:extract-text($archive, $entry)
      return fn:parse-xml($text)
    else
      archive:extract-binary($archive, $entry),
    ()
  }</epub:entry>
};

declare function epub:create-from-binary($archive as xs:base64Binary) as element(epub:archive) {
  <epub:archive>{ archive:entries($archive) ! epub:entry($archive, .) }</epub:archive>
};

declare function epub:load($path as xs:string) as element(epub:archive) {
  let $archive := file:read-binary($path)
  return epub:create-from-binary($archive)
};
