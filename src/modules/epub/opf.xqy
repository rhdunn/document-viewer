(: Copyright (C) 2021 Reece H. Dunn.
 : SPDX-License-Identifier: Apache-2.0
 :
 : Reference: https://www.w3.org/publishing/epub3/epub-packages.html
 :)
xquery version "3.1";
module namespace opf = "http://www.idpf.org/2007/opf";

declare namespace dc = "http://purl.org/dc/elements/1.1/";

declare function opf:prefixes($opf as element(opf:package)) as map(xs:string, xs:string) {
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
};

declare function opf:metadata($opf as element(opf:package)) as element()* {
  $opf/opf:metadata/*
};

declare function opf:title($opf as element(opf:package)) as text()? {
  $opf/opf:metadata/dc:title/text()
};

declare function opf:language($opf as element(opf:package)) as text()? {
  $opf/opf:metadata/dc:language/text()
};

declare function opf:manifest($opf as element(opf:package), $ids as xs:string*) as element(opf:item)* {
  for $id in $ids
  return $opf/opf:manifest/opf:item[@id = $id]
};

declare function opf:manifest-by-href($opf as element(opf:package), $hrefs as xs:string*) as element(opf:item)* {
  for $href in $hrefs
  return $opf/opf:manifest/opf:item[@href = $href]
};

declare function opf:spine($opf as element(opf:package)) as element(opf:item)* {
  opf:manifest($opf, $opf/opf:spine/opf:itemref/@idref)
};

declare function opf:toc($opf as element(opf:package)) as element(opf:item)? {
  opf:manifest($opf, $opf/opf:spine/@toc)
};
