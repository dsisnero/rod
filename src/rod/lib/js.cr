module Rod
  module JS
    # Function represents a JavaScript helper function that can be injected into the page.
    struct Function
      getter name : String
      getter definition : String
      getter dependencies : Array(Function)

      def initialize(@name : String, @definition : String, @dependencies : Array(Function) = [] of Function)
      end
    end

    # Functions is the root object that holds all helper functions.
    FUNCTIONS = Function.new(
      name: "functions",
      definition: "() => ({})",
      dependencies: [] of Function
    )

    # Selectable returns the selectable element (document if element doesn't have querySelector).
    SELECTABLE = Function.new(
      name: "selectable",
      definition: "function(s){return s.querySelector?s:document}",
      dependencies: [] of Function
    )

    # Tag returns the element with a tagName (or its parent element).
    TAG = Function.new(
      name: "tag",
      definition: "function(e){return e.tagName?e:e.parentElement}",
      dependencies: [] of Function
    )

    # Element returns the first element matching the CSS selector.
    ELEMENT = Function.new(
      name: "element",
      definition: "function(e){return functions.selectable(this).querySelector(e)}",
      dependencies: [SELECTABLE]
    )

    # Elements returns all elements matching the CSS selector.
    ELEMENTS = Function.new(
      name: "elements",
      definition: "function(e){return functions.selectable(this).querySelectorAll(e)}",
      dependencies: [SELECTABLE]
    )

    # ElementX returns the first element matching the XPath expression.
    ELEMENT_X = Function.new(
      name: "elementX",
      definition: "function(e){var t=functions.selectable(this);return document.evaluate(e,t,null,XPathResult.FIRST_ORDERED_NODE_TYPE).singleNodeValue}",
      dependencies: [SELECTABLE]
    )

    # ElementsX returns all elements matching the XPath expression.
    ELEMENTS_X = Function.new(
      name: "elementsX",
      definition: "function(e){for(var t,n=functions.selectable(this),r=document.evaluate(e,n,null,XPathResult.ORDERED_NODE_ITERATOR_TYPE),i=[];t=r.iterateNext();)i.push(t);return i}",
      dependencies: [SELECTABLE]
    )

    # Text returns the text content of an element.
    TEXT = Function.new(
      name: "text",
      definition: "function(){switch(this.tagName){case\"INPUT\":case\"TEXTAREA\":return this.value||this.placeholder;case\"SELECT\":return Array.from(this.selectedOptions).map(e=>e.innerText).join();case void 0:return this.textContent;default:return this.innerText}}",
      dependencies: [] of Function
    )

    # ElementR returns the first element matching CSS selector whose text matches regex.
    ELEMENT_R = Function.new(
      name: "elementR",
      definition: "function(e,t){var n=t.match(/(/?)(.+)\\1([a-z]*)/i),r=n[3]&&!/^(?!.*?(.).*?\\1)[gmixXsuUAJ]+$/.test(n[3])?new RegExp(t):new RegExp(n[2],n[3]),t=functions.selectable(this),n=Array.from(t.querySelectorAll(e)).find(e=>r.test(functions.text.call(e)));return n||null}",
      dependencies: [SELECTABLE, TEXT]
    )

    # WaitLoad waits for the window or element to load.
    WAIT_LOAD = Function.new(
      name: "waitLoad",
      definition: "function(){const n=this===window;return new Promise((e,t)=>{if(n){if(\"complete\"===document.readyState)return e();window.addEventListener(\"load\",e)}else void 0===this.complete||this.complete?e():(this.addEventListener(\"load\",e),this.addEventListener(\"error\",t))})}",
      dependencies: [] of Function
    )

    # Visible checks if element is visible.
    VISIBLE = Function.new(
      name: "visible",
      definition: "function(){var e=functions.tag(this),t=e.getBoundingClientRect(),e=window.getComputedStyle(e);return\"none\"!==e.display&&\"hidden\"!==e.visibility&&!!(t.top||t.bottom||t.width||t.height)}",
      dependencies: [TAG]
    )

    # Invisible checks if element is invisible.
    INVISIBLE = Function.new(
      name: "invisible",
      definition: "function(){return!functions.visible.apply(this)}",
      dependencies: [VISIBLE]
    )

    # InputEvent dispatches input and change events.
    INPUT_EVENT = Function.new(
      name: "inputEvent",
      definition: "function(){this.dispatchEvent(new Event(\"input\",{bubbles:!0})),this.dispatchEvent(new Event(\"change\",{bubbles:!0}))}",
      dependencies: [] of Function
    )

    # ExposeFunc exposes a Go function to the page's window object.
    EXPOSE_FUNC = Function.new(
      name: "exposeFunc",
      definition: "function(e,t){let o=0;window[e]=e=>new Promise((n,r)=>{const i=t+\"_cb\"+o++;window[i]=(e,t)=>{delete window[i],t?r(t):n(e)},window[t](JSON.stringify({req:e,cb:i}))})}",
      dependencies: [] of Function
    )

    # Select selects/deselects options in a <select> element.
    SELECT = Function.new(
      name: "select",
      definition: "function(e,t,n){let r;switch(n){case\"regex\":r=e.map(e=>{const t=new RegExp(e);return e=>t.test(e.innerText)});break;case\"css-selector\":r=e.map(t=>e=>e.matches(t));break;default:r=e.map(t=>e=>e.innerText.includes(t))}const i=Array.from(this.options);let o=!1;return r.forEach(e=>{e=i.find(e);e&&(e.selected=t,o=!0)}),this.dispatchEvent(new Event(\"input\",{bubbles:!0})),this.dispatchEvent(new Event(\"change\",{bubbles:!0})),o}",
      dependencies: [] of Function
    )

    # GetXPath returns the XPath of the element.
    GET_XPATH = Function.new(
      name: "getXPath",
      definition: <<-'JS',
        function(e){class i{constructor(e,t){this.value=e,this.optimized=t||!1}toString(){return this.value}}function o(t){function n(e,t){return e===t||(e.nodeType===Node.ELEMENT_NODE&&t.nodeType===Node.ELEMENT_NODE?e.localName===t.localName:e.nodeType===t.nodeType||(e.nodeType===Node.CDATA_SECTION_NODE?Node.TEXT_NODE:e.nodeType)===(t.nodeType===Node.CDATA_SECTION_NODE?Node.TEXT_NODE:t.nodeType))}var e=t.parentNode,r=e?e.children:null;if(!r)return 0;let i;for(let e=0;e<r.length;++e)if(n(t,r[e])&&r[e]!==t){i=!0;break}if(!i)return 0;let o=1;for(let e=0;e<r.length;++e)if(n(t,r[e])){if(r[e]===t)return o;++o}return-1}if(this.nodeType===Node.DOCUMENT_NODE)return"/";var t=[];let n=this;for(;n;){var r=function(e,t){let n;var r=o(e);if(-1===r)return null;switch(e.nodeType){case Node.ELEMENT_NODE:if(t&&e.id)return new i(`//*[@id='${e.id}']`,!0);n=e.localName;break;case Node.ATTRIBUTE_NODE:n="@"+e.nodeName;break;case Node.TEXT_NODE:case Node.CDATA_SECTION_NODE:n="text()";break;case Node.PROCESSING_INSTRUCTION_NODE:n="processing-instruction()";break;case Node.COMMENT_NODE:n="comment()";break;default:Node.DOCUMENT_NODE;n=""}return 0<r&&(n+=`[${r}]`),new i(n,e.nodeType===Node.DOCUMENT_NODE)}(n,e);if(!r)break;if(t.push(r),r.optimized)break;n=n.parentNode}return t.reverse(),(t.length&&t[0].optimized?"":"/")+t.join("/")}
      JS
      dependencies: [] of Function
    )

    # ContainsElement checks if target is equal or inside the element.
    CONTAINS_ELEMENT = Function.new(
      name: "containsElement",
      definition: "function(e){for(var t=e;null!=t;){if(t===this)return!0;t=t.parentElement}return!1}",
      dependencies: [] of Function
    )

    # Additional helper functions can be added here as needed.
    # For now, include only the essential ones for query system.
  end
end
