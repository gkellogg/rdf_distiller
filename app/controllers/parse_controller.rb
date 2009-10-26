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
    @parser_debug = params[:debug] || false
    
    @parser = RdfaParser::RdfaParser.new
    @parser.parse(@content, (@uri || root_url).to_s)
    respond_to do |format|
      format.html { render }
      format.any(:xml, :rdf) { render :xml => @parser.graph.to_rdfxml }
      format.any(:nt, :text) { render :text => @parser.graph.to_ntriples }
    end
  rescue RdfaParser::RdfException
    @errors = "RdfException: #{$!.class}: #{$!}, errors:\n" + @errors.inspect
    logger.warn(@errors)
    respond_to do |format|
      format.html { render }
      format.any(:xml, :rdf) { render :xml => {:errors => @errors}.to_xml }
      format.any(:nt, :text) { render :text => @errors }
    end
  end
end
