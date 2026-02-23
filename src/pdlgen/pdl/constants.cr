module Pdlgen
  module Pdl
    # circular_deps is the list of types that can cause circular dependency issues.
    CIRCULAR_DEPS = {
      "browser.browsercontextid" => true,
      "dom.backendnodeid"        => true,
      "dom.backendnode"          => true,
      "dom.nodeid"               => true,
      "dom.node"                 => true,
      "dom.nodetype"             => true,
      "dom.pseudotype"           => true,
      "dom.rgba"                 => true,
      "dom.shadowroottype"       => true,
      "network.loaderid"         => true,
      "network.monotonictime"    => true,
      "network.timesinceepoch"   => true,
      "page.frameid"             => true,
      "page.frame"               => true,
    }

    # primitive_types is a map of primitive type names to their enum value.
    PRIMITIVE_TYPES = {
      "any"     => TypeEnum::Any,
      "array"   => TypeEnum::Array,
      "binary"  => TypeEnum::Binary,
      "boolean" => TypeEnum::Boolean,
      "integer" => TypeEnum::Integer,
      "number"  => TypeEnum::Number,
      "object"  => TypeEnum::Object,
      "string"  => TypeEnum::String,
    }

    # regexp's copied from pdl.py in the chromium source tree.
    DOMAIN_RE            = /^(experimental )?(deprecated )?domain (.*)/
    DEPENDS_RE           = /^  depends on ([^\s]+)/
    TYPE_RE              = /^  (experimental )?(deprecated )?type (.*) extends (array of )?([^\s]+)/
    COMMAND_EVENT_RE     = /^  (experimental )?(deprecated )?(command|event) (.*)/
    MEMBER_RE            = /^      (experimental )?(deprecated )?(optional )?(array of )?([^\s]+) ([^\s]+)/
    PARAMS_RETS_PROPS_RE = /^    (parameters|returns|properties)/
    ENUM_RE              = /^    enum/
    VERSION_RE           = /^version/
    MAJOR_RE             = /^  major (\d+)/
    MINOR_RE             = /^  minor (\d+)/
    INCLUDE_RE           = /^\s*include\s+(\S+)/
    REDIRECT_RE          = /^    redirect ([^\s]+)/
    REDIRECT_COMMENT_RE  = /^Use '([^']+)' instead$/
    ENUM_LITERAL_RE      = /^      (  )?[^\s]+$/

    def self.is_circular_dep(dtyp : String, typ : String) : Bool
      CIRCULAR_DEPS[{"#{dtyp.downcase}.#{typ.downcase}"}]? || false
    end
  end
end
