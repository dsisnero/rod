require "./spec_helper"

describe Rod do
  it "creates and reuses values in a pool" do
    pool = Rod::Pool(String).new(1)
    created = 0

    first, err = pool.get do
      created += 1
      {"v1", nil}
    end

    err.should be_nil
    first.should eq("v1")

    pool.put(first)

    second, err2 = pool.get do
      created += 1
      {"v2", nil}
    end

    err2.should be_nil
    second.should eq("v1")
    created.should eq(1)
  end

  it "supports must_get helper" do
    pool = Rod::Pool(String).new(1)
    created = 0

    value = pool.must_get do
      created += 1
      "x"
    end

    value.should eq("x")
    created.should eq(1)
  end

  it "cleans up pooled values" do
    pool = Rod::Pool(String).new(2)
    _, _ = pool.get { {"a", nil} }
    _, _ = pool.get { {"b", nil} }
    pool.put("a")
    pool.put("b")

    cleaned = [] of String
    pool.cleanup { |v| cleaned << v }

    cleaned.sort.should eq(["a", "b"])
  end
end
