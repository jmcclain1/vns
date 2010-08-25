require "#{File.dirname(__FILE__)}/benchmarking_helper"
include Pivotal::Benchmarking

class Pivotal::RailsTestCase  
  cattr_reader :benchmark_stats
  
  def run(*args, &progress)
    seconds = Benchmark.realtime { super(*args, &progress) }
    @@benchmark_stats ||= []
    @@benchmark_stats << Stat.new(seconds, self.class.to_s, @method_name)
  end
end

at_exit do
  unless $! || Test::Unit.run?
    Test::Unit::AutoRunner.run    
    print_benchmarking_report(Pivotal::RailsTestCase.benchmark_stats)
  end
end