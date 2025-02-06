namespace :elm do
  # based on https://github.com/ChristophP/elm-esm/blob/master/src/index.js
  def esmify(text)
    commented = ""
    if text.match(/_Platform_export\((\{.*\})\);\}\(this\)/m)
      elmExports = $1
    else
      puts "couldn't find elmExports"
      return text
    end
    filter = false
    text.each_line do |line|
      unless filter
        case line
        when /\A\(function\(scope\)/
          filter = 1
        when /\A['"]use strict['"];/
          filter = 1
        when /\Afunction _Platform_export/
          filter = "}\n"
        when /\Afunction _Platform_mergeExports/
          filter = "}\n"
        when /\A_Platform_export\(\{/
          filter = 2
        end
      end
      commented += (filter ? "// -- " : "") + line
      if filter
        case filter
        when 1
          filter = false
        when 2
          filter = true
        else
          filter = false if line == filter
        end
      end
    end

    commented += "\nexport const Elm = #{elmExports};\n"
    commented
  end

  def compile_and_minify(name, args, main="Main")
    js = "_#{name}_elm.js"
    min = "../../../javascript/elm_#{name}.min.js"
    opt = args[:debug].present? ? "" : "--optimize"
    if system("elm make #{main}.elm #{opt} --output #{js}")
      File.open(min, "w") do |file|
        file.write(Terser.compile(esmify(File.read(js))))
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

  desc "make and minify the Elm JS file for Board"
  task :board, [:debug] do |task, args|
    Dir.chdir("app/views/pages/board") do
      compile_and_minify "board", args, "Board"
    end
  end

  desc "make and minify the Elm JS file for Weight"
  task :weight, [:debug] do |task, args|
    Dir.chdir("app/views/pages/weight") do
      compile_and_minify "weight", args, "Weight"
    end
  end
end
