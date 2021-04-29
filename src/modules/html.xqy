(: Copyright (C) 2021 Reece H. Dunn.
 : SPDX-License-Identifier: Apache-2.0
 :)
xquery version "3.1";
module namespace html = "http://www.w3.org/1999/xhtml";

declare function html:simplify($node as node()) as node()* {
  typeswitch ($node)
  (: Don't include text elements that look like css. :)
  case text() return
    if (contains($node, "margin-bottom: ")) then
      ()
    else
      $node
  (: Can't currently display images. :)
  case element(html:img) return
    ()
  (: Inline these elements. :)
  case element(html:a) | element(html:font) return
    $node/node() ! html:simplify(.)
  (: Copy these elements. :)
  case element(html:span) return
    if ($node/html:p) then
      $node/node() ! html:simplify(.)
    else
      element { local-name($node) } {
        $node/@*,
        $node/node() ! html:simplify(.)
      }
  case element() return
    element { local-name($node) } {
      $node/@*,
      $node/node() ! html:simplify(.)
    }
  (: Don't include comment elements. :)
  default return
    ()
};
