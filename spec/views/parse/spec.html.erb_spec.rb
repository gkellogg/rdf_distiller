require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
describe "parse/parse.html.erb" do
  before(:each) do
    @graph = mock("graph")
    
    @parser = mock("parser")
    @parser.stub(:graph).and_return(@graph)
    @parser.stub(:debug).and_return(["Display this debug information"])
    assigns[:serializer_options] = {}
  end
  
  it "should display errors" do
    assigns[:errors] = "Display these errors"
    render "parse/parse.html.erb"
    response.should contain(assigns[:errors])
  end
  
  it "should display debug" do
    assigns[:parser_debug] = true
    assigns[:parser] = @parser
    assigns[:serializer_opts] = {:format => "xml"}
    @graph.should_receive(:serialize).with(assigns[:serializer_opts]).and_return("RDF/XML")
    render "parse/parse.html.erb"
    response.should contain("Display this debug information")
  end
  
  it "should display content" do
    assigns[:content] ="Display this Content"
    @graph.should_not_receive(:serialize)
    render "parse/parse.html.erb"
    response.should contain(assigns[:content])
  end
  
  it "should render triples" do
    assigns[:parser] = @parser
    assigns[:serializer_opts] = {:format => "nt"}
    @graph.should_receive(:serialize).with(assigns[:serializer_opts]).and_return("N-Triples")
    render "parse/parse.html.erb"
    response.should contain("N-Triples")
  end
  
  it "should render rdfxml" do
    assigns[:parser] = @parser
    assigns[:serializer_options] = {:format => "xml"}
    assigns[:serializer_opts] = {:format => "xml"}
    @graph.should_receive(:serialize).with(assigns[:serializer_opts]).and_return("RDF/XML")
    render "parse/parse.html.erb"
    response.should contain("RDF/XML")
  end
end