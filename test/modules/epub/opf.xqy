(: Copyright (C) 2021 Reece H. Dunn.
 : SPDX-License-Identifier: Apache-2.0
 :
 : Reference: https://www.w3.org/publishing/epub3/epub-packages.html
 :)
xquery version "3.1";
module namespace test = "http://www.idpf.org/2007/opf/test";

import module namespace opf = "http://www.idpf.org/2007/opf" at "../../../src/modules/epub/opf.xqy";
import module namespace unit = "http://basex.org/modules/unit";

declare %private function test:assert-map-equals($returned as map(*), $expected as map(*)) {
  unit:assert-equals(
    fn:sort(map:for-each($returned, map:entry#2), (), map:keys#1),
    fn:sort(map:for-each($expected, map:entry#2), (), map:keys#1)
  )
};

declare %unit:test function test:reserved-prefixes() {
  test:assert-map-equals(
    opf:prefixes(<opf:package/>),
    map:merge((
      map:entry("a11y:", "http://www.idpf.org/epub/vocab/package/a11y/#"),
      map:entry("dcterms:", "http://purl.org/dc/terms/"),
      map:entry("marc:", "http://id.loc.gov/vocabulary/"),
      map:entry("media:", "http://www.idpf.org/epub/vocab/overlays/#"),
      map:entry("onix:", "http://www.editeur.org/ONIX/book/codelists/current.html#"),
      map:entry("rendition:", "http://www.idpf.org/vocab/rendition/#"),
      map:entry("schema:", "http://schema.org/"),
      map:entry("xsd:", "http://www.w3.org/2001/XMLSchema#"),
      ()
    ))
  )
};
