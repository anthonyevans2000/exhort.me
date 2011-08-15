require 'rubygems'
require 'sinatra'
require 'yaml'
require 'haml'
require 'd_access.rb'
require 'pp'
begin 
#####################################################################################
#
#Sinatra webpage serving file- Written by Mark Fabbro.
#
#####################################################################################


#
# Create Our Static Single User
#
#
  $singleuser = UserProfile.new('DavidBowie', 
                                  [:leisure, :craft],
                                  {:difficulty => ['hard'],
                                   :sociality  => ['social']},
                                  { :monday    => ['morning', 'afternoon', 'evening'],
                                    :tuesday   => ['afternoon', 'evening'],
                                    :wednesday => ['evening'],
                                  }
                                )
#-----------------------------------------------------------------


#Class Userdata has self.loaddb- which calls YAML::load_file('') on userdb.yaml
  UserData.loaddb
rescue Exception
  puts "Unable to load database" 
end


#Class ExhortData has the hash maps of @@data and @@ attr-  respectively the genres and
#event-specific attributes of an 'event' item.

get '/' do
  output = '' #Required to enable data operations
  ## Input equates to the cat of the genrelist and attrlist, perfect for printing into
  #haml markup for selection of attributes.
  @input  = UserData.genrelist
  @input += UserData.attrlist

# This serves the /views/index.haml file to the user, output is read into the file.
  output << haml(:index)
  return output
end

post '/Generate' do
  genres     = []
  attributes = {}
  @params.keys.each do |k|
    case (a=k.split('/')).length
    when 1: genres << a[0].to_sym
    when 2 
        attributes[a[0].to_sym] ||= []
        attributes[a[0].to_sym] << a[1]
    else raise "Recieved an attribute that had more than one slash"
    end
  end
  @eventlist = UserData.events_by_attr(genres, attributes)
  puts "JUST AFTER EVENTS_BY_ATTR", @eventlist
  haml :listoutput
end

get '/users/*' do
  #Users' Page. Attempt to print users stuff
  o = []
  if params[:splat][0] == "DavidBowie"
    genre      = $singleuser.genre
    attr       = $singleuser.interests.merge $singleuser.timetable
    @eventlist = UserData.events_by_attr(genre, attr)
    o << "Bowie Dump: #{$singleuser.genre} #{$singleuser.interests} #{$singleuser.timetable}"
    o << haml(:listoutput)
  end
end

get '/products/*/*' do
#  UserData.registered_products(params[:splat][0], params[:splat][1])
#  haml   
end

#
# At this moment redirect any urls that aren't captured to the main page.
#
not_found do 
  redirect '/'
end





