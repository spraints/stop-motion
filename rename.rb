n = 1
ARGV.each do |filename|
  dir = File.dirname filename
  newname = File.join dir, ('%03d.jpg' % n)
  puts "mv #{filename} #{newname}"
  File.rename filename, newname
  n = n.succ
end
