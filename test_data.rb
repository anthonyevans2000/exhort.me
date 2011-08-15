require 'd_access.rb'
#
#Howboutdata.addevent(:genre, {:name=>'string', :attr1=>'bleh.....}
#
toggle = false
["selfimprovement", 'leisure', 'cultural','craft'].each do |g|
['name1', 'name2', 'name3'].each do |n|
['outdoor','indoor','either'].each do |a|
['easy','medium','hard'].each do |b|
['solitary','social'].each do |c|
['morning', 'evening'].each do |t|
['tuesday','thursday', 'sunday'].each do |d|

toggle = !toggle
if toggle 
  name = "MERCHANT"
  else
  name = "USER"
end
data = {
	:name=>"#{name}:#{g}:#{n}:#{a}:#{b}:#{c}:#{t}:#{d}",
	:environment=>a, 
	:difficulty=>b, 
	:sociality=>c, 
	:temporality=>"#{d}-#{t}", 
}
data[:merchant] = true if toggle
UserData.addevent(g.to_sym,data)
end
end
end
end
end
end
end
UserData.savedb
