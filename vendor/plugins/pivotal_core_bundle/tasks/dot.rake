# dot.rake
# Creates a DOT format file showing the model objects and their associations
# Authors:
#   Matt Biddulph - http://www.hackdiary.com/archives/000093.html
#   Alex Chaffee - http://www.pivotalblabs.com/articles/2007/09/29/dot-rake
#   David Vrensk - david@vrensk.com
# Usage:
#  rake dot
#  To open in OmniGraffle, run
#    open -a 'OmniGraffle' model.dot
#  or
#    open -a 'OmniGraffle Professional' model.dot

desc "Generate a DOT diagram of the ActiveRecord model objects in 'model.dot'"
task :dot => :environment do
  Dir.glob("app/models/*rb") { |f|
    require f
  }
  File.open("model.dot", "w") do |out|
    out.puts "digraph x {"
    #out.puts "\tnode [fontname=Helvetica,fontcolor=blue]"
    out.puts "\tnode [fontname=Helvetica]"
    out.puts "\tedge [fontname=Helvetica,fontsize=10]"
    Dir.glob("app/models/*rb") { |f|
      f.match(/\/([a-z_]+).rb/)
      classname = $1.camelize
      klass = Kernel.const_get classname
      if (klass.class != Module) && (klass.ancestors.include? ActiveRecord::Base)
        if klass.include? ActiveRecord::Acts::List::InstanceMethods
          scope = klass.new.scope_condition.sub(/(_id?) .*/,'').camelize
          out.puts "\t#{classname} [label=\"#{classname}\\n(list in #{scope})\"]"
        elsif klass.superclass != ActiveRecord::Base
          out.puts "\t#{classname} -> #{klass.superclass.name} [arrowhead=empty]"
        else
          out.puts "\t#{classname}"
        end
        klass.reflect_on_all_associations.select { |a| a.macro.to_s.starts_with? 'has_' }.each do |a|
          target = a.name.to_s.camelize.singularize
          if a.klass.name != target
            target = a.klass.name
            label = ",label=\"as #{a.name}\""
          else
            label =""
          end
          case a.macro.to_s
          when 'has_many'
            out.puts "\t#{classname} -> #{target} [arrowhead=crow#{label}]"
          when 'has_and_belongs_to_many'
            out.puts "\t#{classname} -> #{target} [arrowhead=crow,arrowtail=crow#{label}]" if classname < target
          when 'has_one'
            out.puts "\t#{classname} -> #{target} [arrowhead=diamond#{label}]"
          else
            $stderr.puts "No support for #{a.macro.to_s} in #{classname}"
          end
        end
      end
    }
    out.puts "}"
  end
  system "dot -Tpng model.dot -o model.png"
  system "/Applications/Graphviz.app/Contents/MacOS/dot -Tpng model.dot -o model.png" unless $?.success?
  puts "Could not write model.png. Please install graphviz (http://www.graphviz.org)." unless $?.success?
end
