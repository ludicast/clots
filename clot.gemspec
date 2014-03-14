require 'rake'

Gem::Specification.new do |s|
  s.name        = 'clot'
  s.summary     = "Clot"
  s.authors     = ["Jim Gilliam"]
  s.version     = "1.2"
  s.files       = FileList["lib/**/*.rb"].to_a
end
