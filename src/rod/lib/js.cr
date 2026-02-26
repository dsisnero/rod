module Rod
  module JS
    # Function definition.
    struct Function
      getter name : String
      getter definition : String
      getter dependencies : Array(Function)

      def initialize(@name : String, @definition : String, @dependencies : Array(Function)? = nil)
        @dependencies = @dependencies || [] of Function
      end
    end

    # Functions root object for helper bindings.
    FUNCTIONS = Function.new(
      name: "functions",
      definition: "() => ({})",
      dependencies: nil
    )

    TRIGGER_FAVICON = Function.new(
      name: "triggerFavicon",
      definition: "function(){return new Promise((e,t)=>{var n=document.querySelector(\"link[rel~=icon]\"),n=n&&n.href||\"/favicon.ico\",n=new URL(n,window.location).toString();const r=new XMLHttpRequest;r.open(\"GET\",n),r.ontimeout=function(){t({errorType:\"timeout_error\",xhr:r})},r.onreadystatechange=function(){4===r.readyState&&(200<=r.status&&r.status<300||304===r.status?e({status:r.status,statusText:r.statusText,responseText:r.responseText}):t({errorType:\"status_error\",xhr:r,status:r.status,statusText:r.statusText,responseText:r.responseText}))},r.onerror=function(){t({errorType:\"onerror\",xhr:r,status:r.status,statusText:r.statusText,responseText:r.responseText})},r.send()})}",
      dependencies: [] of Function
    )

    PARENTS = Function.new(
      name: "parents",
      definition: "function(e){let t=this.parentElement;for(var n=[];t;)t.matches(e)&&n.push(t),t=t.parentElement;return n}",
      dependencies: [] of Function
    )

    CONTAINS_ELEMENT = Function.new(
      name: "containsElement",
      definition: "function(e){for(var t=e;null!=t;){if(t===this)return!0;t=t.parentElement}return!1}",
      dependencies: [] of Function
    )

    UPDATE_MOUSE_TRACER = Function.new(
      name: "updateMouseTracer",
      definition: "function(e,t,n){e=document.getElementById(e);return!!e&&(e.style.left=t-2+\"px\",e.style.top=n-3+\"px\",!0)}",
      dependencies: [] of Function
    )

    REMOVE_OVERLAY = Function.new(
      name: "removeOverlay",
      definition: "function(e){e=document.getElementById(e);e&&Element.prototype.remove.call(e)}",
      dependencies: [] of Function
    )

    WAIT_IDLE = Function.new(
      name: "waitIdle",
      definition: "function(t){return new Promise(e=>{window.requestIdleCallback(e,{timeout:t})})}",
      dependencies: [] of Function
    )

    WAIT_LOAD = Function.new(
      name: "waitLoad",
      definition: "function(){const n=this===window;return new Promise((e,t)=>{if(n){if(\"complete\"===document.readyState)return e();window.addEventListener(\"load\",e)}else void 0===this.complete||this.complete?e():(this.addEventListener(\"load\",e),this.addEventListener(\"error\",t))})}",
      dependencies: [] of Function
    )

    INPUT_EVENT = Function.new(
      name: "inputEvent",
      definition: "function(){this.dispatchEvent(new Event(\"input\",{bubbles:!0})),this.dispatchEvent(new Event(\"change\",{bubbles:!0}))}",
      dependencies: [] of Function
    )

    INPUT_TIME = Function.new(
      name: "inputTime",
      definition: "function(e){var e=new Date(e),t=e=>e.toString().padStart(2,\"0\"),n=e.getFullYear(),r=t(e.getMonth()+1),i=t(e.getDate()),o=t(e.getHours()),s=t(e.getMinutes());switch(this.type){case\"date\":this.value=n+`-${r}-`+i;break;case\"datetime-local\":this.value=n+`-${r}-${i}T${o}:`+s;break;case\"month\":this.value=n+\"-\"+r;break;case\"time\":this.value=o+\":\"+s}functions.inputEvent.call(this)}",
      dependencies: [INPUT_EVENT]
    )

    INPUT_COLOR = Function.new(
      name: "inputColor",
      definition: "function(e){this.value=\"\"+e,functions.inputEvent.call(this)}",
      dependencies: [INPUT_EVENT]
    )

    SELECT_TEXT = Function.new(
      name: "selectText",
      definition: "function(e){e=this.value.match(new RegExp(e));e&&this.setSelectionRange(e.index,e.index+e[0].length)}",
      dependencies: [] of Function
    )

    SELECT_ALL_TEXT = Function.new(
      name: "selectAllText",
      definition: "function(){this.select()}",
      dependencies: [] of Function
    )

    SELECT = Function.new(
      name: "select",
      definition: "function(e,t,n){let r;switch(n){case\"regex\":r=e.map(e=>{const t=new RegExp(e);return e=>t.test(e.innerText)});break;case\"css-selector\":r=e.map(t=>e=>e.matches(t));break;default:r=e.map(t=>e=>e.innerText.includes(t))}const i=Array.from(this.options);let o=!1;return r.forEach(e=>{e=i.find(e);e&&(e.selected=t,o=!0)}),this.dispatchEvent(new Event(\"input\",{bubbles:!0})),this.dispatchEvent(new Event(\"change\",{bubbles:!0})),o}",
      dependencies: [] of Function
    )

    TEXT = Function.new(
      name: "text",
      definition: "function(){switch(this.tagName){case\"INPUT\":case\"TEXTAREA\":return this.value||this.placeholder;case\"SELECT\":return Array.from(this.selectedOptions).map(e=>e.innerText).join();case void 0:return this.textContent;default:return this.innerText}}",
      dependencies: [] of Function
    )

    RESOURCE = Function.new(
      name: "resource",
      definition: "function(){return new Promise((e,t)=>{if(this.complete)return e(this.currentSrc);this.addEventListener(\"load\",()=>e(this.currentSrc)),this.addEventListener(\"error\",e=>t(e))})}",
      dependencies: [] of Function
    )

    ADD_SCRIPT_TAG = Function.new(
      name: "addScriptTag",
      definition: "function(r,i,o){if(!document.getElementById(r))return new Promise((e,t)=>{var n=document.createElement(\"script\");i?(n.src=i,n.onload=e):(n.type=\"text/javascript\",n.text=o,e()),n.id=r,n.onerror=t,document.head.appendChild(n)})}",
      dependencies: [] of Function
    )

    ADD_STYLE_TAG = Function.new(
      name: "addStyleTag",
      definition: "function(r,i,o){if(!document.getElementById(r))return new Promise((e,t)=>{var n;i?((n=document.createElement(\"link\")).rel=\"stylesheet\",n.href=i):((n=document.createElement(\"style\")).type=\"text/css\",n.appendChild(document.createTextNode(o)),e()),n.id=r,n.onload=e,n.onerror=t,document.head.appendChild(n)})}",
      dependencies: [] of Function
    )

    SELECTABLE = Function.new(
      name: "selectable",
      definition: "function(e){return e.querySelector?e:document}",
      dependencies: [] of Function
    )

    TAG = Function.new(
      name: "tag",
      definition: "function(e){return e.tagName?e:e.parentElement}",
      dependencies: [] of Function
    )

    EXPOSE_FUNC = Function.new(
      name: "exposeFunc",
      definition: "function(e,t){let o=0;window[e]=e=>new Promise((n,r)=>{const i=t+\"_cb\"+o++;window[i]=(e,t)=>{delete window[i],t?r(t):n(e)},window[t](JSON.stringify({req:e,cb:i}))})}",
      dependencies: [] of Function
    )

    GET_XPATH = Function.new(
      name: "getXPath",
      definition: "function(e){class i{constructor(e,t){this.value=e,this.optimized=t||!1}toString(){return this.value}}function o(t){function n(e,t){return e===t||(e.nodeType===Node.ELEMENT_NODE&&t.nodeType===Node.ELEMENT_NODE?e.localName===t.localName:e.nodeType===t.nodeType||(e.nodeType===Node.CDATA_SECTION_NODE?Node.TEXT_NODE:e.nodeType)===(t.nodeType===Node.CDATA_SECTION_NODE?Node.TEXT_NODE:t.nodeType))}var e=t.parentNode,r=e?e.children:null;if(!r)return 0;let i;for(let e=0;e<r.length;++e)if(n(t,r[e])&&r[e]!==t){i=!0;break}if(!i)return 0;let o=1;for(let e=0;e<r.length;++e)if(n(t,r[e])){if(r[e]===t)return o;++o}return-1}if(this.nodeType===Node.DOCUMENT_NODE)return\"/\";var t=[];let n=this;for(;n;){var r=function(e,t){let n;var r=o(e);if(-1===r)return null;switch(e.nodeType){case Node.ELEMENT_NODE:if(t&&e.id)return new i(`//*[@id='${e.id}']`,!0);n=e.localName;break;case Node.ATTRIBUTE_NODE:n=\"@\"+e.nodeName;break;case Node.TEXT_NODE:case Node.CDATA_SECTION_NODE:n=\"text()\";break;case Node.PROCESSING_INSTRUCTION_NODE:n=\"processing-instruction()\";break;case Node.COMMENT_NODE:n=\"comment()\";break;default:Node.DOCUMENT_NODE;n=\"\"}return 0<r&&(n+=`[${r}]`),new i(n,e.nodeType===Node.DOCUMENT_NODE)}(n,e);if(!r)break;if(t.push(r),r.optimized)break;n=n.parentNode}return t.reverse(),(t.length&&t[0].optimized?\"\":\"/\")+t.join(\"/\")}",
      dependencies: [] of Function
    )

    ELEMENT = Function.new(
      name: "element",
      definition: "function(e){return functions.selectable(this).querySelector(e)}",
      dependencies: [SELECTABLE]
    )

    ELEMENTS = Function.new(
      name: "elements",
      definition: "function(e){return functions.selectable(this).querySelectorAll(e)}",
      dependencies: [SELECTABLE]
    )

    ELEMENT_X = Function.new(
      name: "elementX",
      definition: "function(e){var t=functions.selectable(this);return document.evaluate(e,t,null,XPathResult.FIRST_ORDERED_NODE_TYPE).singleNodeValue}",
      dependencies: [SELECTABLE]
    )

    ELEMENTS_X = Function.new(
      name: "elementsX",
      definition: "function(e){for(var t,n=functions.selectable(this),r=document.evaluate(e,n,null,XPathResult.ORDERED_NODE_ITERATOR_TYPE),i=[];t=r.iterateNext();)i.push(t);return i}",
      dependencies: [SELECTABLE]
    )

    ELEMENT_R = Function.new(
      name: "elementR",
      definition: "function(e,t){var n=t.match(/(\\/?)(.+)\\1([a-z]*)/i),r=n[3]&&!/^(?!.*?(.).*?\\1)[gmixXsuUAJ]+$/.test(n[3])?new RegExp(t):new RegExp(n[2],n[3]),t=functions.selectable(this),n=Array.from(t.querySelectorAll(e)).find(e=>r.test(functions.text.call(e)));return n||null}",
      dependencies: [SELECTABLE, TEXT]
    )

    INIT_MOUSE_TRACER = Function.new(
      name: "initMouseTracer",
      definition: "async function(e,t){var n;await functions.waitLoad(),document.getElementById(e)||((n=document.createElement(\"div\")).innerHTML=t,(t=n.lastChild).id=e,t.style=\"position: absolute; z-index: 2147483647; width: 17px; pointer-events: none;\",t.removeAttribute(\"width\"),t.removeAttribute(\"height\"),document.body.parentElement.appendChild(t))}",
      dependencies: [WAIT_LOAD]
    )

    RECT = Function.new(
      name: "rect",
      definition: "function(){var e=functions.tag(this).getBoundingClientRect();return{x:e.x,y:e.y,width:e.width,height:e.height}}",
      dependencies: [TAG]
    )

    OVERLAY = Function.new(
      name: "overlay",
      definition: "async function(e,t,n,r,i,o){await functions.waitLoad();var s=document.createElement(\"div\");s.id=e,s.style=`position: fixed; z-index:2147483647; border: 2px dashed red;\n        border-radius: 3px; box-shadow: #5f3232 0 0 3px; pointer-events: none;\n        box-sizing: border-box;\n        left: ${t}px;\n        top: ${n}px;\n        height: ${i}px;\n        width: ${r}px;`,r*i==0&&(s.style.border=\"none\"),o?((e=document.createElement(\"div\")).style=`position: absolute; color: #cc26d6; font-size: 12px; background: #ffffffeb;\n        box-shadow: #333 0 0 3px; padding: 2px 5px; border-radius: 3px; white-space: nowrap;\n        top: ${i}px;`,e.innerHTML=o,s.appendChild(e),document.body.parentElement.appendChild(s),window.innerHeight<e.offsetHeight+n+i&&(e.style.top=-e.offsetHeight-2+\"px\"),window.innerWidth<e.offsetWidth+t&&(e.style.left=window.innerWidth-e.offsetWidth-t+\"px\")):document.body.parentElement.appendChild(s)}",
      dependencies: [WAIT_LOAD]
    )

    ELEMENT_OVERLAY = Function.new(
      name: "elementOverlay",
      definition: "async function(n,e){const r=100,i=functions.tag(this);let o=i.getBoundingClientRect();await functions.overlay(n,o.left,o.top,o.width,o.height,e);const s=()=>{var e,t=document.getElementById(n);null!==t&&(e=i.getBoundingClientRect(),o.left===e.left&&o.top===e.top&&o.width===e.width&&o.height===e.height||(t.style.left=e.left+\"px\",t.style.top=e.top+\"px\",t.style.width=e.width+\"px\",t.style.height=e.height+\"px\",o=e),setTimeout(s,r))};setTimeout(s,r)}",
      dependencies: [TAG, OVERLAY]
    )

    VISIBLE = Function.new(
      name: "visible",
      definition: "function(){var e=functions.tag(this),t=e.getBoundingClientRect(),e=window.getComputedStyle(e);return\"none\"!==e.display&&\"hidden\"!==e.visibility&&!!(t.top||t.bottom||t.width||t.height)}",
      dependencies: [TAG]
    )

    INVISIBLE = Function.new(
      name: "invisible",
      definition: "function(){return!functions.visible.apply(this)}",
      dependencies: [VISIBLE]
    )
  end
end
