#!/usr/bin/ruby
# untitled.rb

# Created by Paolo Bosetti on 2011-09-02.
# Copyright (c) 2011 University of Trento. All rights reserved.

require "socket"

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
    
    def <<(str)
      UDPSocket.open.send(str, 0, @host, port)
      sleep @delay
    end
    
    def clear
      UDPSocket.open.send("CLEAR", 0, @host, port)
    end
    
    def close
      UDPSocket.open.send("CLOSE", 0, @host, port)     
    end

    def names(ary)
      UDPSocket.open.send("NAMES " + (ary * " "), 0, @host, port)     
    end
  
  end
end


if __FILE__ == $0
  ch = Charter::Client.new(1)
  ch.clear
  500.times do |i|
    #ch << "m #{(i)/10.0},#{rand} #{(i)/10.0+rand*0.01}},#{rand}"
    ch << "s #{(i)/10.0} #{Math::sin(i/10.0)} #{1.1*Math::cos(i/10.0)} #{0.7*Math::sin(i/10.0)+rand*0.05}"
  end
  ch.names %w|speed velocity acceleration|
  #ch.close
end