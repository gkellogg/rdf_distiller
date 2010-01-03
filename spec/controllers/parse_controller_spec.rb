require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ParseController do
  before(:each) do
    @mock_parser = mock("rdfa-parser")
    @graph = mock("graph")
    @graph.stub(:to_ntriples).and_return("triples")
    @graph.stub(:to_rdfxml).and_return("rdfxml")
    @mock_parser.stub(:parse).and_return(@graph)
    @mock_parser.stub(:graph).and_return(@graph)
    RdfContext::RdfaParser.stub!(:new).and_return(@mock_parser)
    
    resp = mock("resp")
    resp.stub(:status).and_return(200)
    resp.stub(:body).and_return("HTML+RDFa document")
    sess = mock("session")
    sess.stub(:base_url=)
    sess.stub(:timeout=)
    sess.stub(:get).and_return(resp)
    Patron::Session.stub!(:new).and_return(sess)
  end
  
  def do_parse(options = {})
    options.reverse_merge(:accept => "text/html")
    request.accept = options.delete(:accept)
    get :parse, {:uri => "http://source"}.merge(options)
    
    response.should be_success, response.status
    assigns(:parser).should == @mock_parser
  end
  
  it "should run parser" do
    RdfContext::RdfaParser.should_receive(:new)
    do_parse
  end
  
  it "should parse URI" do
    RdfContext::RdfaParser.should_receive(:new)
    do_parse
  end
  
  it "should parse form and render view" do
    do_parse
    response.should render_template(:parse)
  end
  
  it "should parse uri and generate triples with accept" do
    @graph.should_receive(:to_ntriples)
    do_parse(:accept => "text/plain")
    #do_parse(:format => "nt")
  end

  it "should parse uri and generate xml with format" do
    @graph.should_receive(:to_rdfxml)
    do_parse(:format => "xml")
  end

  it "should parse uri and generate triples with format" do
    @graph.should_receive(:to_ntriples)
    do_parse(:format => "nt")
  end
end
