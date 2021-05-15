(: Copyright (C) 2021 Reece H. Dunn.
 : SPDX-License-Identifier: Apache-2.0
 :
 : Reference: https://www.w3.org/publishing/epub3/epub-packages.html
 : Reference: https://www.dublincore.org/specifications/dublin-core/dcmi-terms/#section-3
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

(: prefixes :)

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

declare %unit:test function test:custom-prefixes() {
  test:assert-map-equals(
    opf:prefixes(<opf:package prefix="
      foaf: http://xmlns.com/foaf/spec/
       dbp: http://dbpedia.org/ontology
    "/>),
    map:merge((
      map:entry("a11y:", "http://www.idpf.org/epub/vocab/package/a11y/#"),
      map:entry("dcterms:", "http://purl.org/dc/terms/"),
      map:entry("marc:", "http://id.loc.gov/vocabulary/"),
      map:entry("media:", "http://www.idpf.org/epub/vocab/overlays/#"),
      map:entry("onix:", "http://www.editeur.org/ONIX/book/codelists/current.html#"),
      map:entry("rendition:", "http://www.idpf.org/vocab/rendition/#"),
      map:entry("schema:", "http://schema.org/"),
      map:entry("xsd:", "http://www.w3.org/2001/XMLSchema#"),
      map:entry("foaf:", "http://xmlns.com/foaf/spec/"),
      map:entry("dbp:", "http://dbpedia.org/ontology"),
      ()
    ))
  )
};

declare %unit:test function test:prefix-same-as-reserved-prefix() {
  test:assert-map-equals(
    opf:prefixes(<opf:package prefix="
      foaf: http://xmlns.com/foaf/spec/ dcterms: http://purl.org/dc/terms/ dbp: http://dbpedia.org/ontology
    "/>),
    map:merge((
      map:entry("a11y:", "http://www.idpf.org/epub/vocab/package/a11y/#"),
      map:entry("dcterms:", "http://purl.org/dc/terms/"),
      map:entry("marc:", "http://id.loc.gov/vocabulary/"),
      map:entry("media:", "http://www.idpf.org/epub/vocab/overlays/#"),
      map:entry("onix:", "http://www.editeur.org/ONIX/book/codelists/current.html#"),
      map:entry("rendition:", "http://www.idpf.org/vocab/rendition/#"),
      map:entry("schema:", "http://schema.org/"),
      map:entry("xsd:", "http://www.w3.org/2001/XMLSchema#"),
      map:entry("foaf:", "http://xmlns.com/foaf/spec/"),
      map:entry("dbp:", "http://dbpedia.org/ontology"),
      ()
    ))
  )
};

declare %unit:test function test:prefix-different-to-reserved-prefix() {
  test:assert-map-equals(
    opf:prefixes(<opf:package prefix="
      foaf: http://xmlns.com/foaf/spec/ dcterms: http://purl.org/dc/elements/1.1/ dbp: http://dbpedia.org/ontology
    "/>),
    map:merge((
      map:entry("a11y:", "http://www.idpf.org/epub/vocab/package/a11y/#"),
      map:entry("dcterms:", "http://purl.org/dc/elements/1.1/"),
      map:entry("marc:", "http://id.loc.gov/vocabulary/"),
      map:entry("media:", "http://www.idpf.org/epub/vocab/overlays/#"),
      map:entry("onix:", "http://www.editeur.org/ONIX/book/codelists/current.html#"),
      map:entry("rendition:", "http://www.idpf.org/vocab/rendition/#"),
      map:entry("schema:", "http://schema.org/"),
      map:entry("xsd:", "http://www.w3.org/2001/XMLSchema#"),
      map:entry("foaf:", "http://xmlns.com/foaf/spec/"),
      map:entry("dbp:", "http://dbpedia.org/ontology"),
      ()
    ))
  )
};

(: metadata :)

declare %unit:test function test:empty-metadata() {
  test:assert-map-equals(
    opf:metadata(<opf:package/>),
    map {}
  )
};

declare %unit:test function test:dublin-core-elements-metadata() {
  test:assert-map-equals(
    opf:metadata(<opf:package>
      <opf:metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
        <dc:title>Lorem Ipsum Dolor</dc:title>
        <dc:language>en-IE</dc:language>
        <dc:identifier>http://www.example.com/test/dublin-core-elements-metadata</dc:identifier>
        <dc:contributor>Andy</dc:contributor>
        <dc:contributor>Samantha</dc:contributor>
        <dc:coverage>London</dc:coverage>
        <dc:coverage>Middle Ages</dc:coverage>
        <dc:format>application/epub+zip</dc:format>
        <dc:creator>Tina</dc:creator>
        <dc:description>This is a Dublin Core elements test.</dc:description>
        <dc:publisher>GitHub</dc:publisher>
        <dc:relation>http://www.example.com/test/</dc:relation>
        <dc:date>05/11/2011</dc:date>
        <dc:rights>Apache-2.0</dc:rights>
        <dc:source>https://github.com/rhdunn/document-viewer</dc:source>
        <dc:subject>opf</dc:subject>
        <dc:subject>metadata</dc:subject>
        <dc:type>electronic</dc:type>
      </opf:metadata>
    </opf:package>),
    map {
      "contributor": (map { "value": "Andy" }, map { "value": "Samantha" }),
      "coverage": (map { "value": "London" }, map { "value": "Middle Ages" }),
      "creator": map { "value": "Tina" },
      "date": map { "value": "05/11/2011" },
      "description": map { "value": "This is a Dublin Core elements test." },
      "format": map { "value": "application/epub+zip" },
      "identifier": map { "value": "http://www.example.com/test/dublin-core-elements-metadata" },
      "language": map { "value": "en-IE" },
      "publisher": map { "value": "GitHub" },
      "relation": map { "value": "http://www.example.com/test/" },
      "rights": map { "value": "Apache-2.0" },
      "source": map { "value": "https://github.com/rhdunn/document-viewer" },
      "subject": (map { "value": "opf" }, map { "value": "metadata" }),
      "title": map { "value": "Lorem Ipsum Dolor" },
      "type": map { "value": "electronic" }
    }
  )
};

declare %unit:test function test:metadata-with-whitespace() {
  test:assert-map-equals(
    opf:metadata(<opf:package>
      <opf:metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
        <dc:title> Lorem Ipsum Dolor </dc:title>
        <dc:language> en-IE </dc:language>
        <dc:identifier> http://www.example.com/test/dublin-core-elements-metadata </dc:identifier>
        <dc:contributor> Andy </dc:contributor>
        <dc:contributor> Samantha </dc:contributor>
        <dc:coverage> London </dc:coverage>
        <dc:coverage> Middle Ages </dc:coverage>
        <dc:format> application/epub+zip </dc:format>
        <dc:creator> Tina </dc:creator>
        <dc:description> This is a Dublin Core elements test. </dc:description>
        <dc:publisher> GitHub </dc:publisher>
        <dc:relation> http://www.example.com/test/ </dc:relation>
        <dc:date> 05/11/2011 </dc:date>
        <dc:rights> Apache-2.0 </dc:rights>
        <dc:source> https://github.com/rhdunn/document-viewer </dc:source>
        <dc:subject> opf </dc:subject>
        <dc:subject> metadata </dc:subject>
        <dc:type> electronic </dc:type>
      </opf:metadata>
    </opf:package>),
    map {
      "contributor": (map { "value": "Andy" }, map { "value": "Samantha" }),
      "coverage": (map { "value": "London" }, map { "value": "Middle Ages" }),
      "creator": map { "value": "Tina" },
      "date": map { "value": "05/11/2011" },
      "description": map { "value": "This is a Dublin Core elements test." },
      "format": map { "value": "application/epub+zip" },
      "identifier": map { "value": "http://www.example.com/test/dublin-core-elements-metadata" },
      "language": map { "value": "en-IE" },
      "publisher": map { "value": "GitHub" },
      "relation": map { "value": "http://www.example.com/test/" },
      "rights": map { "value": "Apache-2.0" },
      "source": map { "value": "https://github.com/rhdunn/document-viewer" },
      "subject": (map { "value": "opf" }, map { "value": "metadata" }),
      "title": map { "value": "Lorem Ipsum Dolor" },
      "type": map { "value": "electronic" }
    }
  )
};
