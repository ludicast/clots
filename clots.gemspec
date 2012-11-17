require 'rake'

Gem::Specification.new do |s|
  s.name        = 'clots'
  s.summary     = "Clots for nbuild"
  s.authors     = ["Jim Gilliam"]
  s.version     = "1"
  s.files       = FileList["init.rb", "lib/**/*.rb"].to_a
end
