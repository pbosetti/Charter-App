#!/usr/bin/ruby
# charter_client.rb

# Created by Paolo Bosetti on 2011-09-02.
# Copyright (c) 2011 University of Trento. All rights reserved.

require "socket"

# Copy and paste this module in your script, or just require this file
module Charter
  BASE_PORT = 2000
  
  attr_accessor :delay
  
  class Client
    def initialize(id, host='localhost')
      @id = id
      @host = host
      @delay = 0.005
    end
    
    def port; @id + BASE_PORT; end
    
    def <<(ary)
      str = String.new
      if ary[0].kind_of? Numeric
        str = "s " + ary * " "
      elsif ary[0].kind_of? Array
        str = "m "
        ary.each {|c| str += "#{c[0]},#{c[1]} "}
      else 
        raise ArgumentError, "Wrong data format in #{ary.inspect}"
      end
      deliver(str)
      sleep @delay
    end
    
    def clear; deliver("CLEAR"); end
    
    def close; deliver("CLOSE"); end

    def names(ary); deliver("NAMES " + (ary * " ")); end
    
    def deliver(message)
      raise ArgumentError, "need a String, got #{message.class}" unless message.respond_to? :to_s
      UDPSocket.open.send(message.to_s, 0, @host, port)
    end
  end
end

# Run this file to plot an example chart
if __FILE__ == $0
  # Instantiate a connection with the app
  ch = Charter::Client.new(1)
  
  # This clears the app buffer and starts a new plot
  ch.clear
  
  200.times do |i|
    # Add a point to each of the 3 series, with common abscissa
    ch << [i/10.0, Math::sin(i/10.0), 1.1*Math::cos(i/10.0), 0.7*Math::sin(i/10.0)+rand*0.05]
    
    # Alternatively, add a point to each series, also specifying different abscissa values
    #ch << [ [i/10.0, rand], [i/10.0+rand*0.01, rand] ]
  end
  
  # Set the names for the series. Names array should have the same number of elements as the chart series
  ch.names %w|speed velocity acceleration|
  
  # Optionally, you could close the connection (i.e. remotely switch the "I O" rocker in the app toolbar to "O")
  #ch.close
end