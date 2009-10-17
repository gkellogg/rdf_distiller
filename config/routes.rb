ActionController::Routing::Routes.draw do |map|
  # Default route goes to manifests
  map.root :controller => 'parse', :action => "parse"
  map.index ':format', :controller => 'parse', :action => "parse"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
