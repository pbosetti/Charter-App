//
//  main.m
//  Testing
//
//  Created by Paolo Bosetti on 8/4/11.
//  Copyright 2011 Dipartimento di Ingegneria Meccanica e Strutturale. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
  return macruby_main("rb_main.rb", argc, argv);
}
