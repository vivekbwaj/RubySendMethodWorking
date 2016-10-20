#
# http://makandracards.com/makandra/18905-how-to-not-repeat-yourself-in-cucumber-scenarios
# Many_steps is a drop-in replacement for Cucumber's steps helper. It does everything that steps does, but gives you meaningful stack traces in case something goes wrong.
# To use this helper, copy the file to features/support. Now you can simply call many_steps instead of steps:
# When /^I search for "(.+?)"$/ do |query|
#   many_steps %{
#    When I go to the search form
#    And I fill in "Query" with "#{query}"
#    And I press "Search"
#  }
# end
# If the second line is undefined or fails, the stack trace will point to the correct file and line number.
#

class StepRunner

  def initialize(world, code, file, line_number)
    @world = world
    @code = code
    @file = file
    @line_number = line_number
  end

  def run
    split_lines
    group = []
    @lines.each do |line|
      if new_group?(line)
        execute_group(group)
        group = []
      end
      group << line unless line =~ /\s*#/
      @line_number += 1
    end
    execute_group(group) # the last group
  end

  private

  def new_group?(line)
    line =~ /^\s*(Given|When|Then|And) /
  end

  def execute_group(group)
    if valid_group?(group)
      code = group.join("\n") + "\n"
      begin
        @world.steps(code)
      rescue Exception => e
        inject_location(e)
        raise e
      end
    end
  end

  def inject_location(e)
    e.backtrace.unshift("#{@file}:#{@line_number}:in many_steps")
  end

  def valid_group?(group)
    group.collect(&:strip).any?(&:present?)
  end

  def split_lines
    @lines = @code.split(/\n/)
  end

  module Harness

    def many_steps(code, file = nil, line_number = nil)
      if file.nil?
        pos = caller(1)[0]
        pos =~ /^([^:]+)\:(\d+)/
        file = $1
        line_number = $2.to_i if $2
      end
      if file.nil? || line_number.nil?
        raise "Could not detect file and line number. Fix me or call with __FILE__ and __LINE__ arguments."
      end
      StepRunner.new(self, code, file, line_number).run
    end

  end

end

World(StepRunner::Harness)
