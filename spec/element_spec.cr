require "./spec_helper"

describe Rod::Element do
  # TODO: Add proper mocking for Page and CDP calls
  # For now, mark specs as pending

  describe "#matches" do
    pending "checks if element matches CSS selector"
  end

  describe "#contains_element" do
    pending "checks if target is equal or inside element"
  end

  describe "#describe" do
    pending "returns DOM node description"
  end

  describe "#shadow_root" do
    pending "returns shadow root element"
    pending "raises NoShadowRootError when no shadow root"
  end

  describe "#frame" do
    pending "returns Page for iframe element"
    pending "returns nil for non-iframe element"
  end

  describe "#element" do
    pending "finds single child element by CSS selector"
    pending "raises NotFoundError when element not found"
  end

  describe "#elements" do
    pending "finds all child elements matching CSS selector"
    pending "returns empty Elements when none found"
  end

  describe "#element_x" do
    pending "finds single child element by XPath selector"
    pending "raises NotFoundError when element not found"
  end

  describe "#element_r" do
    pending "finds single child element by CSS selector with regex text"
    pending "raises NotFoundError when element not found"
  end
end
