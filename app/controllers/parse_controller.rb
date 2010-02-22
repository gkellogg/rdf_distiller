class ParseController < ApplicationController
  def parse
    @uri = URI.parse(params[:uri]) rescue nil
    @uri = nil if @uri.to_s.empty?
    @content = params[:content] unless params[:content].to_s.empty?
    @content ||= begin
      sess = Patron::Session.new
      base_url = "#{@uri.scheme}://#{@uri.host}"
      base_url += ":#{@uri.port}" if @uri.port
      sess.base_url = base_url
      sess.timeout = 10
      resp = sess.get(@uri.path)
      raise RuntimeError, "HTTP returned status #{resp.status}" if resp.status >= 400
      resp.body
    rescue
      nil
    end
    @fmt = params[:fmt] || "nt"
    @in = params[:in] || "rdfa"
    @parser_debug = params[:debug] || false
    @strict = params[:strict] || false
    
    parser_opts = {:string => @strict, :debug => @parser_debug && []}
    
    @parser = case @in
    when "rdfxml" then RdfContext::RdfXmlParser.new
    when "n3"     then RdfContext::N3Parser.new
    else               RdfContext::RdfaParser.new
    end
    #$verbose = true
    @parser.parse(@content, (@uri || root_url).to_s, parser_opts)
    #$verbose = false

    respond_to do |format|
      format.html { render }
      format.any(:xml, :rdf) { render :xml => @parser.graph.to_rdfxml }
      format.any(:nt, :text) { render :text => @parser.graph.to_ntriples }
    end
  rescue RdfContext::RdfException
    @errors = "RdfException: #{$!.class}: #{$!}, errors:\n" + @errors.inspect
    logger.warn(@errors)
    respond_to do |format|
      format.html { render }
      format.any(:xml, :rdf) { render :xml => {:errors => @errors}.to_xml }
      format.any(:nt, :text) { render :text => @errors }
    end
  end
end
