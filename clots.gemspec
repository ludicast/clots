require 'rake'

Gem::Specification.new do |s|
  s.name        = 'clot'
  s.summary     = "Clots"
  s.authors     = ["Jim Gilliam"]
  s.version     = "1.1"
  s.files       = FileList["lib/**/*.rb"].to_a
end
