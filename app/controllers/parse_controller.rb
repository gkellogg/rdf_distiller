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
    @base = params[:base]
    @max_depth = params[:max_depth]
    @attributes = params[:attributes]
    @lang = params[:lang]
    
    parser_opts = {:strict => @strict, :debug => @parser_debug && []}
    @serializer_opts = {:format => @fmt}.merge(params.slice(:base, :lang, :depth, :attributes)).symbolize_keys
    
    @parser = case @in
    when "rdfxml", "rdf", "xml" then RdfContext::RdfXmlParser.new
    when "n3", "ttl"            then RdfContext::N3Parser.new
    when "html", "rdfa"         then RdfContext::RdfaParser.new
    else                             RdfContext::Parser.new
    end
    #$verbose = true
    @parser.parse(@content, (@uri || root_url).to_s, parser_opts)
    #$verbose = false

    respond_to do |format|
      format.html { render }
      format.any(:xml, :rdf) { render :xml => @parser.graph.serialize(@serializer_opts.merge(:format => "xml")) }
      format.any(:nt, :text) { render :text => @parser.graph.serialize(@serializer_opts.merge(:format => "nt")) }
      format.any(:n3, :ttl) { render :text => @parser.graph.serialize(@serializer_opts.merge(:format => "ttl")) }
    end
  rescue
    @errors = "RdfException: #{$!.class}: #{$!}, errors:\n" + @errors.inspect
    logger.warn(@errors)
    respond_to do |format|
      format.html { render }
      format.any(:xml, :rdf) { render :xml => {:errors => @errors}.to_xml }
      format.any(:nt, :text) { render :text => @errors }
    end
  end
end
