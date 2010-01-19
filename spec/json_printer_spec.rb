require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "JsonPrinter" do
  describe ".render" do
    it "should raise an error for invalid objects" do
      lambda {
        JsonPrinter.render(Object.new)
      }.should raise_error
    end
    
    it "should render nil with null" do
      JsonPrinter.render(nil).should == %{null}
    end
    
    it "should render true with true" do
      JsonPrinter.render(true).should == %{true}
    end
    
    it "should render false with false" do
      JsonPrinter.render(false).should == %{false}
    end
          
    it "should render JSON-escaped strings" do
      JsonPrinter.render(%{foo&}).should == %{"foo\\u0026"}
    end
    
    it "should render symbols as strings" do
      JsonPrinter.render(:foo).should == %{"foo"}
    end
    
    it "should render numbers" do
      JsonPrinter.render(7).should == %{7}
    end
    
    it "should render times" do
      t = Time.at(946702800).utc
      JsonPrinter.render(t).should == "Sat Jan 01 05:00:00 UTC 2000"
    end
    
    it "should render arrays" do
      JsonPrinter.render([:foo, :bar, :bat]).should ==
        %{["foo",\n} <<
        %{ "bar",\n} <<
        %{ "bat"]}
    end
    
    it "should render arrays with repeated values" do
      JsonPrinter.render([:foo, :bar, :foo]).should ==
        %{["foo",\n} <<
        %{ "bar",\n} <<
        %{ "foo"]}
    end
    
    # TODO: would be nice to spec the actual output formatting
    
    it "should render hashes" do
      d = {"foo" => "bar", "biz" => "bat", "bing" => "bong"}
      JSON.parse(JsonPrinter.render(d)).should == d
    end
    
    it "should render hashes with repeated values" do
      d = {"foo" => "bar", "biz" => "bar", "bing" => "bar"}
      JSON.parse(JsonPrinter.render(d)).should == d
    end
    
    describe "on compound data structures" do
      before :each do 
        @d = 
          ["foo",
           "bar",
           ["biz",
            "bang",
            {"biz" => "bat",
             "bang" => "yang"},
            "zoo"],
           "bat",
           {"bang" => "str",
            "comp" =>
              ["foo",
               "bar",
               "bat"],
            "hash" =>
              {"from" => "to",
               "next" => "best"}},
           "fin",
           "end"]
      end
      
      it "should render" do
        JSON.parse(JsonPrinter.render(@d)).should == @d
      end
    end
  end
end