hanami_routes = lambda do |f, level, prefix, calc_path, lvars|
  base = BASE_ROUTE.dup
  ROUTES_PER_LEVEL.times do
    if level == 1
      f.puts "  get '#{prefix}#{base}/:#{lvars.last}', to: ->(env) {"
      f.puts "    body = \"#{RESULT.call(calc_path[1..-1] + base)}#{lvars.map{|lvar| "-\#{env['router.params'][:#{lvar}]}"}.join}\""
      f.puts "    [200, {'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s}, body]"
      f.puts "  }"
    else
      hanami_routes.call(f, level-1, "#{prefix}#{base}/:#{lvars.last}/", "#{calc_path}#{base}/", lvars + [lvars.last.succ])
    end
    base.succ!
  end
end

File.open("#{File.dirname(__FILE__)}/../apps/hanami-router_#{LEVELS}_#{ROUTES_PER_LEVEL}.rb", 'wb') do |f|
  f.puts "# frozen_string_literal: true"
  f.puts "require 'hanami/router'"
  f.puts "App = Hanami::Router.new do"
  hanami_routes.call(f, LEVELS, '/', '/', ['a'])
  f.puts "end"
end
