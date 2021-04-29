(: Copyright (C) 2021 Reece H. Dunn.
 : SPDX-License-Identifier: Apache-2.0
 :)
xquery version "3.1";
module namespace html = "http://www.w3.org/1999/xhtml";

declare function html:simplify($node as node(), $resource-uri as xs:string?) as node()* {
  typeswitch ($node)
  (: Don't include text elements that look like css. :)
  case text() return
    if (contains($node, "margin-bottom: ")) then
      ()
    else
      $node
  (: Process media objects to allow the content to be loaded. :)
  case element(html:img) return
    element { local-name($node) } {
      if (exists($resource-uri)) then (
        $node/@*[not(local-name() = "src")],
        $node/@src ! attribute src { $resource-uri || . }
      ) else
        $node/@*,
      $node/node() ! html:simplify(., $resource-uri)
    }
  (: Inline these elements. :)
  case element(html:a) | element(html:font) return
    $node/node() ! html:simplify(., $resource-uri)
  (: Copy these elements. :)
  case element(html:span) return
    if ($node/html:p) then
      $node/node() ! html:simplify(., $resource-uri)
    else
      element { local-name($node) } {
        $node/@*,
        $node/node() ! html:simplify(., $resource-uri)
      }
  case element() return
    element { local-name($node) } {
      $node/@*,
      $node/node() ! html:simplify(., $resource-uri)
    }
  (: Don't include comment elements. :)
  default return
    ()
};
