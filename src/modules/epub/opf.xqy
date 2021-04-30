(: Copyright (C) 2021 Reece H. Dunn.
 : SPDX-License-Identifier: Apache-2.0
 :)
xquery version "3.1";
module namespace opf = "http://www.idpf.org/2007/opf";

declare namespace dc = "http://purl.org/dc/elements/1.1/";

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
