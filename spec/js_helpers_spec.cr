require "./spec_helper"

describe Rod::JS do
  it "ports all go helper functions" do
    helpers = [
      Rod::JS::TRIGGER_FAVICON,
      Rod::JS::PARENTS,
      Rod::JS::CONTAINS_ELEMENT,
      Rod::JS::UPDATE_MOUSE_TRACER,
      Rod::JS::REMOVE_OVERLAY,
      Rod::JS::WAIT_IDLE,
      Rod::JS::WAIT_LOAD,
      Rod::JS::INPUT_EVENT,
      Rod::JS::INPUT_TIME,
      Rod::JS::INPUT_COLOR,
      Rod::JS::SELECT_TEXT,
      Rod::JS::SELECT_ALL_TEXT,
      Rod::JS::SELECT,
      Rod::JS::TEXT,
      Rod::JS::RESOURCE,
      Rod::JS::ADD_SCRIPT_TAG,
      Rod::JS::ADD_STYLE_TAG,
      Rod::JS::SELECTABLE,
      Rod::JS::TAG,
      Rod::JS::EXPOSE_FUNC,
      Rod::JS::GET_XPATH,
      Rod::JS::ELEMENT,
      Rod::JS::ELEMENTS,
      Rod::JS::ELEMENT_X,
      Rod::JS::ELEMENTS_X,
      Rod::JS::ELEMENT_R,
      Rod::JS::INIT_MOUSE_TRACER,
      Rod::JS::RECT,
      Rod::JS::OVERLAY,
      Rod::JS::ELEMENT_OVERLAY,
      Rod::JS::VISIBLE,
      Rod::JS::INVISIBLE,
    ]

    helpers.size.should eq(32)
    names = helpers.map(&.name)
    names.uniq.size.should eq(32)

    Rod::JS::ELEMENT_R.dependencies.map(&.name).should eq(["selectable", "text"])
    Rod::JS::OVERLAY.dependencies.map(&.name).should eq(["waitLoad"])
    Rod::JS::ELEMENT_R.definition.should contain("(\\/?)(.+)\\1([a-z]*)")
  end
end
