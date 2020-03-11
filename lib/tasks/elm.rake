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

  def compile_and_minify(name, args, main="Main")
    js = "_#{name}_elm.js"
    min = "../_#{name}_elm.min.js"
    opt = args[:debug].present? ? "" : "--optimize"
    if system("elm make #{main}.elm #{opt} --output #{js}")
      File.open(min, "w") do |file|
        file.write(Uglifier.compile(File.read(js)))
      end
      puts "minified to #{min}"
    end
  end

  desc "make and minify the Elm JS file for Family Tree"
  task :tree, [:debug] do |task, args|
    Dir.chdir("app/views/people/elm") do
      compile_and_minify "tree", args
    end
  end

  desc "make and minify the Elm JS file for AOC"
  task :aoc, [:debug] do |task, args|
    Dir.chdir("app/views/pages/aoc") do
      compile_and_minify "aoc", args
    end
  end

  desc "make and minify the Elm JS file for Play"
  task :play, [:debug] do |task, args|
    Dir.chdir("app/views/pages/play") do
      compile_and_minify "play", args
    end
  end

  desc "make and minify the Elm JS file for Magic Numbers"
  task :magic, [:debug] do |task, args|
    Dir.chdir("app/views/pages/magic") do
      compile_and_minify "magic", args
    end
  end

  desc "make and minify the Elm JS file for Board"
  task :board, [:debug] do |task, args|
    Dir.chdir("app/views/pages/board") do
      compile_and_minify "board", args, "Board"
    end
  end
end
