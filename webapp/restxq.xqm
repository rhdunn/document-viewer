(: Copyright (C) 2021 Reece H. Dunn.
 : SPDX-License-Identifier: Apache-2.0
 :)
xquery version "3.1";
module namespace page = "http://basex.org/examples/web-page";

import module namespace epub = "http://www.idpf.org/2007/ops" at "../src/modules/epub/epub.xqy";
import module namespace opf = "http://www.idpf.org/2007/opf" at "../src/modules/epub/opf.xqy";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rest = "http://exquery.org/ns/restxq";

declare %private function page:epub($path as xs:string) as element(html) {
  let $epub := epub:load($path)
  let $opf := epub:package($epub)
  return <html lang="{opf:language($opf)}">
    <head>
      <title>{opf:title($opf)}</title>
      <link rel="stylesheet" type="text/css" href="/static/style.css"/>
    </head>
    <body>{epub:contents($epub)}</body>
  </html>
};

declare
  %rest:GET
  %rest:path("")
  %rest:query-param("path", "{$path}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
function page:start($path as xs:string?) as element(html)? {
  if (fn:ends-with($path, ".epub")) then
    page:epub($path)
  else
    ()
};
