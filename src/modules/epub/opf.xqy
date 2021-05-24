(: Copyright (C) 2021 Reece H. Dunn. SPDX-License-Identifier: Apache-2.0
 :
 : Reference: https://www.w3.org/publishing/epub3/epub-packages.html
 : Reference: https://www.dublincore.org/specifications/dublin-core/dcmi-terms/#section-3
 :)
xquery version "3.1";
module namespace opf = "http://www.idpf.org/2007/opf";

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";

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
    for tumbling window $prefix in fn:tokenize($opf/@prefix)
        start at $s when true()
        only end at $e when $e - $s eq 1
    return map:entry($prefix[1], $prefix[2]),
    ()
  ), map { "duplicates": "use-last" })
};

declare %private function opf:extract-metadata($items as element()*, $name as xs:string) as map(xs:string, item()*)? {
  if (exists($items)) then
    map:entry($name,
      $items ! map:merge((
        map:entry("value", ./normalize-space()),
        ()
      ))
    )
  else
    ()
};

declare function opf:metadata($opf as element(opf:package)) as map(xs:string, item()*) {
  let $meta := $opf/opf:metadata
  return map:merge((
    (: Dublin Core elements :)
    $meta/(
      dc:contributor|dct:contributor|meta[@property="dcterms:contributor"]
    ) => opf:extract-metadata("contributor"),
    $meta/(
      dc:coverage|dct:coverage|meta[@property="dcterms:coverage"]
    ) => opf:extract-metadata("coverage"),
    $meta/(
      dc:creator|dct:creator|meta[@property="dcterms:creator"]
    ) => opf:extract-metadata("creator"),
    $meta/(
      dc:date|dct:date|meta[@property="dcterms:date"]
    ) => opf:extract-metadata("date"),
    $meta/(
      dc:description|dct:description|meta[@property="dcterms:description"]
    ) => opf:extract-metadata("description"),
    $meta/(
      dc:format|dct:format|meta[@property="dcterms:format"]
    ) => opf:extract-metadata("format"),
    $meta/(
      dc:identifier|dct:identifier|meta[@property="dcterms:identifier"]
    ) => opf:extract-metadata("identifier"),
    $meta/(
      dc:language|dct:language|meta[@property="dcterms:language"]
    ) => opf:extract-metadata("language"),
    $meta/(
      dc:publisher|dct:publisher|meta[@property="dcterms:publisher"]
    ) => opf:extract-metadata("publisher"),
    $meta/(
      dc:relation|dct:relation|meta[@property="dcterms:relation"]
    ) => opf:extract-metadata("relation"),
    $meta/(
      dc:rights|dct:rights|meta[@property="dcterms:rights"]
    ) => opf:extract-metadata("rights"),
    $meta/(
      dc:source|dct:source|meta[@property="dcterms:source"]
    ) => opf:extract-metadata("source"),
    $meta/(
      dc:subject|dct:subject|meta[@property="dcterms:subject"]
    ) => opf:extract-metadata("subject"),
    $meta/(
      dc:title|dct:title|meta[@property="dcterms:title"]
    ) => opf:extract-metadata("title"),
    $meta/(
      dc:type|dct:type|meta[@property="dcterms:type"]
    ) => opf:extract-metadata("type"),
    ()
  ))
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
