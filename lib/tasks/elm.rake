class ErbContext
  def initialize(hash)
    hash.each_pair do |key, val|
      instance_variable_set("@" + key.to_s, val)
    end
  end

  def get_binding
    binding
  end
end

namespace :elm do
  def generate(names, hash={})
    context = ErbContext.new(hash).get_binding
    names.each do |name|
      source = "#{name}.elm.erb"
      target = "#{name}.elm"
      File.open(target, "w") do |file|
        file.write(ERB.new(File.read(source)).result(context))
      end
      puts "generated #{target}"
    end
  end

  def compile_and_minify(name)
    js = "_#{name}_elm.js"
    min = "../_#{name}_elm.min.js"
    if system("elm-make Main.elm --output #{js}")
      File.open(min, "w") do |file|
        file.write(Uglifier.compile(File.read(js)))
      end
      puts "minified to #{min}"
    end
  end

  def todos_stuff
    hash = {}
    hash[:priority_high] = Todo::PRIORITIES.min
    hash[:priority_low] = Todo::PRIORITIES.max
    hash[:priority_desc] = Todo::PRIORITIES.reduce({}) { |d, p| d[p] = I18n.t("todo.priorities")[p]; d }
    hash[:priority_first] = Todo::PRIORITIES[0]
    hash
  end

  desc "make and minify the Elm JS file for Todos"
  task todos: :environment do
    Dir.chdir("app/views/todos/elm") do
      generate %w/Misc/, todos_stuff
      compile_and_minify "todos"
    end
  end

  desc "make and minify the Elm JS file for Family Tree"
  task :tree do
    Dir.chdir("app/views/people/elm") do
      compile_and_minify "tree"
    end
  end

  desc "make and minify the Elm JS file for AOC"
  task :aoc do
    Dir.chdir("app/views/pages/aoc") do
      compile_and_minify "aoc"
    end
  end

  desc "make and minify the Elm JS file for AOC version 2"
  task :aoc2 do
    Dir.chdir("app/views/pages/aoc2") do
      compile_and_minify "aoc2"
    end
  end

  desc "make and minify the Elm JS file for Play"
  task :play do
    Dir.chdir("app/views/pages/play") do
      compile_and_minify "play"
    end
  end
end
