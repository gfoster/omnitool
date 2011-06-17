# This defines a setup hook that will be called within the constructor.
# You can use this to setup any ivars and such you might want down the road

# You can have multiple of these

setup do
    puts "in the initialize method"
    @blah = "la dee da"
end

setup do
    puts "still in the constructor"
    puts "@blah = #{@blah}"
end

# and here's our commands.  They will automagically show up in any help listings
# as well
command :foo, "help text for the foo command" do
    puts "in the foo method, @blah = #{@blah}"
    help
end

option :s, :switch => true, :description => "a simple switch"

option :m, :medium

option :l, :long, :description => "a long switch with a block" do
	"blah blah"
end


