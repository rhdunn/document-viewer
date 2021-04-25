(: Copyright (C) 2021 Reece H. Dunn.
 : SPDX-License-Identifier: Apache-2.0
 :)
xquery version "3.1";
module namespace html = "http://www.w3.org/1999/xhtml";

declare function html:simplify($element as node()) as node()* {
  typeswitch ($element)
  (: Don't include text elements that look like css. :)
  case text() return
    if (contains($element, "margin-bottom: ")) then
      ()
    else
      $element
  (: Can't currently display images. :)
  case element(html:img) return
    ()
  (: Inline these elements. :)
  case element(html:a) | element(html:font) return
    $element/node() ! html:simplify(.)
  (: Copy these elements. :)
  case element(html:span) return
    if ($element/html:p) then
      $element/node() ! html:simplify(.)
    else
      element { local-name($element) } {
        $element/@*,
        $element/node() ! html:simplify(.)
      }
  case element() return
    element { local-name($element) } {
      $element/@*,
      $element/node() ! html:simplify(.)
    }
  (: Don't include comment elements. :)
  default return
    ()
};
