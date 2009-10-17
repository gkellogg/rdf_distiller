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
    end
    @fmt = params[:fmt] || "nt"
    
    @parser = RdfaParser::RdfaParser.new
    @parser.parse(@content, (@uri || root_url).to_s)
    @parser_debug = params[:debug]
    respond_to do |format|
      format.html { render }
      format.any(:xml, :rdf) { render :xml => @parser.graph.to_rdfxml }
      format.any(:nt, :text) { render :text => @parser.graph.to_ntriples }
    end
  rescue
    logger.warn(@errors.inspect)
    @errors = $!
    respond_to do |format|
      format.html { render }
      format.any(:xml, :rdf) { render :xml => {:errors => @errors}.to_xml, :status => :not_acceptable }
      format.any(:nt, :text) { render :text => @errors, :status => :not_acceptable }
    end
  end
end
