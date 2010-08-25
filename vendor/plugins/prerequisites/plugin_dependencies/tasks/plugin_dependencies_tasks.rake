# rule(/.*/ => [proc {|task_name| 'execute_plugin_task'}])
task :execute_plugin_task => :environment do
  Rake::Task[$*.first].execute
end