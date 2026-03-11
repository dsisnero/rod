require "./spec_helper"

private class PoolBrowserStub < Rod::Browser
  getter id : String
  getter? closed = false

  def initialize(@id : String)
    super()
  end

  def close : Nil
    @closed = true
  end
end

private class PoolPageStub < Rod::Page
  getter id : String
  getter? closed = false

  def initialize(@id : String)
    super(Rod::Browser.new, Rod::TargetID.new("target-#{id}"))
  end

  def close : Nil
    @closed = true
  end
end

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

  it "supports browser pool get/put/must_get/cleanup parity" do
    pool = Rod.new_browser_pool(3)
    created = 0

    first, err = pool.get do
      created += 1
      {PoolBrowserStub.new("b#{created}"), nil}
    end
    err.should be_nil
    first.should_not be_nil
    first.not_nil!.as(PoolBrowserStub).id.should eq("b1")

    pool.put(first)

    fetched, err2 = pool.get do
      created += 1
      {PoolBrowserStub.new("b#{created}"), nil}
    end
    err2.should be_nil
    fetched.should_not be_nil
    created.should eq(2)

    from_must_get = pool.must_get do
      created += 1
      PoolBrowserStub.new("b#{created}")
    end
    from_must_get.as(PoolBrowserStub).id.should eq("b3")

    pool.put(fetched)
    pool.put(from_must_get)

    cleaned = [] of String
    pool.cleanup do |b|
      b.close
      cleaned << b.as(PoolBrowserStub).id
    end

    cleaned.sort.should eq(["b1", "b2", "b3"])
  end

  it "supports page pool get/put/must_get/cleanup parity" do
    pool = Rod.new_page_pool(3)
    created = 0

    first, err = pool.get do
      created += 1
      {PoolPageStub.new("p#{created}"), nil}
    end
    err.should be_nil
    first.should_not be_nil
    first.not_nil!.as(PoolPageStub).id.should eq("p1")

    pool.put(first)

    fetched, err2 = pool.get do
      created += 1
      {PoolPageStub.new("p#{created}"), nil}
    end
    err2.should be_nil
    fetched.should_not be_nil
    created.should eq(2)

    from_must_get = pool.must_get do
      created += 1
      PoolPageStub.new("p#{created}")
    end
    from_must_get.as(PoolPageStub).id.should eq("p3")

    pool.put(fetched)
    pool.put(from_must_get)

    cleaned = [] of String
    pool.cleanup do |p|
      p.close
      cleaned << p.as(PoolPageStub).id
    end

    cleaned.sort.should eq(["p1", "p2", "p3"])
  end
end
