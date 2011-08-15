#
# This file includes the classes that interact with the database.
#
#

require 'yaml'
require 'pp'

=begin
class MerchantData << ExhortData
  def self.loaddb
    @@users = 
    @@data  = YAML::load_file('productdb.yaml')
  end

  def self.savedb
    File.open("productdb.yaml", "w+") do |f|
      f.print YAML::dump(@@data)
    end
  end
end
=end

MERCHANT_PERCENT = 0.3

class ExhortData
#
# @data a hash map of all genres mapped to all events
#

  @@data = { :selfimprovement => [],
             :leisure         => [], 
             :cultural        => [], 
             :craft           => [], 
           }
  @@attr = {:environment  => ['outdoor', 'indoor',    'either'  ],
            :difficulty   => ['easy',    'medium',    'hard'    ],
            :temporality  => ['monday-morning', 'sunday-afternoon', 'tuesday-evening' ],
            :sociality    => ['social',  'solitary'],
           }


  def self.loaddb
    @@data = YAML::load_file('db.yaml')
  end

  def self.savedb
    File.open("db.yaml", "w+") do |f|
      f.print YAML::dump(@@data)
    end
  end

# addevent method
# genre      -> ['genre1', 'genre2']
# event_info -> {:name => blah', :attrx=>'rzsing'}
#
  def self.addevent(genre, event_info)
    if @@data.has_key? genre
      @@data[genre] << event_info
      return true
    else
      puts "An event was trying to be added to a invalid genre"
      return false
    end
  end

#
# Returns an array of the genres
#
  def self.genrelist
    o = []
    @@data.each_key{|k| o << k.to_s}
    return o
  end


#
# Returns an array of the accepted attribytes
#
  def self.attrlist
    o = []
    @@attr.each_pair{|h,v| v.each {|s| o << "#{h}/#{s}"}}
    return o
  end


#
# events_by_genre returns an array of all the events that match
# a particular genrelist
#
  def self.events_by_genre(genrelist)
    o = []
    @@data.each_pair do |k,v|
      if genrelist.include? k.to_s
        v.each{|event| o << event[:name] if event[:name] } 
      end
    end
    return o
  end

#
# events_by_attr returns an array of all the events that match
# a particular genrelist and attrlist
#
# attrlist  = {:difficulty->['hard', 'medium']}
# genrelist = ['cultural', 'leisure']

  def self.events_by_attr(genrelist, attrlist, listsize=20)
    o = []
    m = []
    @@data.each_pair do |gen, evlist|
      if genrelist.include? gen
        evlist.each do |ev|
          check = true
          attrlist.each_pair {|aname, a_array| check = false unless a_array.include? ev[aname]}
          if check
            pp "CHECK PASSED", ev[:merchant]
            case ev[:merchant]
            when true:       m << ev[:name]
            when false, nil: o << ev[:name]
            end
          end
        end
      end
    end
    randout = ExhortData.distribute(m, o, listsize)
    return randout
  end

  def self.distribute(merchant, user, number=20)
    o = []
    pp "merchant", merchant, 'user', user
    totmerch = (number*MERCHANT_PERCENT).ceil
    totmerch.times do |i|
      x = rand(merchant.length).round
      o << merchant[x] if merchant[x]
    end
    pp "NUMBER", (number-o.length)
    (number-o.length).times do |i|
      x = rand(user.length).round
      o << user[x] if user[x] 
    end
    pp 'OOOOO', o
    return o
  end
end

class UserData < ExhortData
  def self.loaddb
    @@data = YAML::load_file('userdb.yaml')
  end

  def self.savedb
    File.open("userdb.yaml", "w+") do |f|
      f.print YAML::dump(@@data)
    end
  end

end

class UserProfile
  attr_accessor :name, :genre, :interests
  def initialize(name, genre, interests, timetable)
    @name      = name
    @genre     = genre
    @interests = interests
    @timetable = timetable
  end
  def timetable
    o = []
    @timetable.each_pair do |day,tod|
      tod.each {|x| o << "#{day}-#{x}"}
    end
    return {:temporality=>o}
  end
end

class MerchantProfile
  attr_reader :product_info
  def initialize(name)
    @merchantid   = ''
    @product_info = {}
  end

  def addproduct(name, genre, interests, additional_info)
      @product_info[name] = additional_info
      interests[:merchant=>true]
      UserData.addevent(genre, interests)
  end
end























