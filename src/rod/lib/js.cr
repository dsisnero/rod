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

    # Additional helper functions can be added here as needed.
    # For now, include only the essential ones for query system.
  end
end
